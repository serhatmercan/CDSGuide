# CLAUDE.md — CDSGuide

Coding rules: docs/CDS-Development-Rules.md (planned; until it exists, follow the existing chapters).

## Purpose and scope
- Practical ABAP CDS reference covering both generations: classic
  DDIC-based `define view` and modern `define view entity`. Keep classic
  examples; do not rewrite them into view-entity syntax for style.
- Classic CDS is reference knowledge; view entities and service
  definition/binding are the recommended approach for new development.
  "Classic vs Modern CDS" (02-CDS-Basics) is the boundary map; update it
  when a classification changes.
- Out of scope: RAP behavior definitions/implementations, draft, managed
  vs unmanaged, and an "available in ABAP Cloud" matrix. Mention RAP only
  as the consumer of the CDS model.
- ABAP-side topics (ABAP SQL, classes, ALV, reports) are not explained
  here; link to ABAPGuide (https://github.com/serhatmercan/ABAPGuide).
- Release numbers appear only as in the root README "Compatibility &
  Version Notes" table; everything else release-sensitive is labelled.
- Original notes are preserved. Fix errors in place and flag them with a
  `> ⚠️ **Corrected from the original note.**` callout; do not drop them.

## Structure
- Chapter folder `NN-Title-Words/` holding one or more `Topic-Name.md`
  files; `Appendix/` is unnumbered. New files get a row in the root README
  "Chapter Reference" table, including the "CDS generation" column.
- Title `# Topic — qualifier` (em dash), no chapter number. `##` headings
  carry no emoji.
- Section order: `## What is it?` → `## Why is it used?` →
  `## When should it be used?` → syntax/example sections →
  `## Common Mistakes` → `## Performance Considerations` →
  `## SAP Best Practices` → `## Interview Notes` → `## Related Chapters`.
- Headings over preserved notes end in `(original note)` or
  `(original notes)`.
- Common Mistakes items start with `- ❌`. Interview Notes use
  `- **Q: <question>**` followed by an indented `  A: <answer>` line.

## Labels
- Exactly five labels, shared with ABAPGuide: `CURRENT / RECOMMENDED`,
  `CLASSIC BUT STILL RELEVANT`, `LEGACY / HISTORICAL REFERENCE`,
  `ABAP CLOUD / MODERN CONTEXT`, `VERSION-DEPENDENT`.
- Lifecycle notes use the ABAPGuide format:
  ``> **Lifecycle:** `LABEL`. <one or two sentences>``. Existing
  `**Classification: LABEL**` lines are migrated in the planned chapter
  pass.
- Version notes: `> ⚠️ **VERSION-DEPENDENT: <feature>.** <text>`, pointing
  to the ABAP Keyword Documentation.
- Existing `ABAP CLOUD / MODERN` labels and the 🕒 version callout are
  migrated in the planned chapter pass.
- `> **CDS generation:** <text>. See [Classic vs Modern CDS](../02-CDS-Basics/Classic-vs-Modern.md).`
  goes directly under the title, only for notes about the CDS generation
  and only where the generation changes what the reader sees.
  Generation-neutral chapters get no generation note; other context
  notes use `> 📝`.
- Callouts: `> ⚠️` pitfalls and corrections, `> 💡` tips, `> 📝` notes,
  `> 🔐` security implications. One idea per callout.

## Code examples
- Fences are ```` ```abap ```` for CDS DDL/DCL and ABAP alike; an
  untagged fence only for plain-text trees or diagrams.
- Fragments get `> 📌 **PARTIAL SNIPPET** — <what is missing or assumed>.`
  directly above. Lookup collections that cannot activate as a whole get
  `> ⚠️ **CONCEPTUAL CATALOGUE — <why>.**`. Complete examples need no label.
- Comments: `//` in CDS DDL/DCL, `"` in ABAP. Never mix them.
- Placeholders use `ZSM_` plus an infix, upper case in CDS: `ZSM_I_`
  view/entity, `ZSM_C_` consumption/projection, `ZSM_V_` sqlViewName
  (max. 16 characters), `ZSM_T_` table, `ZSM_F_` table function,
  `ZSM_CL_` class, `ZSM_DCL_` role; ABAP reports `zsm_p_`.
- `ZSD_*` and `ZSM_CDS_*` are not allowed; existing ones are renamed in
  the chapter pass.
- View-entity element aliases are CamelCase (`matnr as Material`). Mark
  key elements with `key`.
- Variables: the current convention is the classic prefixes used in
  ABAPGuide (Chapter 20 there); docs/CDS-Development-Rules.md may change
  this.
- A security-relevant read (`WITH PRIVILEGED ACCESS`, generated SQL view)
  is always shown next to the access-controlled alternative.

## Links
- Relative links only. Same folder: file name as text (`[Main.md](Main.md)`);
  other folder: repo-root path as text
  (`[09-Security/AccessControl.md](../09-Security/AccessControl.md)`).
- Related Chapters list: `- [path](relative-path) — reason`.
- For version questions link the ABAP Keyword Documentation (latest index
  URL as in the root README).
- External links are limited to official SAP documentation (help.sap.com,
  ABAP Keyword Documentation) and the sibling guides in
  github.com/serhatmercan.
