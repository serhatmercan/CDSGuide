# Time Functions

## What is it?

CDS provides built-in functions to validate and convert time-of-day (`TIMS`) values, complementing the date functions in [Date.md](Date.md).

## Why is it used?

To safely validate and normalize time values coming from potentially inconsistent source data (e.g. `999999` used as a sentinel/placeholder rather than a real time).

## When should it be used?

Use `tims_is_valid` whenever a time field's input cannot be trusted to always be a genuine `HHMMSS` value, before performing further time arithmetic or display formatting.

## Examples (original notes, with output annotated)

```abap
// Validation: Return => (0 = Invalid || 1 = Valid)
tims_is_valid( Main.DocumentTime ) = 1

// Validation & Conversion
// --> '123456' || '999999' || NULL
// <--  123456  ||  000000  || 000000
case when tims_is_valid( Main.DocumentTime ) = 1 then tims_to_timn( Main.DocumentTime, 'NULL' )
                                                 else tims_to_timn( cast( '000000' as abap.tims ), 'NULL' )
end as ConvertedDocumentTime
```

## Function Reference

| Function | Purpose |
|---|---|
| `tims_is_valid(time)` | Returns `1` if the value is a genuine, valid time (`000000`–`235959`), `0` otherwise (e.g. `999999` sentinel values, malformed input). |
| `tims_to_timn(time, on_error)` | Converts a value in the ABAP `TIMS` representation to the HANA `TIME` representation associated with the DDIC type `TIMN`. The second argument is `on_error`, controlling what happens when the input is not a valid time. |

> 📝 **`tims_to_timn` is a type conversion, not a formatter.** It moves a value from the ABAP `TIMS` representation (a six-character `HHMMSS` field) to the `TIMN` representation used by HANA's native `TIME` type. Its second parameter is `on_error` — the same error-handling concept used by the date functions in [Date.md](Date.md) — not a display mode.

## Explaining the Pattern

The combined `CASE` + `tims_is_valid` pattern is a defensive-programming idiom: rather than letting an invalid sentinel time (`999999`, often used in legacy interfaces to mean "no time recorded") flow downstream and break formatting or comparisons, the view explicitly checks validity first and substitutes a safe default (`000000`) when the source value isn't a real time.

```abap
case when tims_is_valid( Main.DocumentTime ) = 1
     then tims_to_timn( Main.DocumentTime, 'NULL' )
     else tims_to_timn( cast( '000000' as abap.tims ), 'NULL' )
end as ConvertedDocumentTime
```

## Common Mistakes

- ❌ Feeding a raw, unvalidated `TIMS` field straight into time arithmetic or display logic — if the source system uses `999999`/other sentinels for "unknown," downstream calculations can silently produce nonsense.
- ❌ Treating `tims_is_valid()` as returning a native boolean rather than the integer `0`/`1` it actually returns.

## Performance Considerations

- Time validation/conversion functions are lightweight, row-level operations — no meaningful performance concern beyond normal `CASE` evaluation cost.

## SAP Best Practices

- Always validate time fields coming from legacy/interface tables with `tims_is_valid()` before using them, exactly as with `dats_is_valid()` for dates (see [Date.md](Date.md)).
- Keep the "invalid → default" substitution logic consistent across views that read the same source field, so the same input always normalizes to the same output.

## Interview Notes

- **Q: Why would a CDS view need to validate a time field before using it?**
  A: Legacy or interface data sometimes stores sentinel values (like `999999`) instead of a real time to indicate "not recorded" — using them directly in time arithmetic can produce invalid or misleading results, so `tims_is_valid()` is checked first.

## Related Chapters

- [Date.md](Date.md) — the equivalent date validation/conversion functions
- [Conversion.md](Conversion.md) — timestamp construction from date + time (`dats_tims_to_tstmp`)
