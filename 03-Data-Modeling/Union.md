# Union

## What is it?

`UNION` (and `UNION ALL`) combines the result sets of two or more `SELECT` statements **vertically** — stacking rows on top of each other — as long as each `SELECT` returns a compatible set of columns (same number, compatible types).

## Why is it used?

- To combine data from structurally similar tables/views into a single result (e.g. combining sales orders and returns into one "documents" view).
- To build a **union view**, a well-known CDS design pattern for aggregating heterogeneous sources under one semantic view.

## When should it be used?

Use `UNION`/`UNION ALL` when you need to **stack** compatible row sets from different sources. Use a [join](Join.md) instead when you need to combine columns from different sources for the *same* row.

## `UNION` vs. `UNION ALL`

| | `UNION` | `UNION ALL` |
|---|---|---|
| Duplicate rows | Removed (implicit `DISTINCT`) | Kept |
| Performance | Slower (extra de-duplication step) | Faster |
| Typical use | When exact duplicates must not appear | When sources are already known to be distinct, or duplicates are acceptable/expected |

> 💡 **Best practice:** default to `UNION ALL` unless you specifically need de-duplication — the `DISTINCT` pass behind plain `UNION` has a real performance cost, especially on large result sets.

## Basic Syntax Example (original note)

```abap
@AbapCatalog.sqlViewName: 'ZSM_V_UNION01'

define view ZSM_CDS_TEST_VIEW
  as select from ZSM_T_001

{
  column1
}

union all
  select from ZSM_T_002

{
  column1
}
```

Each branch of the union must expose the **same number of columns**, in the **same order**, with compatible types. The column names of the *first* `SELECT` become the column names of the combined result.

## Union Branch with a `WHERE` Condition (original note)

> 📌 **PARTIAL SNIPPET** — a single union branch, shown on its own. It must follow a first branch carrying the full `define view … as select from …` header (see the complete example below).

```abap
union all
  select from ZSM_T_002

{
  column1
}

where column1 < 10
```

Each individual branch of a `UNION`/`UNION ALL` can carry its own `WHERE` condition — filters apply only to that branch before the rows are stacked.

> ⚠️ **Correction note:** the original notes also contained a branch written as `union / select from ZSM_T_002 / as select from ZSM_T_001 { column1 } where column1 > 10` — mixing `union` (which expects a bare `select from ...`) with the `define view ... as select from ...` view-header syntax is not valid CDS. A `UNION`/`UNION ALL` branch after the first is always a plain `select from <source> { ... }` (optionally with `where`), **without** a leading `define view` or `as`. A corrected, complete three-way union looks like this:

```abap
@AbapCatalog.sqlViewName: 'ZSM_V_UNION02'

define view ZSM_CDS_TEST_VIEW
  as select from ZSM_T_001
  {
    column1
  }
  where column1 > 10

  union all
    select from ZSM_T_002
    {
      column1
    }
    where column1 < 10

  union all
    select from ZSM_T_003
    {
      column1
    }
```

## Common Mistakes

- ❌ Mismatched column count/order across union branches — CDS will raise an activation error.
- ❌ Mixing `union` and `union all` inconsistently within the same view without understanding the de-duplication cost of the plain `union` branches.
- ❌ Forgetting that `ORDER BY` can only appear once, at the very end of the whole union, not per branch.
- ❌ Repeating `define view ... as` syntax in subsequent branches (only the very first branch uses the full view header).

## Performance Considerations

- `UNION ALL` avoids an implicit sort/de-duplication step — always prefer it when duplicates are not a concern.
- Filtering each branch's `WHERE` clause as early as possible (rather than filtering the combined result afterward) lets the database prune rows per source before the union executes.

## SAP Best Practices

- Keep exposed column names identical in meaning and type across branches, even though only the first branch's aliases are used for the final result — this avoids confusion when maintaining the view later.
- Document (via comments or `@EndUserText.label`) what each branch represents, since the combined view hides the origin of each row unless you explicitly add a literal/discriminator column (e.g. `'ORDER' as SourceType`).

## Interview Notes

- **Q: What's the difference between `UNION` and `JOIN`?**
  A: `UNION` stacks rows vertically from compatible result sets; `JOIN` combines columns horizontally based on a matching condition.
- **Q: Why would you prefer `UNION ALL` over `UNION`?**
  A: `UNION ALL` skips the duplicate-removal step, which is cheaper — use it whenever duplicate rows are impossible or acceptable.

## Related Chapters

- [Join.md](Join.md) — combining columns instead of stacking rows
- [07-Query-and-Reporting/Query.md](../07-Query-and-Reporting/Query.md) — aggregation and filtering patterns that often accompany unions
