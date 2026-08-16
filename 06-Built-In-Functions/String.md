# String Functions

## What is it?

CDS provides a set of built-in **string functions** for concatenation, trimming, padding, case conversion, searching, and substring extraction — evaluated directly in the database.

## Why is it used?

To manipulate text fields (formatting, combining, searching) without transferring rows to the application server first.

## When should it be used?

Use CDS string functions whenever the transformation can be expressed declaratively in the view — reserve ABAP-side string handling for logic that's genuinely program-specific or too complex for SQL.

## Examples (original notes, with output annotated)

```abap
// String Functions in CDS
// Assume: Text1 = 'Example'  (7 characters)
//         Text2 = 'Sample'   (6 characters)

// Concat: Concatenate Strings
concat(Text1, Text2)               // => ExampleSample

// Concat w/ Separator: Add Separator Between Strings
concat(concat(Text1, ','), Text2)  // => Example,Sample

// Concat w/ Space: Add Space Between Strings
concat_with_space(Text1, Text2, 1) // => Example Sample     | 1 Character Space
concat_with_space(Text1, Text2, 3) // => Example   Sample   | 3 Character Space

// Left & Right: Get Left & Right Part of String
left(Text1, 2)   // => Ex
right(Text1, 2)  // => le

// Left & Right: Ex
left outer join /sapsll/maritc as Maritc on Maritc.matnr           = _Item.matnr
                                        and left(Maritc.ccngn, 17) = I_ProductPlant.Commodity

// Lpad & Rpad: Pad to a Total Length With a Character
lpad(Text1, 10, '0') // => 000Example  | padded from 7 to 10 characters
rpad(Text2, 10, '0') // => Sample0000  | padded from 6 to 10 characters

// Lowercase & Uppercase: Convert to Lower & Upper
lowercase(Text2) // => sample
uppercase(Text1) // => EXAMPLE

// Instr: Find Position of Character
instr(Text1, 'a')   // => 3
instr(Text1, 'z')   // => 0
instr(Text2, 'mp')  // => 3

// Length: Find Length of String
length(Text1) // => 7

// Ltrim & Rtrim: Delete Left & Right Matched Character
ltrim(Text1, 'E') // => xample
rtrim(Text2, 'e') // => Sampl

// Replace: Replace Character in String
replace(Text1, 'a', 'o')                 // => Exomple
replace(Text1, 'Example', 'SampleText')  // => SampleText

// Substring: Get Substring of String
substring(Text1, 2, 3) // => xam
```

> 📝 **`concat()` takes exactly two arguments.** The original note wrote the separator example as `concat(concat(Text1, ',', Text2))` — an inner call with three arguments, which does not compile. The corrected form above nests the calls: `concat(concat(Text1, ','), Text2)`, i.e. first append the separator to `Text1`, then append `Text2` to that result. Unlike ABAP's `CONCATENATE ... SEPARATED BY`, CDS `concat()` is strictly binary and must be nested for more than two parts; use `concat_with_space` when the separator is a space.

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
  on  Maritc.matnr           = _Item.matnr
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
- Remember `lpad`/`rpad` take a **total target length**, not a number of padding characters — `lpad('Example', 10, '0')` yields `000Example`, not ten zeros followed by the text.

## Interview Notes

- **Q: How many arguments does `concat()` take in CDS?**
  A: Exactly two — for more parts, nest additional `concat()` calls.
- **Q: What does `instr()` return when the substring is not found?**
  A: `0`.

## Related Chapters

- [Math.md](Math.md) — numeric built-in functions
- [Conversion.md](Conversion.md) — `cast()` and type conversion, often paired with string functions
