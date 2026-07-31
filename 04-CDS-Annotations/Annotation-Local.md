# Local (Element-Level) Annotations — Quick Reference

## What is it?

**Local annotations** are attached directly above an individual **element** (field) inside the view's `{ }` field list, rather than above the whole view. They describe how *that specific field* should behave semantically, in the UI, in OData, and in analytics.

## Why is it used?

To attach metadata exactly where it belongs — on the field itself — so that a single field carries its own currency/unit reference, UI position, search behavior, criticality, etc., without extra configuration layers.

## When should it be used?

Use local annotations whenever metadata is specific to one field: currency/unit assignment, UI positioning, value help binding, hidden fields, text associations, and so on. Use [global annotations](Annotation-Global.md) when the metadata applies to the view as a whole.

## Original Notes (raw)

> ⚠️ **Preservation note:** the notes below were captured from documentation/IntelliSense tooltips and, in a few places, the annotation value and its descriptive comment got concatenated into a single dotted path (e.g. `@Consumption.": { Hidden.in.OData.&.UI.semanticObject: ... }`). That form does **not** parse as valid CDS syntax — it's a documentation artifact, not something to paste into a real view. The **cleaned-up equivalents** are provided in the reference table further down; keeping the raw notes here preserves the original research trail.

```abap
" Local Annotation for CDS Views
@AnalyticsDetails:

{
  exceptionAggregationSteps: {
    " Exception Aggregation Behavior: AVG || COUNT || COUNT_DISTINCT || FIRST || LAST || MAX || MIN || NHA || STD || SUM
    exceptionAggregationBehavior    : #IGNORE,
    " Exception Aggregation Elements: Field Name
    exceptionAggregationElements    :['NetAmount']
  }
  query: {
      axis                            : #ROWS, " Axis: COLUMNS || FREE || ROWS
      decimals                        : 2, " Decimal Places
      formula                         : 'NODIM(IntrstRtInPrcnt+0)'    " Formula
      display                         : #TEXT, " Display: KEY || KEY_TEXT || TEXT || TEXT_KEY
      variableSequence                : 10                            " Type: Integer
  }
}

@DefaultAggregation: #FORMULA                      " AVG || COUNT || COUNT_DISTINCT || FORMULA || MAX || MIN || NONE || SUM
@EndUserText.label                      : 'Material'                    " Text Field Name in OData & UI

@Semantics.amount.currencyCode: 'Currency'
@Semantics.quantity.unitOfMeasure: 'MEINS'

@Search.defaultSearchElement: true

@UI.hidden: true
```

## Cleaned-Up Reference Table

| Annotation | Purpose |
|---|---|
| `@AnalyticsDetails.query.axis` | Placement of the field in an analytical query: `#ROWS`, `#COLUMNS`, or `#FREE` (available but not placed by default). |
| `@AnalyticsDetails.query.display` | How a coded field is displayed: `#KEY`, `#TEXT`, `#KEY_TEXT`, `#TEXT_KEY`. |
| `@AnalyticsDetails.query.formula` | A calculated formula field for analytical queries. |
| `@AnalyticsDetails.exceptionAggregationSteps.exceptionAggregationBehavior` | How to aggregate this measure when grouped by "exception" dimensions (`AVG`, `SUM`, `MAX`, `MIN`, etc.) — used for KPIs like "average delay per route," where a plain sum would be meaningless. |
| `@Consumption.filter.hidden` / `mandatory` / `multipleSelections` / `selectionType` | Controls how a field behaves as a UI filter/selection field. |
| `@Consumption.hidden` | Hides the field entirely from OData/UI consumption. |
| `@Consumption.valueHelpDefault.binding.usage` | Whether a value help applies to `#FILTER`, `#RESULT`, or `#FILTER_AND_RESULT`. |
| `@Consumption.valueHelpDefinition` | Points to the CDS entity/element that provides F4 value help for this field. |
| `@DefaultAggregation` | Default aggregation behavior for a measure field: `#SUM`, `#AVG`, `#MIN`, `#MAX`, `#COUNT`, `#COUNT_DISTINCT`, `#FORMULA`, `#NONE`. |
| `@EndUserText.label` | Field-level description shown in UI/OData metadata. |
| `@ObjectModel.foreignKey.association` | Declares which association represents this field's foreign-key relationship (used by value helps/RAP). |
| `@ObjectModel.text.association` / `.element` | Declares the text association/field providing a description for a coded value (e.g. material number → material description). |
| `@ObjectModel.readOnly` | Marks a field as non-editable in RAP-based UIs. |
| `@ObjectModel.virtualElement` + `virtualElementCalculatedBy` | Declares a **calculated field** whose value is computed at runtime by an ABAP class implementing `IF_SADL_EXIT_CALC_ELEMENT_READ` — see [10-Examples/Class.md](../10-Examples/Class.md). |
| `@Search.defaultSearchElement` | Includes this field by default in free-text search. |
| `@Search.fuzzinessThreshold` / `ranking` | Tunes fuzzy search matching and result ranking. |
| `@Semantics.amount.currencyCode` | Declares which field holds the currency for this amount field. |
| `@Semantics.currencyCode` | Marks *this* field as the currency-code field referenced by an amount field. |
| `@Semantics.quantity.unitOfMeasure` | Declares which field holds the unit of measure for this quantity field. |
| `@Semantics.unitOfMeasure` | Marks *this* field as the unit-of-measure field. |
| `@Semantics.systemDateTime.createdAt` / `lastChangedAt` | Marks system-managed timestamp fields. |
| `@Semantics.user.createdBy` / `lastChangedBy` | Marks system-managed user fields. |
| `@UI.identification` | Adds the field to the object page's general information/identification section. |
| `@UI.lineItem` | Adds the field as a column in list reports/tables, with `position`, `importance`, `label`, `type`, `criticality`. |
| `@UI.selectionField` | Exposes the field as a selection/filter field. |
| `@UI.fieldGroup` | Groups related fields together under a shared qualifier in the UI. |
| `@UI.facet` | Defines a section (facet) on an object page. |
| `@UI.dataPoint` | Renders the field as a KPI/rating/progress indicator, optionally with `criticalityCalculation`. |
| `@UI.hidden` | Hides the field from the UI (while still available via OData, unless combined with `@Consumption.hidden`). |
| `@UI.textArrangement` | Controls how a key and its text are combined for display: `#TEXT_FIRST`, `#TEXT_LAST`, `#TEXT_ONLY`, `#TEXT_SEPARATE`. |

## Common Mistakes

- ❌ Copying documentation/tooltip text directly as annotation syntax (see the preservation note above) — always verify against the ADT annotation assist (`Ctrl+Space`) before activating.
- ❌ Setting `@Semantics.amount.currencyCode` without the referenced currency field actually being marked with `@Semantics.currencyCode: true`.
- ❌ Using `@UI.hidden` when the intent was `@Consumption.hidden` (or vice versa) — the former only affects Fiori Elements rendering, the latter removes the field from the OData payload entirely.

## Performance Considerations

- Local annotations are pure metadata — they do not affect the SQL generated for the view and carry no runtime cost by themselves.
- `@ObjectModel.virtualElement` fields, however, **do** have a runtime cost: they trigger an additional ABAP-side calculation (via the exit class) for every row read. See [10-Examples/Class.md](../10-Examples/Class.md) for the performance implications.

## SAP Best Practices

- Always pair `@Semantics.amount.currencyCode` / `@Semantics.quantity.unitOfMeasure` with the corresponding currency/unit field annotation — Fiori Elements and RAP rely on this pairing to render amounts/quantities correctly.
- Use `@ObjectModel.text` instead of manually concatenating key + description in the SQL — it lets consuming UIs choose the text arrangement themselves.

## Interview Notes

- **Q: How does a CDS view know which field is the currency for an amount field?**
  A: Through the pair of annotations `@Semantics.amount.currencyCode: '<Field>'` on the amount field and `@Semantics.currencyCode: true` on the referenced field.
- **Q: What is `@DefaultAggregation` used for?**
  A: It tells analytical consumers how to aggregate a measure by default when no explicit aggregation is requested (e.g. `#SUM` for an amount, `#MAX` for a "last changed" date).

## Related Chapters

- [Annotation-Global.md](Annotation-Global.md) — view-level annotations
- [Annotation-LocalEx.md](Annotation-LocalEx.md) — a full worked view showing these annotations applied to real fields
- [10-Examples/Class.md](../10-Examples/Class.md) — the exit class behind `virtualElementCalculatedBy`
