# Conditions — `CASE` Expressions

## What is it?

`CASE` is CDS's conditional expression, equivalent to SQL `CASE WHEN` — it evaluates conditions in order and returns a value for the first one that's true (with an optional `ELSE` fallback).

## Why is it used?

- To derive a new field from one or more existing fields based on business rules (status text, categorization, sign flipping).
- To push conditional/branching logic down to the database instead of post-processing in ABAP.

## When should it be used?

Use `CASE` whenever a field's value depends on a condition more complex than a simple null-check (for null-checks, prefer `COALESCE` — see [03-Data-Modeling/Join.md](../03-Data-Modeling/Join.md)).

## Two Forms of `CASE`

| Form | Syntax | When to use |
|---|---|---|
| **Simple CASE** | `case <expr> when <value> then ... end` | Comparing one expression against a list of discrete values. |
| **Searched CASE** | `case when <condition> then ... end` | Arbitrary boolean conditions (ranges, combined conditions). |

## Examples (original notes)

> 📌 The examples in this section are **partial snippets** — single `CASE` expressions as they would appear inside a view's element list. Wrap them in a `define view` / `define view entity` with a matching `FROM` clause to use them.

### Simple CASE — Day of the Week

```abap
// Case w/ Date + Mod: Get the Day of the Week for a Given Date
// Note: The 'dats_days_between' Function is used to Calculate the Number of Days Between Two Dates
case mod( dats_days_between( cast( '20250101' as abap.dats ), $projection.due_date ), 7 )
    when 0 then 'Monday'
    when 1 then 'Tuesday'
    when 2 then 'Wednesday'
    when 3 then 'Thursday'
    when 4 then 'Friday'
    when 5 then 'Saturday'
    when 6 then 'Sunday'
end as DayOfWeek
```

This combines a **simple CASE** with the [Date](../06-Built-In-Functions/Date.md) function `dats_days_between` and the [Math](../06-Built-In-Functions/Math.md) function `mod`: it computes the number of days since a known Monday (`2025-01-01`), takes the remainder modulo 7, and maps the remainder to a weekday name.

> 📝 This only works correctly if the reference date (`'20250101'`) is verified to actually be a Monday for the calendar in use — otherwise every mapped day is shifted. Double check the reference date whenever reusing this pattern.

### Simple CASE — Sign Flipping by Indicator

```abap
// Case w/ Indicator: Get the Indicator Value
case matdoc.shkzg
   when 'H' then - matdoc.menge
   when 'S' then + matdoc.menge
end as Quantity
```

A very common MM/FI pattern: `shkzg` ("debit/credit indicator") is `H` (Haben/Credit) or `S` (Soll/Debit); the quantity is negated for one and kept positive for the other so that summing `Quantity` gives a correct net movement.

> ⚠️ Without an `else` branch, any other value of `shkzg` produces `NULL` for `Quantity` — acceptable here since `H`/`S` are the only valid values in the domain, but worth being deliberate about.

### Simple CASE — Unit of Measure Flag

```abap
// Case w/ String: Get the Unit of Measure
case mara.meins
    when 'ST' then 'X'
    else ''
end as UOM
```

A simple two-way flag: `'X'` if the base unit is "piece" (`ST`), blank otherwise.

### Searched CASE — Nested Status Logic

```abap
// Condition: Case
select from ZSM_T_001{
    key vbeln                                   as Vbeln,
    case when T1.menge is null then T1.zzmenge
         else T1.menge
     end                                        as Menge,
    case BillingStatus
         when 'P' then 'Paid'
         when ' ' then
            case DeliveryStatus
                when 'D' then 'Delivered'
                when ' ' then 'Open'
                else DeliveryStatus
            end
         else BillingStatus
     end                                        as Status
}
```

`CASE` expressions can be **nested** — here, when `BillingStatus` is blank, a second `CASE` inspects `DeliveryStatus` to derive a more specific status text. This mirrors how classic ABAP nested `IF`/`CASE` logic is expressed declaratively in CDS.

## Common Mistakes

- ❌ Omitting `ELSE` when a fallback value is actually needed — an unmatched row silently becomes `NULL`, which can break downstream `NOT NULL` assumptions or UI rendering.
- ❌ Deeply nesting `CASE` expressions until they become unreadable — consider whether the logic belongs in a database view at all, or would be clearer as a value-mapping table joined in, or a virtual element (see [04-CDS-Annotations/Annotation-Local.md](../04-CDS-Annotations/Annotation-Local.md)).
- ❌ Using `CASE ... IS NULL ... ELSE ...` for a plain fallback where `COALESCE` would be shorter and clearer (see [03-Data-Modeling/Join.md](../03-Data-Modeling/Join.md)).

## Performance Considerations

- `CASE` expressions execute per row on the database — cheap compared to fetching the data first and branching in ABAP, but avoid extremely long `WHEN` chains on very large tables; consider a lookup/mapping table with a join instead if the list grows beyond a handful of values.

## SAP Best Practices

- Prefer **searched CASE** for range/boolean conditions, **simple CASE** for discrete value mapping — pick whichever reads more naturally for the specific comparison.
- Always consider whether an `ELSE` is needed, even if only to explicitly return a sentinel value (e.g. `''` or `'UNKNOWN'`) instead of `NULL`.

## Interview Notes

- **Q: What's the difference between simple and searched `CASE`?**
  A: Simple `CASE` compares one expression against a list of discrete values (`case x when 1 then ...`); searched `CASE` evaluates independent boolean conditions (`case when x > 10 then ...`).
- **Q: What happens if no `WHEN` matches and there's no `ELSE`?**
  A: The expression evaluates to `NULL`.

## Related Chapters

- [Parameters.md](Parameters.md) — parameters often used inside `CASE`/`WHERE` conditions
- [03-Data-Modeling/Join.md](../03-Data-Modeling/Join.md) — `COALESCE` as a shorthand for the simplest `CASE` pattern
- [07-Query-and-Reporting/Query.md](../07-Query-and-Reporting/Query.md) — `CASE`/`COALESCE` used alongside `WHERE`, `GROUP BY`, and aggregation
