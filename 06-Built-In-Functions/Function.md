# Table Functions & AMDP (Overview)

> **Context:** Table functions implemented in AMDP are **HANA-specific** and step outside declarative, database-agnostic CDS. That has consequences beyond portability: AMDP does not support CDS access control (see Common Mistakes), and this is not the default modelling style for cloud-ready development. Treat it as a deliberate escape hatch. See [Classic vs Modern CDS](../02-CDS-Basics/Classic-vs-Modern.md).

## What is it?

A **CDS table function** is a CDS artifact whose result set is **not** computed by declarative DDL, but by a custom **AMDP (ABAP Managed Database Procedure)** method written in SQLScript. It behaves like a regular CDS entity to consumers (can be selected from, joined, exposed via OData), but its actual logic is imperative SQLScript running inside HANA.

## Why is it used?

- To implement logic that's difficult or impossible to express in plain declarative CDS (recursive calculations, complex procedural steps, calling other HANA-native procedures).
- To still get a proper CDS "shape" (typed result, associable, exposable) for logic that needs a procedural implementation.

## When should it be used?

Reach for a table function only when declarative CDS (views, associations, `CASE`, built-in functions) genuinely cannot express the needed logic — for example, factory-calendar-based working-day calculations, or complex recursive/iterative computations. Prefer plain CDS views whenever possible; table functions add implementation and maintenance complexity (SQLScript + AMDP class).

## Syntax and Example (original note)

```abap
@AccessControl.authorizationCheck: #NOT_REQUIRED

@ClientHandling.algorithm: #SESSION_VARIABLE
@ClientHandling.type: #CLIENT_DEPENDENT

@EndUserText.label: 'Function AMDP'

@ObjectModel.usageType: { dataClass: #TRANSACTIONAL, serviceQuality: #A, sizeCategory: #L }

define table function zsm_f_amdp
  with parameters
    @Environment.systemField: #CLIENT
    p_client : abap.clnt

returns

{
  Client         : abap.clnt;
  DocNo          : knumv;
  DocItemNo      : kposn;
  DocItemGuid    : guid;
  PriceBeginTime : cpet_firsttimestamp;
  PriceBeginDate : datum;
  PriceEndTime   : cpet_firsttimestamp;
  PriceEndDate   : datum;
  WorkingDay     : int4;
}

implemented by method
  zsm_cl_amdp=>get_data;
```

### The Implementing AMDP Class

```abap
CLASS ZSM_CL_AMDP DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      if_amdp_marker_hdb.

    CLASS-METHODS:
      get_data FOR TABLE FUNCTION zsm_f_amdp.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ZSM_CL_AMDP IMPLEMENTATION.

  METHOD get_data BY DATABASE FUNCTION FOR HDB LANGUAGE SQLSCRIPT OPTIONS READ-ONLY USING zsm_i_amdp.
    RETURN SELECT DISTINCT
      p_client                                                 as Client,
      docno                                                    as DocNo,
      docitemno                                                as DocItemNo,
      docitemguid                                              as DocItemGuid,
      pricebegintime                                           as PriceBeginTime,
      pricebegindate                                           as PriceBeginDate,
      priceendtime                                             as PriceEndTime,
      priceenddate                                             as PriceEndDate,
      workdays_between('PI', PriceBeginDate, PriceEndDate) + 1 as WorkingDay

  FROM zsm_i_amdp;
  ENDMETHOD.
ENDCLASS.
```

### Explanation

| Element | Meaning |
|---|---|
| `define table function <name> with parameters ... returns { ... }` | Declares the table function's signature — parameters in, a typed result structure out (note the **semicolon**-separated field list, unlike the comma-separated list of a regular view). |
| `implemented by method <class>=>get_data` | Points to the AMDP method providing the actual result. |
| `INTERFACES if_amdp_marker_hdb` | Marks the class as an AMDP class, required for any class implementing database procedures. |
| `METHOD ... BY DATABASE FUNCTION FOR HDB LANGUAGE SQLSCRIPT OPTIONS READ-ONLY USING <entity>` | The AMDP method body is written in **SQLScript**, not ABAP; `USING zsm_i_amdp` declares which CDS entities/tables the procedure is allowed to read from. |
| `workdays_between(...)` | A **HANA-native factory calendar** function (here `'PI'` is the factory calendar ID) — this kind of calendar-aware calculation is a classic reason to reach for a table function/AMDP instead of plain CDS. ⚠️ **Verify the signature for your HANA version** before reusing this call: `WORKDAYS_BETWEEN` is a SAP HANA SQL datetime function whose argument list (factory calendar, start date, end date, and a schema/source argument in some versions) differs between HANA releases. The example below is preserved as it was written against one specific system; treat the argument list as system-specific, not canonical. |

## Consuming a Table Function from a CDS View (original note, from Query.md context)

```abap
define view entity ZSM_I_WORKING_DAYS
  as select from ZSM_F_WORKING_DAYS( p_client: $session.client , p_fabkl: 'PI' )
{
  key CalendarDate,
      FactoryCalendar,
      MonthFirstDate,
      MonthLastDate,
      WorkingDaysMonth,
      IsWorkingDay
}
where
  IsWorkingDay <> 0
```

Once defined, a table function is selected from **exactly like a regular CDS view**, with parameters passed the same way as a [parameterized view](../05-Filtering-and-Parameters/Parameters.md) — consumers don't need to know it's backed by AMDP/SQLScript at all.

## Common Mistakes

- ❌ Reaching for a table function/AMDP as the default approach instead of trying to model the logic declaratively first — this adds SQLScript maintenance burden and database-specific code (SQLScript is HANA-specific, unlike standard CDS which is more database-agnostic).
- ❌ Forgetting `OPTIONS READ-ONLY` — table functions are for reading; write logic doesn't belong here.
- ❌ Not restricting `USING` to only the entities actually needed — overly broad access surfaces are harder to review and secure.
- ❌ Assuming a CDS entity's DCL role still applies inside the AMDP method — **AMDP does not support CDS access control**. Only ABAP SQL access *to the table function itself* can be access-controlled; the SQLScript body reads its `USING` sources directly, with no DCL evaluation. Any row-level restriction the data needs must therefore be enforced on the table function, or coded explicitly in the SQLScript. See [09-Security/AccessControl.md](../09-Security/AccessControl.md).

## Performance Considerations

- SQLScript inside AMDP runs natively in the HANA database engine — for genuinely procedural/iterative logic, this can be significantly faster than trying to force the same logic through nested CDS expressions, or (much worse) pulling data into ABAP to loop over it.
- Table functions **cannot** be buffered and have some restrictions compared to plain views (e.g. more limited support in certain RAP/analytics scenarios) — verify feature parity for the intended consumption channel before committing to this approach.

## SAP Best Practices

- Treat table functions as an **escape hatch** for logic that's genuinely hard to express declaratively (calendar arithmetic, recursive graphs, complex procedural steps) — not a default modeling style.
- Keep the AMDP method's SQLScript logic focused and well-commented; SQLScript debugging tooling is less mature than ABAP debugging.
- Mark the class `FINAL` and implement only `if_amdp_marker_hdb` plus the specific `FOR TABLE FUNCTION` methods needed — keep AMDP classes narrowly scoped.

## Interview Notes

- **Q: What is a CDS table function, and how does it differ from a regular CDS view?**
  A: A table function is a CDS entity whose result set is computed by a custom AMDP (SQLScript) method rather than declarative DDL — used when the required logic can't reasonably be expressed as a plain view, association, or built-in function.
- **Q: What language is used to implement a table function's logic?**
  A: SQLScript, inside an AMDP method of an ABAP class that implements `IF_AMDP_MARKER_HDB`.

## Related Chapters

- [05-Filtering-and-Parameters/Parameters.md](../05-Filtering-and-Parameters/Parameters.md) — parameters, used the same way for table functions
- [07-Query-and-Reporting/Query.md](../07-Query-and-Reporting/Query.md) — consuming a table function inside a regular CDS view
- [10-Examples/Class.md](../10-Examples/Class.md) — a different ABAP-side extension mechanism (virtual element exit class) for comparison
