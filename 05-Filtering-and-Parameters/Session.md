# Session Variables (`$session`)

## What is it?

`$session` gives a CDS view access to **client-session context** — the current client, system date, logon language, and user — without needing to pass them in explicitly as parameters.

## Why is it used?

- To filter data relative to "today," the current user, or the current logon language directly in the view.
- To keep views client-aware and language-aware without requiring every caller to supply that context manually.

## When should it be used?

Use `$session` for context that is implicitly true for *any* caller in the current session (today's date, the logged-on user, the client). Use [input parameters](Parameters.md) instead when the caller needs to supply an explicit, overridable value (e.g. "as of this specific date," which might not be today).

## Available Session Variables (original note)

```abap
" Definition
$session.client          as CurrentClient,  " => T4D
$session.system_date     as SystemDate,     " => 2024-11-14
$session.system_language as SystemLanguage, " => TR
$session.user            as Username        " => XSMERCAN
```

| Variable | Returns |
|---|---|
| `$session.client` | The current logon client (e.g. `'100'`, `'T4D'`). |
| `$session.system_date` | Today's date, as `abap.dats`. |
| `$session.system_language` | The current logon language key (e.g. `'EN'`, `'TR'`). |
| `$session.user` | The current logged-on user name. |

## Basic Example (original note)

```abap
" Example
define view ZSM_I_001
as select from mara {
    matnr,
    $session.client as CurrentClient
}
where ersda = $session.system_date
```

Filters `mara` to only rows created **today**, and additionally exposes the current client as a field.

## `$session.system_date` in an Association Filter (original note)

```abap
" Ex: System Date in Association
define root view entity ZSM_I_0005
  as select from I_BillingDocumentItem  as BDI
  association [0..1] to /sapsll/maritc  as _Maritc  on _Maritc.matnr = BDI.Product
                                                   and _Maritc.stcts = 'TR01'
                                                   and _Maritc.datab <= $session.system_date
                                                   and _Maritc.datbi >= $session.system_date
{
  key BDI.BillingDocument     as VbelnVF,
  key BDI.BillingDocumentItem as PosnrVF,
      _Maritc.ccngn           as GTIP
}
```

This is the classic **time-dependent master data** pattern: the association's `ON` condition restricts the related row to the one whose validity period (`datab`/`datbi` — valid-from/valid-to) contains today's date, so exactly one "current" record is picked for each product.

## `$session.system_language` in a Path Expression (original note)

```abap
" Ex: System Language
define root view entity ZSD_I_0002
  as select from ZSD_I_0003 as I0003
  association [0..1] to I_BillingDocumentItem as _BDI on _BDI.BillingDocument     = $projection.VbelnVF
                                                     and _BDI.BillingDocumentItem = $projection.PosnrVF
{
  key vbeln_vf                                                                                                  as VbelnVF,
      posnr_vf                                                                                                  as PosnrVF,
      _BDI._BillingDocument._SalesOrganization.SalesOrganization                                                as Vkorg,
      _BDI._BillingDocument._SalesOrganization._Text[Language = $session.system_language].SalesOrganizationName as VkorgText
}
```

A **deep path expression** (`_BDI._BillingDocument._SalesOrganization._Text`) drilling through three levels of associations, with the final text association filtered by `$session.system_language` — the standard way to fetch a description in the current user's logon language. See also [03-Data-Modeling/Association.md](../03-Data-Modeling/Association.md).

## `$session.system_language` with Cardinality Hint (original note)

```abap
" Ex: System Language w/ Parameter
@Semantics.text: true
_Equipment._EquipmentText[ 1:Language = $session.system_language ].EquipmentName
```

The `1:` prefix inside the filter (`[ 1:Language = ... ]`) is a **cardinality hint** telling the compiler that, despite the association's declared cardinality, at most one row is expected to match this filter — allowing the path expression to be used as a scalar field instead of requiring an explicit aggregate.

## Common Mistakes

- ❌ Using `$session.system_date` when the business logic actually needs a **caller-supplied** key date (e.g. simulating "as of a past date") — use a [parameter](Parameters.md) instead.
- ❌ Forgetting to filter time-dependent associations by `$session.system_date` (or a key-date parameter) and ending up with multiple/ambiguous rows from a `[0..*]` association that was only supposed to yield one "current" record.
- ❌ Assuming `$session.client` is needed explicitly in most views — client handling is usually automatic (see `@ClientHandling.algorithm` in [04-CDS-Annotations/Annotation-Global.md](../04-CDS-Annotations/Annotation-Global.md)); only expose it explicitly when genuinely required.

## Performance Considerations

- `$session` variables are resolved once per query execution (not per row) — negligible overhead.
- Filtering time-dependent associations by `$session.system_date` inside the `ON` condition (rather than in the outer `WHERE`) lets the database apply the filter as part of the join itself, which is typically more efficient than joining all validity periods and filtering afterward.

## SAP Best Practices

- Prefer `$session.system_language` over hardcoding a language key for any text association — this is what makes views usable across all logon languages without modification.
- Document explicitly, in a comment, when a view depends on `$session.system_date`/`$session.system_language`, since this makes its output context-dependent (same query returns different values depending on who runs it and when).

## Interview Notes

- **Q: What is `$session.system_language` typically used for?**
  A: Filtering text associations to return the description in the current user's logon language.
- **Q: What's the difference between `$session.system_date` and a key-date parameter?**
  A: `$session.system_date` always reflects "now" for the current session; a parameter lets the caller override the reference date explicitly (e.g. to simulate a historical point in time).

## Related Chapters

- [Parameters.md](Parameters.md) — the explicit, caller-supplied alternative to `$session`
- [03-Data-Modeling/Association.md](../03-Data-Modeling/Association.md) — associations and path expressions used alongside `$session`
- [06-Built-In-Functions/Date.md](../06-Built-In-Functions/Date.md) — date arithmetic often combined with `$session.system_date`
