# Joins

## What is it?

A `JOIN` combines rows from two data sources (tables or CDS views) based on a matching condition, and — unlike an association — is **always executed** as part of the view's generated SQL.

## Why is it used?

- To combine data from multiple tables that must **always** appear together in the result (e.g. purchase order header + item).
- To implement fallback logic across several tables using `LEFT OUTER JOIN` + `CASE`/`COALESCE`.

## When should it be used?

Use a join when the related data is **mandatory** for every consumer of the view. If the relationship is optional or only needed by some consumers, prefer an [association](Association.md) instead — it avoids the join cost when unused.

## Join Types (original notes, with explanations)

### Cross Join

> The cross join is a join operation that produces the Cartesian product of two tables.

```abap
@AbapCatalog.sqlViewName: 'ZSM_V_JOIN01'

define view ZSM_I_001
  as select from ekko
  cross join ekpo
  {
    ekko.ebeln,
    ekpo.ebelp
  }
```

> ⚠️ **Corrected from the original note.** The original snippet wrote `cross join ekpo on ekpo.ebeln = ekko.ebeln`. A `CROSS JOIN` takes **no** `ON` condition — it multiplies every row of the left table with every row of the right table. The `on` clause has been removed above so the example is a genuine Cartesian product. If you need matched rows instead, use `inner join` (below).

### Inner Join

> The inner join is a join operation that produces the result of the intersection of two tables.

```abap
@AbapCatalog.sqlViewName: 'ZSM_V_JOIN02'

define view ZSM_I_001
  as select from ekko
  inner join ekpo on ekpo.ebeln = ekko.ebeln
  {
    ekko.ebeln,
    ekpo.ebelp
  }
```

Only rows that have a match in **both** `ekko` (PO header) and `ekpo` (PO item) are returned.

### Left Outer Join

> The left outer join is a join operation that produces the result of the intersection of two tables, plus all the rows from the left table that do not have a match in the right table.

```abap
@AbapCatalog.sqlViewName: 'ZSM_V_JOIN03'

define view ZSM_I_001
  as select from ekko
  left outer join ekpo on ekpo.ebeln = ekko.ebeln
  {
    ekko.ebeln,
    ekpo.ebelp
  }
```

All `ekko` rows are kept, even if there is no matching `ekpo` row (the `ekpo` fields would be `NULL` in that case).

### Left Outer Join — Fallback with `CASE WHEN`

```abap
@AbapCatalog.sqlViewName: 'ZSM_V_JOIN04'

define view ZSM_I_001
  as select from ZSM_T_001 as T1
  left outer join ZSM_T_002 as T2 on T2.matnr = T1.matnr and T2.lgort = T1.lgort
  left outer join ZSM_T_003 as T3 on T3.matnr = T1.matnr and T3.lgort = T1.lgort
  {
    T1.matnr                                  as MaterialNumber,
    case when T2.menge is null then T3.menge
         else T2.menge
     end                                      as Quantity
  }
```

A classic "prefer table T2, fall back to T3" pattern: if `T2.menge` is not found (i.e. `NULL` after the left outer join), use `T3.menge` instead.

### Left Outer Join — Fallback with `COALESCE`

```abap
@AbapCatalog.sqlViewName: 'ZSM_V_JOIN05'

define view ZSM_I_001
  as select from ZSM_T_001  as T1
  left outer join ZSM_T_002 as T2 on T2.matnr = T1.matnr and T2.lgort = T1.lgort
  left outer join ZSM_T_003 as T3 on T3.matnr = T1.matnr and T3.lgort = T1.lgort
  {
    T1.matnr                    as MaterialNumber,
    coalesce(T2.menge,T3.menge) as Quantity
  }
```

`COALESCE(a, b)` returns the first non-`NULL` value — a shorter equivalent of the `CASE WHEN ... IS NULL` pattern above. Prefer `COALESCE` for simple "use this, otherwise that" fallbacks; reserve `CASE WHEN` for conditions beyond a plain null-check (see [05-Filtering-and-Parameters/Condition.md](../05-Filtering-and-Parameters/Condition.md)).

### Right Outer Join

> The right outer join is a join operation that produces the result of the intersection of two tables, plus all the rows from the right table that do not have a match in the left table.

```abap
@AbapCatalog.sqlViewName: 'ZSM_V_JOIN06'

define view ZSM_I_001
  as select from ekko
  right outer join ekpo on ekpo.ebeln = ekko.ebeln
  {
    ekko.ebeln,
    ekpo.ebelp
  }
```

> 📝 `RIGHT OUTER JOIN` is supported but rarely used in practice — it's usually clearer to swap the `FROM`/join order and use `LEFT OUTER JOIN` instead, so the "driving" table always appears first.

## Join Type Comparison

| Join Type | Rows Returned |
|---|---|
| `INNER JOIN` | Only matching rows from both sides |
| `LEFT OUTER JOIN` | All rows from the left side + matches from the right (unmatched right fields = `NULL`) |
| `RIGHT OUTER JOIN` | All rows from the right side + matches from the left (unmatched left fields = `NULL`) |
| `CROSS JOIN` | Cartesian product — every row of A × every row of B (no `ON` condition) |

## Common Mistakes

- ❌ Writing `CROSS JOIN ... ON ...` — a cross join takes no `ON` condition. If you need a matching condition, you want `INNER JOIN`.
- ❌ Chaining many `LEFT OUTER JOIN`s and forgetting that any field from the joined table can now be `NULL` — always handle with `COALESCE`/`CASE WHEN` where a non-null default matters.
- ❌ Joining on a non-indexed field, causing full table scans on large tables.

## Performance Considerations

- Every join in the field list is **always executed**, regardless of whether the joined fields are consumed — unlike associations. Only add a join when the data is genuinely needed for every consumer.
- Join order and join fields matter for HANA's optimizer; join on **key fields** wherever possible.
- Multiple `LEFT OUTER JOIN`s to fetch "the first available value" (as in the fallback examples) can often be replaced by a single association with a filter — evaluate whether an association is more appropriate.

## SAP Best Practices

- Alias every source table (`as T1`, `as T2`) once more than one table is involved — improves readability and avoids ambiguous field errors.
- Use `LEFT OUTER JOIN` (not `RIGHT OUTER JOIN`) as the default outer join style, keeping the "main" entity on the left for readability.
- Reach for an [association](Association.md) instead of a join whenever the relationship is optional.

## Interview Notes

- **Q: When would you use a join instead of an association in a CDS view?**
  A: When the joined data is mandatory for every consumer and must always appear in the query result — associations are lazily resolved and won't execute unless explicitly used.
- **Q: What's the difference between `COALESCE` and `CASE WHEN ... IS NULL`?**
  A: `COALESCE` is a concise built-in for "return the first non-null value"; `CASE WHEN` is needed when the condition is more complex than a null check.

## Related Chapters

- [Association.md](Association.md) — the lazy alternative to joins
- [Union.md](Union.md) — combining result sets vertically instead of horizontally
- [05-Filtering-and-Parameters/Condition.md](../05-Filtering-and-Parameters/Condition.md) — `CASE`/`COALESCE` in depth
