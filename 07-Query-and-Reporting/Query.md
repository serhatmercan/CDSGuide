# Querying CDS Views — Filtering, Grouping & Aggregation

## What is it?

This chapter collects the core query-shaping clauses available in a CDS view's `SELECT` — field selection, aggregate functions, `GROUP BY`/`HAVING`, `WHERE`, and `DISTINCT` — the same relational toolkit as SQL, expressed in CDS DDL.

## Why is it used?

Every non-trivial CDS view needs to filter, group, or aggregate data at some point — these clauses are the bread and butter of CDS view design.

## When should it be used?

Use these clauses whenever the view needs to expose a filtered, grouped, or summarized subset of the underlying data rather than a 1:1 row copy.

## Field Selection (original notes)

```abap
// Table: ZSM_T_001
// Fields: VBELN, POSNR, AMOUNT, ERSDA, MENGE, ZZMENGE, BISMT, AUART
@AbapCatalog.sqlViewName: 'ZSM_V_QRY01'

define view ZSM_I_001
as select from ZSM_T_001 {
    key vbeln,
    key posnr,

    amount
}
```

A basic view exposing a composite key (`vbeln` + `posnr`) and one data field.

### Selecting All Elements

```abap
// All Elements - I: Select All Elements
@AbapCatalog.sqlViewName: 'ZSM_V_QRY02'

define view ZSM_I_001
as select from ZSM_T_001 {
    *
}
```

```abap
// All Elements - II: Select All Elements
@AbapCatalog.sqlViewName: 'ZSM_V_QRY03'

define view ZSM_I_001
as select from ZSM_T_001 {
    // Insert All Elements
}
```

> ⚠️ **Avoid `SELECT *` in real views.** While syntactically valid, exposing every source field makes the view fragile to future table changes (adding/removing a column changes the view's structure implicitly) and hides which fields are actually intended for consumption. The commented "Insert All Elements" form is an ADT quick-assist feature — it *expands* `*` into an explicit field list at edit time, which is the recommended way to use it: let the tool expand the list once, then maintain the explicit fields going forward.

## Aggregate Functions (original note)

> 📌 **PARTIAL SNIPPET** — `SELECT` body only; prepend a `define view … as` (or `define view entity …`) header to make it a view.

```abap
// Average & Count & Count(Distinct) & Min & Max & Sum
select from ZSM_T_001 {
    vbeln,
    avg(amount)                 as POAverage,
    count(*)                    as POCount,
    count( distinct amount )    as POCountDistinct,
    min(amount)                 as POMin,
    max(amount)                 as POMax,
    sum(amount)                 as POSum
}
group by vbeln
```

| Function | Purpose |
|---|---|
| `avg(expr)` | Average value. |
| `count(*)` | Number of rows in the group. |
| `count(distinct expr)` | Number of **distinct** non-null values of `expr` in the group. |
| `min(expr)` / `max(expr)` | Minimum/maximum value. |
| `sum(expr)` | Total. |

> 📝 Any field in the `SELECT` list that is **not** wrapped in an aggregate function must appear in `GROUP BY` — here, `vbeln` is grouped, and all other fields are aggregates over each `vbeln` group.

## `CASE`/`COALESCE` in the Field List

See [05-Filtering-and-Parameters/Condition.md](../05-Filtering-and-Parameters/Condition.md) and [03-Data-Modeling/Join.md](../03-Data-Modeling/Join.md) for the full explanation of these patterns:

> 📌 **PARTIAL SNIPPET** — field list only. The aliases `zf08`, `zf09` and `zf14` refer to condition tables that would be joined in the (omitted) `FROM` clause.

```abap
// Condition: Coalesce (Check If Exist Property I & Property II)
select from ZSM_T_001{
    key vbeln                                                                                                               as Vbeln,
    coalesce(menge, zzmenge)                                                                                                as Menge,
    coalesce(bismt, '')                                                                                                     as Bismt,
    cast(coalesce(coalesce(zf08.kbetr * zf08.kpein, zf09.kbetr * zf09.kpein), zf14.kbetr * zf14.kpein ) as abap.dec(10,2))  as Amount
}
```

The last field nests `coalesce()` three levels deep — a "try condition table ZF08, then ZF09, then ZF14" cascade, a common SD/pricing-condition pattern for picking the first available pricing record across several condition tables.

## `DISTINCT`

```abap
// Distinct
define root view entity ZSM_I_001
  as select distinct from T1
  inner join T2 on T2.number = T1.number
{
  key T1.srfxnr     as FieldI,
      T2.com_idtext as FieldII
}
```

`select distinct` removes duplicate rows from the result **after** the join — useful when a join can legitimately produce repeated combinations that should be collapsed. Compare this with `UNION` vs. `UNION ALL` de-duplication semantics (see [03-Data-Modeling/Union.md](../03-Data-Modeling/Union.md)).

## Consuming a Table Function (cross-reference)

```abap
// Function
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

See [06-Built-In-Functions/Function.md](../06-Built-In-Functions/Function.md) for how `ZSM_F_WORKING_DAYS` itself is implemented via AMDP/SQLScript.

## `GROUP BY` with a Composite Key

> 📌 **PARTIAL SNIPPET** — `SELECT` body only.

```abap
// Group By II
select from ZSM_T_001 {
    key vbeln,
    key posnr
}
group by vbeln, posnr
```

## `WHERE` Conditions (original note)

> 📌 **CONCEPTUAL SNIPPET — operator catalogue, not an activatable view.** This block deliberately collects every `WHERE` operator in one place. It references `ekko`, `likp`, `vbrk`, `vbap` and the fields `s_fiscyear`/`funcarea`, none of which are declared in the `FROM` clause shown, so it will not activate as written. Read it as a syntax reference; take the operators, not the statement.

```abap
// Where Condition
select from ZSM_T_001 {
    key vbeln,

    meins
}
where meins =  'ST'
  and auart <> 'Z113'
  and ersda =  $session.system_date
  and s_fiscyear = left( $session.system_date, 4 )
  and ( ekko.bsart like 'ZH%' or ekko.bsart like 'ZU%' )
  and not( likp.vbeln is null and vbrk.sfakn = '' )
   or vbap.matnr between '000000000000005000' and '000000000000006999'
   or vbrk.vbeln is null
   or funcarea is not initial
```

This example demonstrates the full range of `WHERE` operators: `=`, `<>`, `LIKE` (with `%` wildcard), `BETWEEN`, `IS NULL`/`IS NOT NULL`, `IS INITIAL`/`IS NOT INITIAL`, `NOT (...)`, parenthesized groups, and combining `AND`/`OR`.

> ⚠️ **Operator precedence trap:** `AND` binds tighter than `OR` in SQL/CDS, exactly like in most programming languages. In the snippet above, the conditions after the first `or` are **not** grouped with the earlier `AND` chain unless explicitly parenthesized — as written, this `WHERE` clause evaluates as `(meins = 'ST' AND auart <> 'Z113' AND ... AND NOT(...)) OR (vbap.matnr BETWEEN ...) OR (vbrk.vbeln IS NULL) OR (funcarea IS NOT INITIAL)`. If the intent was for *all* conditions to apply together, wrap the entire `OR` chain in its own parentheses, or restructure with explicit grouping. This is one of the most common real-world CDS bugs — always add parentheses when mixing `AND` and `OR` in the same `WHERE` clause, even when operator precedence would technically produce the intended result, purely for readability and to avoid future mistakes when the condition is edited.

## `HAVING`

> 📌 **PARTIAL SNIPPET** — the `HAVING` clause on its own; it follows the `GROUP BY` of an aggregating view.

```abap
// Having Sum
having sum(SNWD_SO.gross_amount) > 100000
```

`HAVING` filters **after** aggregation — use it to filter on aggregate results (like `SUM`, `COUNT`) where a plain `WHERE` (which filters rows *before* grouping) cannot be used.

## `WHERE` vs. `HAVING`

| | `WHERE` | `HAVING` |
|---|---|---|
| Applied | Before grouping/aggregation | After grouping/aggregation |
| Can reference aggregate functions | ❌ No | ✅ Yes |
| Typical use | Filtering individual rows | Filtering groups (e.g. "only groups where SUM > X") |

## Common Mistakes

- ❌ Mixing `AND`/`OR` without parentheses and assuming the "obvious" grouping — always parenthesize explicitly (see the warning above).
- ❌ Using `SELECT *` in views meant for long-term consumption.
- ❌ Trying to filter an aggregate value with `WHERE` instead of `HAVING`.
- ❌ Forgetting that every non-aggregated field in the SELECT list must appear in `GROUP BY`.

## Performance Considerations

- Filter as early as possible: conditions in `WHERE` (applied before aggregation) are typically cheaper than the equivalent logic pushed into `HAVING`.
- `COUNT(DISTINCT ...)` is more expensive than `COUNT(*)` — use it only when true distinct counting is required.
- Excessive `LIKE '%...%'` (leading wildcard) patterns prevent index usage and can force full table scans on large tables.

## SAP Best Practices

- Always parenthesize mixed `AND`/`OR` conditions, even when precedence would technically resolve correctly — future maintainers (including yourself) will thank you.
- Prefer an explicit field list over `SELECT *`.
- Use `HAVING` only for aggregate filtering; keep all row-level filtering in `WHERE`.

## Interview Notes

- **Q: What's the difference between `WHERE` and `HAVING`?**
  A: `WHERE` filters individual rows before grouping and cannot reference aggregate functions; `HAVING` filters groups after aggregation and can reference aggregates like `SUM`/`COUNT`.
- **Q: Why should `SELECT *` be avoided in CDS views?**
  A: It makes the view's structure implicitly dependent on the underlying table's current columns, so table changes can unexpectedly break or change consumers.

## Related Chapters

- [Report.md](Report.md) — displaying query results via ALV
- [05-Filtering-and-Parameters/Condition.md](../05-Filtering-and-Parameters/Condition.md) — `CASE` expressions in depth
- [03-Data-Modeling/Union.md](../03-Data-Modeling/Union.md) — `DISTINCT`-like de-duplication via `UNION`
