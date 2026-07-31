# String Functions

## What is it?

CDS provides a set of built-in **string functions** for concatenation, trimming, padding, case conversion, searching, and substring extraction — evaluated directly in the database.

## Why is it used?

To manipulate text fields (formatting, combining, searching) without transferring rows to the application server first.

## When should it be used?

Use CDS string functions whenever the transformation can be expressed declaratively in the view — reserve ABAP-side string handling for logic that's genuinely program-specific or too complex for SQL.

## Examples (original notes, with output annotated)

```abap
" String Functions in ABAP
Name1 = 'Dilaray'.
Name2 = 'Serhat'.

" Concat: Concatenate Strings
concat(Name1, Name2)             " => DilaraySerhat

" Concat w/ Separator: Add Separator Between Strings
concat(concat(Name1, ',', Name2)) " => Dilaray,Serhat

" Concat w/ Space: Add Space Between Strings
concat_with_space(Name1, Name2, 1) " => Dilaray Serhat     | 1 Character Space
concat_with_space(Name1, Name2, 3) " => Dilaray   Serhat   | 3 Character Space

" Left & Right: Get Left & Right Part of String
left(Name1, 2)   " => Di
right(Name1, 2)  " => ay

" Left & Right: Ex
left outer join /sapsll/maritc as Maritc on Maritc.matnr           = _Sip.matnr
                                        and left(Maritc.ccngn, 17) = I_ProductPlant.Commodity

" Lpad & Rpad: Add Character to Left & Right
lpad(Name1, 10, '0') " => 0000Dilaray
rpad(Name2, 10, '0') " => Serhat0000

" Lowercase & Uppercase: Convert to Lower & Upper
lowercase(Name2) " => serhat
uppercase(Name1) " => DILARAY

" Instr: Find Position of Character
instr(Name1, 'a')   " => 4
instr(Name1, 'z')   " => 0
instr(Name2, 'rh')  " => 3

" Length: Find Length of String
length(Name1) " => 7

" Ltrim & Rtrim: Delete Left & Right Matched Character
ltrim(Name1, 'D') " => ilaray
rtrim(Name2, 't') " => Serha

" Replace: Replace Character in String
replace(Name1, 'a', 'o')                " => Diloroy
replace(Name1, 'Dilaray','Mır Mır' )    " => Mır Mır

" Substring: Get Substring of String
substring(Name1, 2, 3) " => ila
```

> 📝 **`concat(concat(Name1, ',', Name2))`** in the original note has an inner call with three arguments — but `concat()` in CDS takes exactly **two** arguments. What actually produces `'Dilaray,Serhat'` is a nested call: `concat(concat(Name1, ','), Name2)`, i.e. first append the separator to `Name1`, then append `Name2` to that result. Keep this in mind: unlike ABAP's `CONCATENATE ... SEPARATED BY`, CDS `concat()` is strictly binary and must be nested for more than two parts, or you can use `concat_with_space` when the separator is a space.

## Function Reference

| Function | Signature | Purpose |
|---|---|---|
| `concat(a, b)` | 2 args | Concatenates two strings. |
| `concat_with_space(a, b, n)` | 3 args | Concatenates `a` and `b` with `n` spaces in between. |
| `left(str, n)` / `right(str, n)` | | First/last `n` characters. |
| `lpad(str, len, char)` / `rpad(str, len, char)` | | Pads `str` on the left/right with `char` until it reaches `len` characters. |
| `lowercase(str)` / `uppercase(str)` | | Case conversion. |
| `instr(str, substr)` | | 1-based position of the first occurrence of `substr` in `str`; `0` if not found. |
| `length(str)` | | Character length of `str`. |
| `ltrim(str, char)` / `rtrim(str, char)` | | Removes leading/trailing occurrences of `char`. |
| `replace(str, from, to)` | | Replaces all occurrences of `from` with `to`. |
| `substring(str, pos, len)` | | Extracts `len` characters starting at 1-based position `pos`. |

## Real Business Example — Building a Commodity Code Match

```abap
left outer join /sapsll/maritc as Maritc
  on  Maritc.matnr           = _Sip.matnr
  and left(Maritc.ccngn, 17) = I_ProductPlant.Commodity
```

Here `left()` truncates a longer commodity code (`ccngn`) down to the first 17 characters so it can be compared against a shorter commodity code field — a real pattern from foreign trade / GTS integration, where code lengths differ between systems.

## Common Mistakes

- ❌ Assuming `concat()` accepts more than two arguments (see the note above) — nest calls or use `concat_with_space` instead.
- ❌ Using `instr()` and treating a `0` result as "found at the start" — `0` means **not found**; CDS string positions are 1-based.
- ❌ Chaining many string functions in the field list instead of considering whether a cleaner data model (e.g. a real join key) would avoid needing string manipulation at all.

## Performance Considerations

- String functions execute per row in the database — generally cheap, but heavy use of `replace`/`instr` on very wide tables can still add up; check `ST05` if a view feels unexpectedly slow.
- Prefer `left(str, n)` over `substring(str, 1, n)` when extracting from the start — functionally equivalent, but `left`/`right` communicate intent more clearly.

## SAP Best Practices

- Use string functions for **presentation/matching** logic, not as a substitute for properly normalized keys.
- Favor `concat_with_space` over manual `concat(concat(a, ' '), b)` chains when a literal space separator is all that's needed — it's shorter and clearer.

## Interview Notes

- **Q: How many arguments does `concat()` take in CDS?**
  A: Exactly two — for more parts, nest additional `concat()` calls.
- **Q: What does `instr()` return when the substring is not found?**
  A: `0`.

## Related Chapters

- [Math.md](Math.md) — numeric built-in functions
- [Conversion.md](Conversion.md) — `cast()` and type conversion, often paired with string functions
