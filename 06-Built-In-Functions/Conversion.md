# Conversion Functions — `CAST`, Currency & Unit Conversion

## What is it?

CDS provides:
1. `cast(expr as type)` — explicit type conversion between ABAP Dictionary data types.
2. `currency_conversion(...)` and `unit_conversion(...)` — built-in business functions that convert amounts/quantities using SAP's standard exchange-rate and unit-of-measure master data.
3. Timestamp-related conversion functions bridging `DATS`/`TIMS`/`TIMESTAMP`.

## Why is it used?

- To make a field's type match what a consumer (OData, RAP, another view) expects.
- To perform **currency and unit conversion** using centrally maintained exchange rates / conversion factors, instead of reimplementing that logic per view.

## When should it be used?

Use `cast()` whenever a literal, calculated, or source field's type doesn't already match the target type needed by the view's element list or a function argument. Use `currency_conversion`/`unit_conversion` whenever a field must be presented in a different currency/unit than it's stored in (e.g. converting to a company's reporting currency, or km to miles).

## `CAST` Reference (original notes, annotated)

```abap
// Conversion Functions
// Assume: Amount = '28.1907'

// Case
cast(
    case mara.meins
         when 'ST' then 'X'
         else ''
    end as xfeld preserving type ) as Unit

// Character (CHAR)
// --> 28.1907
// <-- 28.1907             (20 Characters)
cast(Amount as abap.char( 20 )) as AmountChar

// Currency Amount (CURR)
cast(Wrbtr as abap.curr( 20, 3 )) as DocumentAmount

// Date - I (YYYYMMDD -> YYYY-MM-DD)
// --> 00000000
// <-- 0000-00-00
cast( '00000000' as abap.dats) as Date

// Date - II (YYYYMMDD -> YYYY-MM-DD)
// --> 20250221
// <-- 2025-02-21
cast( '20241114' as abap.dats ) as Date

// Decimal - I (DEC)
// --> 28.1907
// <-- 28.19
cast(Amount as abap.dec( 10, 2 )) as AmountDec

// Decimal - II (DEC)
// --> 1000
// <-- 1
cast( cast( mmh.mcount as abap.dec(16,3) ) / 1000 as abap.dec(16,3) ) as TotalHeight

// Decimal - III (DEC)
// --> 0.25
// <-- 0.25
0.25 as DecimalValue

// Decimal - IV (DEC)
// --> '99.75'
// <-- 99
cast(get_numeric_value(Pricing.ConditionQuantity) as abap.dec(5,0)) as ConditionQuantity

// Decimal - Float
// --> 12345.678
// <-- 1.2345678E+4
cast( nsum.ScheduledQuantity as abap.decfloat34 ) as ScheduledQuantity

// Default Type (Default)
// -->                              1000000017
// <-- 1000000017
cast( '1000000017' as abap.default ) as MatNumd // => CHAR 40 : '1000000017'

// Floating Point Number (FLTP)
cast( 0 as abap.fltp ) as KDV

// Floating Point Number (FLTP) -> Decimal (DEC)
// --> 23.456789
// <-- 23.457
fltp_to_dec( diptemp.par_fltp as abap.dec( 13, 3 ) ) as Temperature

// Integer (INT2)
cast(0 as abap.int2) as IntValue

// Numeric (NUMC)
// --> YYYYMMDD: 20250213
// <-- YYYYMM  : 202502
cast(substring(vbep.edatu, 1, 6) as abap.numc(6)) as Endmn

// Standard Type (STANDARD)
// --> '1000000028'
// <-- '0000000000000000000000000000001000000028' (CHAR40)
cast('1000000028' as matnr) as MatnrEx

// Quantity (QUAN)
// --> 9876543.21
// <-- 9876543.210
cast( 0 as abap.quan( 13, 3 )) as Quantity
```

### Explanation

| Cast target | Meaning |
|---|---|
| `abap.char(n)` | Fixed-length character string of `n` characters. |
| `abap.curr(len, decimals)` | Currency amount field with `len` total digits and `decimals` decimal places. |
| `abap.dats` | Date (`YYYYMMDD` internally, displayed as `YYYY-MM-DD`). |
| `abap.dec(len, decimals)` | Packed decimal number. |
| `abap.decfloat34` | Decimal floating point (34 significant digits) — used for scientific/very precise values. |
| `abap.default` | Uses the referenced data element's own domain-defined type/length (here, `matnr`'s underlying type, `CHAR 40`). |
| `abap.fltp` | Binary floating point. |
| `abap.int2` / `int4` | Integer types of different sizes. |
| `abap.numc(n)` | Numeric-only character field of `n` digits, typically zero-padded. |
| `abap.quan(len, decimals)` | Quantity field. |
| `preserving type` | Used with `cast(... as <domain type> preserving type)` to keep the semantic/business type of the source expression rather than switching to the raw target type — mostly relevant for indicator/flag domains like `xfeld`. |

> 📝 **`cast('1000000028' as matnr)`** casts to the **data element** `matnr`, not a generic ABAP built-in type — the result inherits `matnr`'s technical type (`CHAR 40`, zero-padded), which is why the note shows the value left-padded with zeros. This is different from casting to `abap.char(40)`, which would *not* zero-pad a numeric-looking string.

## Currency Conversion

```abap
// Currency Conversion
// Table: T0001
// --> Budat: 20250220
// --> Waers: EUR
// --> Wrbtr: 100
// --- Exchange Rate: 1.10
// <-- DocumentAmount: 110
@Semantics.amount.currencyCode: 'DocumentCurrency'
sum( currency_conversion( amount                => T0001.Wrbtr,
                          exchange_rate_date    => T0001.Budat,
                          round                 => 'X',
                          source_currency       => T0001.Waers,
                          target_currency       => $projection.DocumentCurrency,
                          error_handling        => 'SET_TO_NULL' ) )                as DocumentAmount,
cast('USD' as abap.cuky( 5 ))                                                       as DocumentCurrency
```

`currency_conversion()` is a built-in that looks up the exchange rate (from the standard `TCURR` tables) valid on `exchange_rate_date` and converts `amount` from `source_currency` to `target_currency`. Key parameters:

| Parameter | Meaning |
|---|---|
| `amount` | The value to convert. |
| `exchange_rate_date` | The date used to look up the applicable exchange rate. |
| `source_currency` / `target_currency` | The "from" and "to" currency keys. |
| `round` | Whether to round the result (`'X'`) per the target currency's decimal places. |
| `error_handling` | What to do if no exchange rate is found: e.g. `'SET_TO_NULL'` (return `NULL`) vs. raising an error. |

> 💡 Always mark the resulting amount field with `@Semantics.amount.currencyCode` referencing the field that holds its currency (here `DocumentCurrency`) — this is what lets Fiori Elements/OData display the amount correctly formatted with its currency symbol/decimals (see [04-CDS-Annotations/Annotation-Local.md](../04-CDS-Annotations/Annotation-Local.md)).

## Unit Conversion

```abap
// Unit
// --> Distance: 100
// --> DistanceUnit: 'KM'
// --> TargetUnit: 'MI or cast( 'MI' as abap.unit )
// <-- 62.1371
unit_conversion( quantity    => Distance,
                 source_unit => DistanceUnit,
                 target_unit => TargetUnit ) as DistanceMI
```

`unit_conversion()` works analogously to `currency_conversion()`, but uses the standard unit-of-measure conversion tables (`T006`) instead of exchange rates.

## Timestamp Conversions

```abap
// Date & Time To Timestamp (DATS & TIMS -> YYYYMMDDHHMMSS)
// --> StartDate: 20250221 & StartTime: 121500
// <-- Timestamp: 20250221121500
dats_tims_to_tstmp( StartDate,
                    StartTime,
                    abap_system_timezone( $session.client, 'NULL' ),
                    $session.client,
                    'NULL' ) as Timestamp

// Timestamp (TIMESTAMP)
// --> 2025-02-21 14:50:45.123
// <-- 20250221145045.123
cast ( dip.etmstm as timestamp ) as ItemTime

// Timestamp Current (UTC)
// --> 2025-02-21 14:50:45.123 UTC
// <-- 20250221145045.123
tstmp_current_utctimestamp() as CurrentTime

// Timestamp to Date (YYYYMMDDHHMMSS -> YYYYMMDD)
// --> 20240212083000 (2024-02-12 08:30:00)
// <-- 20240212       (12 February 2024)
tstmp_to_dats( cast( dip.etmstm as abap.dec( 15, 0 )),
                     abap_system_timezone( $session.client, 'NULL' ),
                     $session.client,
                     'NULL' ) as StartDate

// Timestamp to Time (YYYYMMDDHHMMSS -> HHMMSS)
// --> 20250217153000    (2025-02-17 15:30:00)
// <-- 153000            (15:30:00)
tstmp_to_tims( cast(ftmstm as abap.dec( 15, 0 )),
                    abap_system_timezone( $session.client,'NULL' ),
                    $session.client, 'NULL' ) as StartTime
```

| Function | Purpose |
|---|---|
| `dats_tims_to_tstmp(date, time, source_tz, client, mode)` | Combines a date + time into a UTC-based `TIMESTAMP`, converting from the given time zone. |
| `tstmp_current_utctimestamp()` | Returns the current UTC timestamp. |
| `tstmp_to_dats(timestamp, target_tz, client, mode)` | Extracts the date portion of a timestamp, converted into the target time zone. |
| `tstmp_to_tims(timestamp, target_tz, client, mode)` | Extracts the time portion of a timestamp, converted into the target time zone. |
| `abap_system_timezone(client, mode)` | Looks up the system time zone configured for the given client. |
| `fltp_to_dec(fltp_value as target_type)` | Converts a floating-point value to a decimal type with explicit precision. |

## Common Mistakes

- ❌ Forgetting `@Semantics.amount.currencyCode` / `@Semantics.quantity.unitOfMeasure` on converted fields — Fiori/OData won't know how to format them (see [04-CDS-Annotations/Annotation-Local.md](../04-CDS-Annotations/Annotation-Local.md)).
- ❌ Ignoring `error_handling` in `currency_conversion()` — if no exchange rate exists for a given date/currency pair and this isn't handled deliberately, the query can fail or silently return `NULL` depending on the setting.
- ❌ Casting to `abap.char(n)` when a domain-specific type (`abap.default`, or a data element like `matnr`) would preserve important formatting (e.g. leading zeros).
- ❌ Confusing `abap.dec` (packed decimal) with `abap.decfloat34` (decimal floating point) — they have different precision/rounding behavior for very large or very precise values.

## Performance Considerations

- `currency_conversion()`/`unit_conversion()` perform a rate/factor lookup per row (or per aggregated group, if wrapped in `SUM`) — for very large result sets, consider whether conversion can be deferred to a smaller, already-aggregated result.
- Excessive nested `cast()` calls (as in the `Decimal - II` example) are fine functionally but can make the compiled SQL harder to optimize/read — simplify where possible.

## SAP Best Practices

- Always pair currency/quantity conversion functions with the matching `@Semantics` annotation on the result field.
- Use `error_handling => 'SET_TO_NULL'` (or the appropriate mode for your scenario) deliberately, rather than relying on the default — think through what should happen when a rate is missing.
- Prefer the data element's own type (`abap.default`, or casting straight to a data element like `matnr`) over generic `abap.char`/`abap.numc` when the goal is to match an existing DDIC field's formatting exactly.

## Interview Notes

- **Q: How does `currency_conversion()` know which exchange rate to use?**
  A: It looks up the applicable rate from the standard currency exchange rate tables (`TCURR`) based on the `exchange_rate_date` and the source/target currency pair.
- **Q: What's the difference between `abap.dec` and `abap.decfloat34`?**
  A: `abap.dec` is a packed decimal with a fixed number of total digits/decimals; `abap.decfloat34` is a decimal floating-point type with 34 significant digits, better suited for very large or very precise values without fixed-scale rounding.

## Related Chapters

- [Math.md](Math.md) — arithmetic functions often combined with casts
- [04-CDS-Annotations/Annotation-Local.md](../04-CDS-Annotations/Annotation-Local.md) — `@Semantics.amount.currencyCode` / `@Semantics.quantity.unitOfMeasure`
- [Function.md](Function.md) — table functions and AMDP, another way to encapsulate complex conversions
