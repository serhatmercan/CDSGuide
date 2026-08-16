# Math Functions

## What is it?

CDS provides built-in arithmetic and aggregate functions — absolute value, rounding, ceiling/floor, division variants, modulo, min/max — evaluated directly in the database.

## Why is it used?

To perform numeric transformations and aggregations without pulling raw data into ABAP first — especially valuable for reports/analytics summing large data sets.

## When should it be used?

Use CDS math functions for straightforward numeric transformations and aggregations. For business logic that depends on many additional factors (multi-step calculations, external configuration), consider a [virtual element / exit class](../10-Examples/Class.md) instead.

## Examples (original notes, with output annotated)

```abap
// Math Operations in CDS
// Assume: Amount = 17.856

// Abs: Absolute Value
abs(Amount) as AmountABS    // => 17.856

// Add & Subtract & Multiply
Amount + 10                 // => 27.856
Amount - 10                 // => 7.856
Amount * 10                 // => 178.560

// Ceil: Smallest Integer Not Less Than the Argument
ceil(Amount)                // => 18

// Div: Integer Division
div(Amount, 5)              // => 3

// Division: Division w/ Decimal Places
// --> 17.856 / 3 = 5.952, rounded to 2 decimal places
// <-- 5.95
division(Amount, 3, 2) as AmountDiv

// Floor: Largest Integer Not Greater Than the Argument
// --> 17.856
// <-- 17
floor(Amount) as AmountFloor

// Max: Find Maximum
max( Begda ) as BeginDate

// Min: Find Minimum
min( endda ) as EndDate
min( case when o.Lictp = 'Z001' then v.Oidatto1 end ) as MinDate

// Mod: Returns the Remainder of a Number
mod(ceil(Amount), 5) as Remainder // => 3

// Numeric Value (String -> Numeric)
// --> '00015'   || '99.75'
// <-- 15        || 99.75
get_numeric_value(Pricing.ConditionQuantity)

// Round: Rounded To The Given Number of Decimal Places
round(Amount, 1) // => 17.9
round(Amount, 2) // => 17.86
```

## Function Reference

| Function | Purpose |
|---|---|
| `abs(n)` | Absolute value. |
| `ceil(n)` | Smallest **integer** that is not less than `n` (rounds up to a whole number). Single argument. |
| `floor(n)` | Largest **integer** that is not greater than `n` (rounds down to a whole number). Single argument. |
| `round(n, decimals)` | Rounds to the nearest value at the given number of decimal places. This is the function that takes a decimal-place argument. |
| `div(a, b)` | Integer division (drops the remainder). |
| `division(a, b, decimals)` | Decimal division, result rounded to the given number of decimal places. |
| `mod(a, b)` | Remainder of `a` divided by `b`. |
| `min(expr)` / `max(expr)` | Aggregate minimum/maximum — usable with `GROUP BY` (see [07-Query-and-Reporting/Query.md](../07-Query-and-Reporting/Query.md)) or standalone over a `CASE` expression. |
| `get_numeric_value(str)` | Extracts the numeric value from a character field (e.g. a padded/formatted quantity). |

> 📝 **`ceil` and `floor` take exactly one argument.** They return an integer — `ceil(17.856)` is `18`, `floor(17.856)` is `17`. There is no decimal-place parameter; if you need rounding to a given number of decimals, that is `round(n, decimals)`. The original notes wrote these as `ceil(Amount, 1)` / `floor(Amount, 1)`, which does not compile.

## Real Business Example — Aggregated Min/Max with a Condition

```abap
min( case when o.Lictp = 'Z001' then v.Oidatto1 end ) as MinDate
```

Combines an aggregate function (`min`) with a [`CASE`](../05-Filtering-and-Parameters/Condition.md) expression: only rows where `Lictp = 'Z001'` contribute a value to the `min()`, everything else evaluates to `NULL` and is ignored by the aggregate — a common pattern for "minimum date, but only among a specific subset of rows."

## Common Mistakes

- ❌ Confusing `div()` (integer division) with `division()` (decimal division with a specified precision) — using the wrong one silently truncates results.
- ❌ Passing a second argument to `ceil()`/`floor()` — they take one argument and return an integer. Only `round(n, decimals)` and `division(a, b, decimals)` accept a decimal-place argument.
- ❌ Using `min()`/`max()` without a `GROUP BY` when a per-group result was intended — without grouping, they aggregate over the *entire* result set.

## Performance Considerations

- Aggregate functions (`min`, `max`, `sum`, `avg`, `count`) are pushed down to the database and are typically far more efficient than fetching detail rows and aggregating in ABAP.
- Wrapping fields in multiple nested math functions (as in `mod(ceil(Amount), 5)`) is fine for correctness but makes the generated SQL harder to read/debug — comment non-obvious formulas.

## SAP Best Practices

- Prefer CDS aggregate functions over ABAP-side `LOOP ... AT` summation whenever possible — this is a core "code-to-data" performance principle.
- Reach for `round(n, decimals)` when you need decimal-place rounding, and `ceil(n)`/`floor(n)` only when you genuinely want a whole number — mixing them up silently changes the scale of a result.

## Interview Notes

- **Q: What is the difference between `div()` and `division()`?**
  A: `div()` performs integer division (whole number result, no rounding); `division()` performs decimal division with an explicit number of decimal places.
- **Q: How would you get the minimum date among only a subset of rows using a single aggregate expression?**
  A: Wrap the field in a `CASE WHEN <condition> THEN <field> END` inside the `MIN()`/`MAX()` call, so only matching rows contribute.

## Related Chapters

- [05-Filtering-and-Parameters/Condition.md](../05-Filtering-and-Parameters/Condition.md) — `CASE` expressions combined with aggregates
- [07-Query-and-Reporting/Query.md](../07-Query-and-Reporting/Query.md) — `GROUP BY`/`HAVING` with aggregate functions
- [Conversion.md](Conversion.md) — decimal/currency type casting
