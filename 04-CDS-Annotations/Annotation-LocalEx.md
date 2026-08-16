# Local Annotations — Full Worked Example

## What is it?

This chapter shows local (element-level) annotations applied to a **real, complete view** built on `vbap` (Sales Document: Item Data), demonstrating how the annotations from [Annotation-Local.md](Annotation-Local.md) come together in practice.

## Why is it used?

Seeing the annotations in the context of a full field list makes the intent much clearer than an isolated reference list — this is the "how do I actually use this" companion to the previous chapter.

## Full Example (original note)

```abap
// Local Annotation - Example for CDS Views
define view ZSM_I_001
  as select from vbap

{
  key vbeln,

      // Action
    @UI.lineItem:[{
        position: 10,
        importance: #HIGH
    },
    {
        dataAction: 'onCloseDocument',
        label: 'Close Document',
        type: #FOR_ACTION
    }
    ]
    CapacityID,

      // Analytics Detail
    @AnalyticsDetails: {
        query: {
            axis: #FREE,
            display: #TEXT,
            variableSequence: 10
        }
    }
    CounterParty,

      // Analytics Detail II
    @AnalyticsDetails: {
        exceptionAggregationSteps: {
        exceptionAggregationBehavior: #AVG,
        exceptionAggregationElements:['Airline', 'FlightConnection', 'FlightDate']
        },
        query: {
            decimals: 0,
            formula: '$projection.WeightOfLuggage',
        }
      }

      // Calculate Field - I
    @ObjectModel: {
        virtualElement: true,
        virtualElementCalculatedBy: 'ABAP:ZSM_CL_TOTAL_ORDER'
    }
    @Semantics.quantity.unitOfMeasure : 'meins'
    cast(0 as abap.quan(13,3))                                       as TotalQuantity,

      // Calculate Field - II
    @ObjectModel: {
        virtualElement: true,
        virtualElementCalculatedBy: 'ABAP:ZSM_CL_TOTAL_ORDER'
    }
    @Semantics.amount.currencyCode : 'Currency'
    cast(0 as abap.curr(15,2))                                       as TotalNetAmount,

      // Consumption: Filter
    @Consumption.filter: {
        hidden: false,
        mandatory: true,
        multipleSelections: false,
        selectionType: #SINGLE
    },

      @Search.defaultSearchElement: true
      @UI.selectionField: [ { position: 10 } ]
      Budat,

      // Consumption: Value Help
    @Consumption: {
        valueHelpDefinition:[{
            entity: {
                element: 'StorageLocation',
                name: 'C_StorageLocationVH'
            }
          }]
        }
    @ObjectModel.text: { element:['Lgobe'] }
    @UI: {
        identification:[{ position: '10' }],
        lineItem:[{ position: '30' }],
        selectionField:[{ position: '20' }],
        textArrangement: #TEXT_FIRST
    }
    key oiisocisl.lgort                                              as StorageLocation,

      // Consumption: Value Help(Multi)
    @Consumption.valueHelpDefinition:[{
        entity: {
            name: 'ZSM_I_BATCH_MATNR_VH',
            element: 'Charg'
        },
        label: 'Batches Related to Material',
        qualifier: 'QF_Material'
    }, {
        entity: {
            name: 'ZSM_I_BATCH_WERKS_VH',
            element: 'Charg'
        },
        label: 'Batches Related to Plant Material',
        qualifier: 'QF_PlantMaterial'
    }, {
        entity: {
            name: 'ZSM_I_BATCH_LIFNR_VH',
            element: 'Charg'
        },
        label: 'Batches Related to Supplier',
        qualifier: 'QF_Supplier'
    }]
    Batch,

      // Currency Code: Assign
    @Semantics.amount.currencyCode: 'Currency'
    GrossAmount - NetAmount                                          as TaxAmount,

      // Currency Code: Define
    @Semantics.currencyCode: true
    TransactionCurrency                                              as Currency,

      // Data Visualization: Criticality -> Description
    @UI.lineItem.criticality: 'QuantityCrytical'
    case
        when Quantity > 100 then 'Sufficient Stock'
        when Quantity > 10 then 'Less than 100'
        else 'Less than 10' end                                      as QuantityDescription,

      // Data Visualization: Criticality -> Value
      @UI.hidden: true
      case
        when Quantity > 100 then 3
        when Quantity > 10 then 2
        else 1 end                                                   as QuantityCrytical,

      // External URL
      @UI: {
        lineItem: {
            type: #WITH_URL,
            url: 'URL'
        }
      }
      CompanyName,

      concat('https://www.example.com/search?q=', CompanyName)       as URL,

      concat('#PurchaseOrder-display?P_DOC_ID=', PurchasingDocument) as IntentURL,

    // Facet(Body -> Top Of Page)
    @UI.facet:[{
        id: 'Detail',
        label: 'Header',
        position: 10,
        type: #COLLECTION
    },
    {
        id: 'Items',
        label: 'Item',
        position: 10,
        targetElement: '_Material',
        type: #LINEITEM_REFERENCE
    }],

      // Field Group
      @UI: {
        fieldGroup:[{
            qualifier: 'WerksQualifier',
            position: 10,
            emphasized: true
        }],
        lineItem:[{ position: '20' }],
        selectionField:[{ position: '10' }],
        textArrangement: #TEXT_FIRST
      }
      @ObjectModel.text: { element:['PlantText']}
      key oiisocisl.werks                                            as Plant,

      // Field Description
      @ObjectModel.text.element:['veh_text']
      vehicle,

      // Field Description II
      @ObjectModel.text: {
          association: '_MaterialText',
          element:['Maktx']
      }

      // Hidden in OData & UI
      @Consumption.hidden: true
      posnr,

      // Measure Unit: Assign
      @Semantics.quantity.unitOfMeasure: 'MEINS'
      kwmeng,

      // Measure Unit: Define
      @Semantics.unitOfMeasure: true
      meins,

      // Rating Indicator
      @UI.dataPoint: {
        targetValue: 6,
        visualization: #RATING
      },

      @UI.lineItem: { position: 10, type: #AS_DATAPOINT }
      Rating,

      // Rating Indicator II(Bar Chart)
      @UI: {
        dataPoint: {
            criticalityCalculation: {
                deviationRangeHighValue: 10,
                deviationRangeLowValue: 000,
                improvementDirection: #TARGET,
                toleranceRangeHighValue: 1000,
                toleranceRangeLowValue: 8
              },
            title: 'Number of Plants in CC'
          },
          lineItem: {
            label: 'Total Plants in CC',
            position: 20,
            type: #AS_DATAPOINT,
            qualifier: 'Q1'
          }
      }
      key count(*)                                                   as TotalPlants,

      // Search & Value Help
      @Consumption.valueHelpDefault.binding.usage: #FILTER_AND_RESULT
      @ObjectModel.foreignKey.association: '_Plant'
      @Search: {
        defaultSearchElement: true,
        fuzzinessThreshold: 0.8,
        ranking: #HIGH
      }
      @UI.lineItem.position: 20
      werks                                                          as Werks,

      // Text Field Name & Hidden in UI
      @EndUserText.label: 'Material'
      @UI.hidden: true
      matnr,

      // User Information - System(Created At || Last Changed At)
      @Semantics.systemDateTime.createdAt: true
      @Semantics.systemDateTime.lastChangedAt: true
      created_at,

      // User Information - User(Created By || Last Changed By)
      @Semantics.user.createdBy: true
      @Semantics.user.lastChangedBy: true
      created_by
}
```

> ⚠️ **CONCEPTUAL CATALOGUE — illustrative, not a compilable single view.** This example intentionally packs *every* interesting annotation pattern into one field list to serve as a lookup catalog. In a real view, several things here would still need adjusting before activation: fields like `oiisocisl.lgort`/`werks` come from an alias never declared in a `FROM`, `key count(*)` is not a valid key, and the `vehicle`/`_MaterialText` blocks appear without a trailing comma/alias in places. Treat each annotated **snippet** as copy-paste-ready in isolation, not the file as a whole.

## Highlights Worth Calling Out

| Pattern | What it demonstrates |
|---|---|
| `@UI.lineItem: [{...}, {dataAction: ..., type: #FOR_ACTION}]` | A field can carry **multiple** `@UI.lineItem` entries — one as a normal column, another declaring a UI **action** button. |
| `virtualElement` + `virtualElementCalculatedBy` on `TotalQuantity` / `TotalNetAmount` | Two **calculated (virtual) fields**, both computed by the same exit class (`ZSM_CL_TOTAL_ORDER`) — see [10-Examples/Class.md](../10-Examples/Class.md) for the implementation. Note the semantics pairing: the quantity field points at a unit-of-measure element, the amount field at a currency-code element. |
| `QuantityDescription` / `QuantityCrytical` pair | The standard SAP pattern for **UI criticality**: one field holds the human-readable text, a second (usually `@UI.hidden`) holds the numeric criticality value (`1`/`2`/`3`) that `@UI.lineItem.criticality` points to. |
| `@UI.facet` with `#COLLECTION` and `#LINEITEM_REFERENCE` | Defines the object page layout: a header collection facet plus a table facet pointing at an association (`_Material`). |
| `@UI.dataPoint` + `criticalityCalculation` | Turns a plain number into a KPI/rating/progress visualization with configurable thresholds. |

## Common Mistakes

- ❌ Assigning two output fields the same alias (`URL` appeared twice in the original notes; the second is now `IntentURL`) — CDS requires unique element names.
- ❌ Annotating an amount field with `@Semantics.quantity.unitOfMeasure`, or a quantity field with `@Semantics.amount.currencyCode` — amounts pair with a currency-code element, quantities with a unit-of-measure element. The original notes had this reversed on the `CURR` virtual element.
- ❌ Forgetting the `key` keyword on genuinely unique fields while adding it to aggregated/calculated fields that aren't actually unique per row (e.g. `count(*) as TotalPlants` marked `key` only makes sense in very specific aggregation-view designs).
- ❌ Mixing multiple unrelated `@UI` sub-annotations (`lineItem`, `facet`, `dataPoint`) on the same field without checking how Fiori Elements actually renders the combination — test in a running Fiori Elements preview, not just by reading the annotations.

## Performance Considerations

- Every `virtualElement` field triggers ABAP-side computation for the *entire* result set on every read — reserve it for fields that genuinely cannot be computed in SQL (see [10-Examples/Class.md](../10-Examples/Class.md)).
- `@Search.fuzzinessThreshold` closer to `1.0` performs cheaper exact-ish matching; lower thresholds (more fuzziness) cost more at query time.

## SAP Best Practices

- Build one annotated field at a time and activate/test frequently — a view this densely annotated is much easier to get right incrementally than all at once.
- Keep `@UI.lineItem` `position` values spaced (10, 20, 30…) so new columns can be inserted later without renumbering everything.
- Use SAP Fiori Elements preview (in ADT or the Fiori tools) to visually confirm the effect of `@UI.facet`, `@UI.dataPoint`, and `@UI.lineItem` combinations.

## Interview Notes

- **Q: How do you add a UI action button to a CDS-based list report column?**
  A: Add a second entry to that field's `@UI.lineItem` array with `type: #FOR_ACTION`, `dataAction`, and `label`.
- **Q: How does SAP typically model a "criticality" traffic-light indicator?**
  A: A visible text/description field annotated with `@UI.lineItem.criticality: '<OtherField>'`, pointing to a second, usually `@UI.hidden`, numeric field holding `1`/`2`/`3`.

## Related Chapters

- [Annotation-Local.md](Annotation-Local.md) — the annotation reference table
- [Annotation-Global.md](Annotation-Global.md) — view-level annotations
- [10-Examples/Class.md](../10-Examples/Class.md) — the `ZSM_CL_TOTAL_ORDER` virtual element exit class
