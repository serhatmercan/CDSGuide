# Associations & Cardinality

## What is it?

An **association** defines a navigable relationship between a CDS view (or table) and another CDS entity, similar to a foreign-key relationship, but lazily resolved: the joined fields are only fetched from the database when a consumer actually requests them through a **path expression** (`_Association.Field`).

## Why is it used?

- To model relationships (e.g. Material → Material Text) **without** forcing a join for every consumer — the join only happens if the associated field is actually requested.
- To express **cardinality** (how many related rows can exist) so the database/RAP framework can optimize and validate the relationship.
- To enable **path expressions**, letting consumers "drill" into related entities (`_Association._NestedAssociation.Field`).

## When should it be used?

Use associations instead of joins when:
- The related data is **optional** for most consumers (lazy loading avoids unnecessary joins).
- You want to expose a relationship for **navigation** (e.g. Fiori Elements object pages navigating from header to items).
- You are modeling **parent/child** or **text/master-data** relationships.

Use a plain `JOIN` instead (see [Join.md](Join.md)) when the related fields are **always** required in the result set of the view.

## Syntax

```abap
association [<cardinality>] to <target> as _Alias on <condition>
```

## Cardinality Reference (original note)

| Cardinality | Minimum | Maximum |
|---|---|---|
| `[1]` | 0 | 1 |
| `[0..1]` | 0 | 1 |
| `[1..1]` | 1 | 1 |
| `[0..*]` | 0 | Unlimited |
| `[1..*]` | 1 | Unlimited |

> 📝 **Note:** `[1]` is shorthand for `[0..1]` in most SAP examples/documentation — both mean "zero or exactly one related row." Cardinality is a **declaration of intent/contract**, not something the database enforces at runtime; be sure the underlying data actually matches the declared cardinality, or you may get truncated or duplicated results downstream.

## Examples (original notes)

### Default Cardinality

```abap
@AbapCatalog.sqlViewName: 'ZSM_V_ASSOC01'

define view ZSM_I_001
  as select from mara as Mara

  association [0..1] to makt as _Makt on _Makt.matnr = Mara.matnr

{
  key Mara.matnr  as MaterialNo,

      _Makt.maktx as MaterialText
}
```

Here `_Makt` is declared `[0..1]` — for one material there is at most one matching text row (in a single language, in practice you would also filter by language — see the *Filter Cardinality* example below and [05-Filtering-and-Parameters/Session.md](../05-Filtering-and-Parameters/Session.md)).

### Multi Cardinality

```abap
@AbapCatalog.sqlViewName: 'ZSM_V_ASSOC02'

define view ZSM_I_001
  as select from snwd_so as SO

  association [1..*] to snwd_so_i as _SOI on _SOI.parent_key = $projection.SalesOrder
  association [1..1] to snwd_bpa  as _BPA on _BPA.node_key   = SO.buyer_guid

{
  key SO.node_key        as SalesOrder,

      SO.so_id           as SalesOrderID,
      SO.currency_code   as Currency,
      SO.gross_amount    as GrossAmount,
      SO.net_amount      as NetAmount,

      _SOI.tax_amount    as TaxAmount,
      _BPA.phone_number  as PhoneNumber
}
```

`_SOI` (Sales Order Items) is `[1..*]` — a sales order always has at least one item and can have many. `_BPA` (Business Partner) is `[1..1]` — exactly one related row is expected.

> ⚠️ **Two corrections from the original note.** (1) The comma after `_SOI.tax_amount` was missing — in real DDL source that is a syntax error, since every element except the last must be comma-separated. (2) The `_BPA` association joined the business-partner key to the *sales order* key (`_BPA.node_key = $projection.SalesOrder`), which is not a meaningful relationship; it now joins on the order's buyer reference instead.

> 📝 **A `[1..*]` path in the element list is allowed** — but be deliberate about it. Exposing `_SOI.tax_amount` from a to-many association can **multiply the result rows** (one row per matching item), which changes the granularity of the view. That is sometimes exactly what you want; when it is not, filter the path down to a single row (see *Filter Cardinality*, below) or model the relationship as a separate item view.

### Filter Cardinality (Association with a Filter Condition)

```abap
@AbapCatalog.sqlViewName: 'ZSM_V_ASSOC03'

define view ZSM_I_001
  as select from snwd_pd as Product

  association [0..*] to snwd_texts as _ProductText on _ProductText.parent_key = $projection.ProductNameGuid

{
  key Product.node_key                                       as ProductKey,

      Product.product_id                                     as ProductID,
      Product.name_guid                                      as ProductNameGuid,
      _ProductText[language = $session.system_language].text as ProductName
}
```

The `[language = $session.system_language]` filter is applied **on the association path**, restricting the `[0..*]` texts down to a single row in the current user's logon language — a very common pattern for text associations. See [05-Filtering-and-Parameters/Session.md](../05-Filtering-and-Parameters/Session.md).

### Parent-Child (Hierarchy) Cardinality

```abap
define view entity ZSM_I_001
  as select from zsm_t_0001 as T1

  association to parent ZSM_I_002 as _T2 on _T2.UUID = $projection.UUID

{
  key T1.UUID,

      _T2
}
```

`association to parent` is used to model **hierarchical / recursive** relationships (e.g. an org unit pointing to its parent org unit) — commonly used together with hierarchy annotations in analytical scenarios.

### Projection Cardinality

```abap
@AbapCatalog.sqlViewName: 'ZSM_V_ASSOC04'

define view ZSM_I_001
  as select from mara as Mara

  association [0..1] to makt as _Makt on _Makt.matnr = $projection.MaterialNo

{
  key Mara.matnr  as MaterialNo,
      _Makt.maktx as MaterialText
}
```

Notice the `on` condition references `$projection.MaterialNo` — the **exposed alias**, not the source field `Mara.matnr`. This is only possible because the association is declared *after* the field is exposed in the SELECT list context (`$projection` refers to the view's own output fields). This is a common way to keep join conditions readable when the underlying field names differ from the exposed ones.

## `$projection` vs. direct field reference

| Reference | Meaning |
|---|---|
| `Mara.matnr` | The field as it exists in the source table/alias. |
| `$projection.MaterialNo` | The field **as exposed** by this view (the aliased name). Useful when an association needs to refer to the view's own renamed output. |

## Common Mistakes

- ❌ Declaring `[1..1]` when the relationship can actually be empty — leads to unexpected `NULL`/blank results being treated as "should always exist."
- ❌ Forgetting to filter text associations by language (`$session.system_language`), returning multiple rows per key over `[0..*]` when only one text is expected.
- ❌ Confusing `$projection` with the source alias — `$projection` only works with fields **already exposed** in the current view's SELECT list.

## Performance Considerations

- Associations are **lazy** — an association that is never referenced in the field list, `WHERE`, or another association does **not** generate a join in the compiled SQL. This is the core performance advantage over always-joining.
- Overusing deep association chains (`_A._B._C.field`) in filters can still generate expensive multi-way joins — check the generated SQL (`ST05`) if a view feels slow.

## SAP Best Practices

- Prefer associations over joins for **optional** or **navigational** relationships; reserve joins for data that's always needed (see [Join.md](Join.md)).
- Always model the **correct cardinality** — RAP and Fiori Elements use it to decide things like whether to show a "1" vs. a table for a navigation property.
- Name associations with a leading underscore (`_Makt`, `_Text`) — this is the SAP-wide naming convention for CDS associations.

## Interview Notes

- **Q: What is the difference between an association and a join in CDS?**
  A: An association is a *declared, lazily-resolved* relationship exposed via path expressions; it only becomes a SQL join if a consumer actually uses fields from it. A join is *always* executed as part of the view's SQL, regardless of whether the joined fields are used.
- **Q: What does cardinality `[0..1]` mean?**
  A: Zero or one related row exists for each row of the source entity.

## Related Chapters

- [Join.md](Join.md) — the alternative when the join must always execute
- [Extend.md](Extend.md) — adding fields/associations to an existing view
- [05-Filtering-and-Parameters/Session.md](../05-Filtering-and-Parameters/Session.md) — `$session` used in association filters
