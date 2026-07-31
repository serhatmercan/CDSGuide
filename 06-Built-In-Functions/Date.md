# Date Functions

## What is it?

CDS provides built-in functions for date arithmetic and validation — adding/subtracting days or months, computing the number of days between two dates, validating a date, and converting date+time into a timestamp.

## Why is it used?

To perform date calculations (due dates, aging, validity checks) directly in the view, keeping business-date logic consistent and pushed down to the database.

## When should it be used?

Use these whenever a field is *derived* from one or more dates — due dates, day counts, calendar lookups. For actual **factory calendar / working day** logic (skipping weekends and holidays), see the table function example in [07-Query-and-Reporting/Query.md](../07-Query-and-Reporting/Query.md) and [Function.md](Function.md).

## Examples (original notes, with output annotated)

```abap
" Date Functions
BirthDate = '20241114' " YYYYMMDD

" Add & Subtract Days
" dats_add_days( date, days, timezone )
dats_add_days(BirthDate, 10,  null)    " => 2024-11-24
dats_add_days(BirthDate, -10, null)    " => 2024-11-04

" Add & Subtract Days w/ Projection
" dats_add_days( date, days, timezone, projection )
" --> projection.p_wadat = '20241114'
" --> projection.p_valtg = 10
" <-- DueDate = '20241124'
dats_add_days( $projection.p_wadat, cast( $projection.p_valtg as int4 ), 'INITIAL' ) as DueDate

" Add & Subtract Months
" dats_add_months( date, months, timezone )
dats_add_months(BirthDate, 2, null)    " => 2025-01-24
dats_add_months(BirthDate, -2, null)   " => 2024-09-24

" Calculate Between Days
" dats_days_between( date1, date2 )
dats_days_between(BirthDate, cast('20241104' as abap.dats)) " => -10
dats_days_between(BirthDate, cast('20241124' as abap.dats)) " => 10

dats_days_between(cast( $session.system_date as abap.dats ), TransactionCashFlow.PaymentDate) as abap.dec( 10, 2 )

" Check Date
" dats_is_valid( date )
dats_is_valid(BirthDate) " => 0: False || 1: True

" Convert Date & Time To Timestamp
" StartDate (DATS)              : 20250221
" StartTime (TIMS)              : 121500
" Timestamp (YYYYMMDDHHMMSS)    : 20250221121500
dats_tims_to_tstmp( StartDate,
                    StartTime,
                    abap_system_timezone( $session.client, 'NULL' ),
                    $session.client,
                    'NULL' ) as Timestamp
```

## Function Reference

| Function | Signature | Purpose |
|---|---|---|
| `dats_add_days(date, days, timezone)` | | Adds (or, with a negative value, subtracts) days from a date. |
| `dats_add_months(date, months, timezone)` | | Adds/subtracts whole months. |
| `dats_days_between(date1, date2)` | | Number of days between two dates (`date2 - date1`; negative if `date2` is earlier). |
| `dats_is_valid(date)` | | Returns `1` if the value is a valid calendar date, `0` otherwise. |
| `dats_tims_to_tstmp(date, time, source_tz, target_tz, ...)` | | Combines a date + time into a `TIMESTAMP` value, converting between time zones. |

> 📝 **`dats_is_valid` return value:** the CDS built-in actually returns an integer (`0`/`1`), not a boolean type — always compare it explicitly (`dats_is_valid(BirthDate) = 1`) rather than treating it as a native boolean, which is exactly the pattern used in [Time.md](Time.md) for `tims_is_valid`.

## Explaining the "Projection" Variant

```abap
dats_add_days( $projection.p_wadat, cast( $projection.p_valtg as int4 ), 'INITIAL' ) as DueDate
```

`$projection.p_wadat` (goods issue date) and `$projection.p_valtg` (validity/lead time in days) are both fields **already exposed by this same view** — `$projection` lets a calculated field reference other output fields of the view rather than the raw source table fields. The result is a computed `DueDate = p_wadat + p_valtg` days. Note the `cast(... as int4)` — `dats_add_days` expects an integer number of days, so a numeric-but-differently-typed field must be cast first (see [Conversion.md](Conversion.md)).

## Common Mistakes

- ❌ Passing a character string with an invalid date format directly into `dats_add_days`/`dats_days_between` without validating with `dats_is_valid` first — invalid input can cause runtime errors or unexpected results.
- ❌ Forgetting the sign convention: `dats_days_between(date1, date2)` is `date2 - date1`, so swapping the arguments flips the sign of the result.
- ❌ Treating `dats_is_valid()` as a native boolean instead of comparing it to `1`/`0` explicitly.

## Performance Considerations

- Date functions are lightweight and execute per row — no special performance concerns beyond the general "push logic to the database" principle.
- When combining several date functions in one expression (as in the day-of-week example in [Condition.md](../05-Filtering-and-Parameters/Condition.md)), keep an eye on readability rather than performance — the cost is negligible either way.

## SAP Best Practices

- Always validate external/raw date input with `dats_is_valid()` before using it in arithmetic, especially when the source is a character field rather than a proper `abap.dats`.
- Use `$session.system_date` (see [05-Filtering-and-Parameters/Session.md](../05-Filtering-and-Parameters/Session.md)) rather than hardcoding "today" logic.

## Interview Notes

- **Q: How do you calculate the number of days between two dates in a CDS view?**
  A: `dats_days_between(date1, date2)`.
- **Q: How would you safely add a variable number of lead-time days to a date field that might come in as a different numeric type?**
  A: Cast the lead-time field to `int4` first, then pass it into `dats_add_days(date, cast(days as int4), timezone)`.

## Related Chapters

- [Time.md](Time.md) — the equivalent functions for time-of-day values
- [Conversion.md](Conversion.md) — `cast()` and timestamp conversions
- [05-Filtering-and-Parameters/Condition.md](../05-Filtering-and-Parameters/Condition.md) — date functions combined with `CASE`
