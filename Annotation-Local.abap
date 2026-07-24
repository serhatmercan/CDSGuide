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

@Consumption.": { Hidden.in.OData.&.UI.semanticObject: 'RequestForQuotation',
                  Navigate.to.Semantic.Object.w/.UI.lineItem: { semanticObjectAction, type: #FOR_INTENT_BASED_NAVIGATION } }

@Consumption.filter: { hidden: false,
                       ": { Hidden.in.OData.&.UI.mandatory: true,
                            Mandatory.Field.multipleSelections: false,
                            Multiple.Selections.selectionType.#INTERVAL.".Selection.Types.SINGLE.||.INTERVAL.||.RANGE.||: HIERARCHY_NODE } }

@Consumption.hidden: true
@Consumption.valueHelpDefault.binding.usage.#FILTER_AND_RESULT.".Usage.FILTER.||.RESULT.||: FILTER_AND_RESULT

@Consumption.valueHelpDefinition: [ { entity: { element: 'StorageLocation',
                                                ".Value.Help.Element.name.'C_StorageLocationVH'.".Value.Help.Name: CDS } } ]

@DefaultAggregation: #FORMULA                      " AVG || COUNT || COUNT_DISTINCT || FORMULA || MAX || MIN || NONE || SUM
@EndUserText.label                      : 'Material'                    " Text Field Name in OData & UI
@ObjectModel:

{
  filter: {
      transformedBy                   : 'ABAP:ZSM_CL_TOTAL_ORDER'     " Calculate Value in Class
  },

  foreignKey: {
      association                     : '_Plant'                      " Association Reference
  },

  readOnly                            : true,

  " Read Only Field
text: {
association                     : '_MaterialText'               " Association Reference
element                         :['veh_text']                " Field Description(Key & Description)
},

  virtualElement                      : true,

  " Using w/ virtualElementCalculatedBy
virtualElementCalculatedBy          : 'ABAP:ZSM_CL_TOTAL_ORDER'     " Calculate Value in Class
}

@Search.": { Default.Search.Element.fuzzinessThreshold: 0.8,
             Fuzziness.Threshold.ranking.#MEDIUM.".HIGH.||.MEDIUM.||: LOW }

@Search.defaultSearchElement: true

@Semantics.": { Assign: { Currency.Code.currencyCode: true, Unit.of.Measure.unitOfMeasure.true.".Define.Unit.of: Measure },
                Define.Currency.Code.systemDateTime: { createdAt: true,
                                                       ".Assign.Created.At.lastChangedAt.true.".Assign.Last.Changed: At } }

@Semantics.amount.currencyCode: 'Currency'
@Semantics.quantity.unitOfMeasure: 'MEINS'
@Semantics.user: { createdBy: true, ".Assign.Created.By.lastChangedBy.true.".Assign.Last.Changed: By }

@UI.".Hidden.in.UI.identification: { importance: #HIGH,
                                     ".Importance.#LOW.||.#MEDIUM.||.#HIGH.position.10.".Identification: Position }

@UI.criticalityCalculation: { deviationRangeHighValue: 10,
                              ": { Deviation.Range: { High.Value.deviationRangeLowValue: 000,
                                                      Low.Value.improvementDirection: #TARGET },
                                   Improvement.Direction.#MAXIMIZE.||.#MINIMIZE.||.#TARGET.toleranceRangeHighValue: 1000,
                                   Tolerance.Range.High.Value.toleranceRangeLowValue.8.".Tolerance.Range.Low: Value } }

@UI.dataPoint: { title: 'Material',
                 ": { Text.Field.Name.in.UI.targetValue: 6, Rating.Indicator.w/.UI.dataPoint.visualization: #RATING },
                 UI.lineItem.type.#AS_DATAPOINT.valueFormat.numberOfFractionalDigits.2.".Number.of.Fractional: Digits,
                 visualization.#RATING.".Rating.Indicator.w/: UI.dataPoint.targetValue,
                 UI.lineItem.type: #AS_DATAPOINT }

@UI.facet: [ ".Body.Facets: { label: 'Header',
                              ": { Facet: { Label.id: 'Detail', ID.position: 10, Position.purpose: #STANDARD },
                                   FILTER.||.HEADER.||.QUICK_CREATE.||.QUICK_VIEW.||.STANDARD.targetElement: '_Material',
                                   Reference.type.#COLLECTION.".ADDRESS_REFERENCE.||.BADGE_REFERENCE.||.CHART_REFERENCE.||.COLLECTION.||.CONTACT_REFERENCE.||.DATAPOINT_REFERENCE.||.FIELDGROUP_REFERENCE.".HEADERINFO_REFERENCE.||.IDENTIFICATION_REFERENCE.||.LINEITEM_REFERENCE.||.NOTE_REFERENCE.||.PRESENTATIONVARIANT_REFERENCE.||.SELECTIONPRESENTATIONVARIANT_REFERENCE.".STATUSINFO_REFERENCE.||: URL_REFERENCE } } ]

@UI.fieldGroup: [ { emphasized: true,
                    ": { Emphasized.Field.position: 10,
                         Field.Group.Position.qualifier.'WerksQualifier'.".Field.Group: Qualifier } } ]

@UI.hidden: true

@UI.lineItem: { criticality: 'QuantityCrytical',
                ": { Data.Visualization.Criticality.cssDefault.width.'10em'.".CSS.Default: Width,
                     Define.Action.w/.UI.lineItem.type.#FOR_ACTION.importance: #HIGH,
                     Importance.#LOW.||.#MEDIUM.||.#HIGH.label: 'Material',
                     Text.Field.Name.in.UI.position: 10,
                     Position.type: #AS_DATAPOINT,
                     Rating.Indicator.w/.UI.dataPoint: { targetValue, visualization: #RATING },
                     Navigate.to.Semantic.Object.w/: { UI.lineItem.dataAction.&.UI.lineItem.label.type: #FOR_INTENT_BASED_NAVIGATION,
                                                       Consumption.semanticObject.&.UI.lineItem: { semanticObjectAction.type: #WITH_URL,
                                                                                                   type.qualifier: 'PurchItem' } },
                     External.URL.w/.UI.lineItem.url.semanticObjectAction: 'compare',
                     Section.Qualifier.url.'URL'.".External.URL.w/: UI.lineItem.type },
                dataAction: 'onCloseDocument',
                type: #FOR_ACTION }

@UI.selectionField.position.10.".Selection.Field: Position
@UI.textArrangement.#TEXT_FIRST.".Text.Arragements.TEXT_FIRST.||.TEXT_LAST.||.TEXT_ONLY.||: TEXT_SEPARATE
