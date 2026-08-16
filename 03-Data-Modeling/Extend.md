# CDS View Extensions (`extend view`)

## What is it?

A **CDS view extension** adds new fields, associations, or annotations to an *existing* CDS view **without modifying its original source code**. The extension is a separate DDL source object that references the base view by name.

## Why is it used?

- To enrich a view (often a **standard SAP** view you must not modify directly) with custom (`Z`/`Y`) fields.
- To keep custom enhancements cleanly separated from standard/original code — surviving upgrades, since the original view object is untouched.
- To add fields conditionally per customer/industry without bloating the base view.

## When should it be used?

Use `extend view` whenever you need to add fields to a view you don't own (SAP standard views) or want to keep custom additions physically separate from a base view for maintainability — instead of copying and modifying the original view.

> ⚠️ The base view must explicitly allow extensions: `@Metadata.allowExtensions: true` (see [04-CDS-Annotations/Annotation-Global.md](../04-CDS-Annotations/Annotation-Global.md)) and, in classic CDS, `@AbapCatalog.viewEnhancementCategory` must include `#PROJECTION_LIST` (or another compatible category) for the extension to activate.

## Syntax and Example (original note)

### Base View

```abap
// Extension CDS View(Extend)
// View
@AbapCatalog.sqlViewName: 'ZSM_V_EXT001'
@Metadata.allowExtensions: true
@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST]

define view ZSM_I_001
  as select from zsm_t_001 as T1

  association [0..1] to zsm_t_002 as _T2 on _T2.key = T1.key

{
  T1.key,
  _T2.description
}
```

### Extension

```abap
// Extension View(Extend)
@AbapCatalog.sqlViewAppendName: 'ZSM_I_EXT_001'
@EndUserText.label: 'ZSM_I_001 Extend View'

extend view ZSM_I_001 with ZSM_I_EXT_001

{
  T1.value,
  _T2.explanation
}

// => ZSM_I_001 = Key, Description, Value, Explanation
```

### Keyword-by-keyword explanation

| Element | Meaning |
|---|---|
| `@AbapCatalog.sqlViewAppendName` | The name of the SQL view append generated for this extension (analogous to `sqlViewName` for a base view). |
| `extend view <base> with <extension-name>` | Declares this DDL source as an extension of `<base>`, identified by `<extension-name>`. |
| `{ ... }` | The **additional** elements contributed by this extension — added to the base view's result set. |

After activation, consumers selecting from `ZSM_I_001` automatically see all four fields: `key`, `description` (from the base view) plus `value`, `explanation` (from the extension) — as if they had always been part of the original view.

## Common Mistakes

- ❌ Forgetting to set `@Metadata.allowExtensions: true` on the base view — the extension will not activate.
- ❌ Referencing an alias (`T1`, `_T2`) from the base view's `FROM`/association clause that isn't actually exposed the same way — the extension shares the base view's data sources, so aliases must match.
- ❌ Adding fields with names that collide with existing fields in the base view.

## Performance Considerations

- An extension adds fields to the same underlying SQL statement — it does not introduce a separate round trip, but any additional joins/associations it brings in do add to the query cost like any other field.
- Multiple extensions on the same base view are all merged at activation; keep them lean to avoid an ever-growing, hard-to-trace field list.

## SAP Best Practices

- Use `extend view` (rather than copying/modifying) whenever extending **standard SAP** CDS views, to remain upgrade-safe.
- Keep custom extensions in a dedicated package/namespace, clearly separated from standard objects.
- Document, in the extension's `@EndUserText.label` or a comment, *why* the extension exists and what it adds — this context is easy to lose once the extension lives in a separate object from the base view.

## Interview Notes

- **Q: Why would you use `extend view` instead of directly modifying a CDS view?**
  A: To add custom fields to a standard SAP view without modifying SAP's original object — keeping the customization upgrade-safe and cleanly separated (also required, since standard objects usually cannot be modified directly).
- **Q: What must the base view declare for an extension to be possible?**
  A: `@Metadata.allowExtensions: true` (and, for classic CDS, an appropriate `@AbapCatalog.viewEnhancementCategory`).

## Related Chapters

- [04-CDS-Annotations/Annotation-Global.md](../04-CDS-Annotations/Annotation-Global.md) — `allowExtensions` and `viewEnhancementCategory` details
- [Association.md](Association.md) — associations referenced from within an extension
