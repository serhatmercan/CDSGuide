# CDS View Basics — `define view`

## What is it?

The `define view` statement is the entry point for creating a classic CDS view. It declares a new **DDL source** that selects fields from one or more underlying tables (or other CDS views) and exposes them as a reusable, database-independent data model.

## Why is it used?

- To model a reusable **read** view on top of one or more tables without duplicating SQL logic across programs.
- To generate a proper database view (via `@AbapCatalog.sqlViewName`) that other ABAP programs, CDS views, and OData services can consume.
- To attach semantic and UI metadata (annotations) directly to the data model.

## When should it be used?

Use `define view` (or its modern successor `define view entity` — see note below) whenever you need to expose table data for reporting, consumption by another view, RAP, or OData — instead of writing an ad-hoc `SELECT` in a report.

> 📝 **`define view` vs. `define view entity`**
>
> | | `define view` | `define view entity` |
> |---|---|---|
> | Introduced | Classic CDS (7.40+) | ABAP 7.51+ / S/4HANA 1809+ |
> | Association target type | View | View Entity |
> | Used for RAP | ❌ Not directly | ✅ Yes |
> | Recommended for new development | No | **Yes** |
>
> SAP recommends using `define view entity` for all new development on modern releases. The classic `define view` syntax is preserved throughout this guide because it is still widely found in existing systems and is what these original notes were written against — but favor `entity` syntax for greenfield projects.

## Basic Syntax (original note)

```abap
" Main CDS Template
@AbapCatalog.sqlViewName            : 'ZSM_V_001'
@AccessControl.authorizationCheck   : #NOT_REQUIRED
@EndUserText.label                  : 'Main CDS'

define view ZSM_I_001
  as select from mara

{
  matnr
}
```

### Keyword-by-keyword explanation

| Element | Meaning |
|---|---|
| `@AbapCatalog.sqlViewName` | The name of the physical SQL database view generated in the DDIC (max. 16 characters, visible in `SE11`). |
| `@AccessControl.authorizationCheck` | Whether an access control (DCL) check is enforced when the view is selected. See [09-Security/AccessControl.md](../09-Security/AccessControl.md). |
| `@EndUserText.label` | The human-readable description shown in `SE11`/ADT. |
| `define view <name>` | Declares the CDS view. By naming convention, custom views typically start with `Z`/`Y` and use an `_I_` infix (Interface view) — e.g. `ZSM_I_001`. |
| `as select from <table>` | The data source — a table, CDS view, or table function. |
| `{ ... }` | The **element list** — the fields exposed by the view. |

## Modern Example (`define view entity`)

```abap
@AbapCatalog.sqlViewName: 'ZSM_V_001'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Main CDS (View Entity)'

define view entity ZSM_I_001
  as select from mara
{
  key matnr as Material,
      mtart as MaterialType,
      meins as BaseUnit
}
```

> 💡 Every element exposed as a **key** should be marked with the `key` keyword. This is mandatory in `define view entity` and strongly recommended in classic `define view` — without a key, consumers (like OData or RAP) cannot uniquely identify rows.

## Naming Conventions (commonly seen in SAP projects)

| Prefix | Meaning |
|---|---|
| `I_` / `ZI_` | Interface View (basic, reusable building block) |
| `C_` / `ZC_` | Consumption View (exposed to UI/OData, built on top of interface views) |
| `P_` / `ZP_` | Projection View (RAP projection layer) |
| `R_` | Root View Entity (RAP) |

## Common Mistakes

- ❌ Forgetting `key` on the primary key field(s) — causes errors or unpredictable behavior when the view is consumed by OData/Fiori.
- ❌ Reusing an existing `sqlViewName` — causes activation conflicts.
- ❌ Selecting `*` in production views (see [07-Query-and-Reporting/Query.md](../07-Query-and-Reporting/Query.md)) — makes the view fragile to table changes and hides which fields are actually needed.

## Performance Considerations

- A `define view` with only field selection (no joins/aggregation) compiles to a simple database view — negligible overhead.
- Keep the field list as narrow as needed; extra fields increase the payload for every consumer of the view, even if unused.

## SAP Best Practices

- Prefer `define view entity` on releases that support it.
- Always assign a meaningful `@EndUserText.label`.
- Use a consistent naming convention (`Z<module>_I_<number>`) across your team.
- Alias the source table (`as Mara`) once the view grows associations or joins — makes field references unambiguous (see [03-Data-Modeling/Association.md](../03-Data-Modeling/Association.md)).

## Interview Notes

- **Q: What's the difference between a CDS view and a classic database view (`SE11` view)?**
  A: A CDS view is defined in ABAP-managed DDL source, supports associations, annotations, and can be consumed by OData/RAP; the underlying SQL view is only the generated artifact.
- **Q: Is a CDS view a physical table?**
  A: No — it's a virtual view; data is fetched from the underlying tables at query time (with the exception of buffered views, see [04-CDS-Annotations/Annotation-Global.md](../04-CDS-Annotations/Annotation-Global.md)).

## Related Chapters

- [Program.md](Program.md) — using this view in an ABAP report
- [03-Data-Modeling](../03-Data-Modeling/Association.md) — adding associations and joins
- [04-CDS-Annotations](../04-CDS-Annotations/Annotation-Global.md) — enriching the view with metadata
