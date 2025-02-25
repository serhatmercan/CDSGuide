" Local
@AnalyticsDetails: {
    exceptionAggregationSteps: {
        exceptionAggregationBehavior    : #IGNORE,                      " Exception Aggregation Behavior: AVG || COUNT || COUNT_DISTINCT || FIRST || LAST || MAX || MIN || NHA || STD || SUM
        exceptionAggregationElements    : [ 'NetAmount' ]               " Exception Aggregation Elements: Field Name
    }    
    query: {
        axis                            : #ROWS,                        " Axis: COLUMNS || FREE || ROWS
        decimals                        : 2,                            " Decimal Places
        formula                         : 'NODIM(IntrstRtInPrcnt+0)'    " Formula 
        display                         : #TEXT,                        " Display: KEY || KEY_TEXT || TEXT || TEXT_KEY
        variableSequence                : 10                            " Type: Integer
    }
}
@Consumption: {
    filter: {
        hidden                          : false,                        " Hidden in OData & UI
        mandatory                       : true,                         " Mandatory Field
        multipleSelections              : false,                        " Multiple Selections
        selectionType                   : #INTERVAL                     " Selection Types: SINGLE || INTERVAL || RANGE || HIERARCHY_NODE
    },
    hidden                              : true,                         " Hidden in OData & UI
    semanticObject                      : 'RequestForQuotation',        " Navigate to Semantic Object w/ UI.lineItem: {semanticObjectAction, type: #FOR_INTENT_BASED_NAVIGATION} 
    valueHelpDefault: {
        binding: {
            usage                       : #FILTER_AND_RESULT            " Usage: FILTER || RESULT || FILTER_AND_RESULT
        }        
    },
    valueHelpDefinition: [{ 
        entity: { 
            element                     : 'StorageLocation',            " Value Help Element
            name                        : 'C_StorageLocationVH'         " Value Help Name: CDS
        } 
    }]               
}
@DefaultAggregation                     : #FORMULA                      " AVG || COUNT || COUNT_DISTINCT || FORMULA || MAX || MIN || NONE || SUM   
@EndUserText.label                      : 'Material'                    " Text Field Name in OData & UI
@ObjectModel: {
    filter: { 
        transformedBy                   : 'ABAP:ZSM_CL_TOTAL_ORDER'     " Calculate Value in Class
    },
    foreignKey: {
        association                     : '_Plant'                      " Association Reference
    },
    readOnly                            : true,                         " Read Only Field
    text: {
        association                     : '_MaterialText'               " Association Reference
        element                         : [ 'veh_text' ]                " Field Description ( Key & Description )            
    },
    virtualElement                      : true,                         " Using w/ virtualElementCalculatedBy
    virtualElementCalculatedBy          : 'ABAP:ZSM_CL_TOTAL_ORDER'     " Calculate Value in Class
}
@Search: { 
    defaultSearchElement                : true,                         " Default Search Element    
    fuzzinessThreshold                  : 0.8,                          " Fuzziness Threshold 
    ranking                             : #MEDIUM                       " HIGH || MEDIUM || LOW
} 
@Semantics: {
    amount.currencyCode                 : 'Currency',                   " Assign Currency Code
    currencyCode                        : true,                         " Define Currency Code
    systemDateTime: {
        createdAt                       : true,                         " Assign Created At
        lastChangedAt                   : true                          " Assign Last Changed At
    },
    user: {
        createdBy                       : true,                         " Assign Created By
        lastChangedBy                   : true                          " Assign Last Changed By
    },
    quantity.unitOfMeasure              : 'MEINS',                      " Assign Unit of Measure
    unitOfMeasure                       : true                          " Define Unit of Measure 
}
@UI: {
    dataPoint: {
        title                           : 'Material',                   " Text Field Name in UI      
        targetValue                     : 6,                            " Rating Indicator w/ UI.dataPoint.visualization: #RATING, UI.lineItem.type: #AS_DATAPOINT
        visualization                   : #RATING                       " Rating Indicator w/ UI.dataPoint.targetValue, UI.lineItem.type: #AS_DATAPOINT
    },
    facet: [                                                            " Body Facets
        {
            label                       : 'Header',                     " Facet Label
            id                          : 'Detail',                     " Facet ID
            position                    : 10,                           " Facet Position
            purpose                     : #STANDARD,                    " FILTER || HEADER || QUICK_CREATE || QUICK_VIEW || STANDARD
            targetElement               : '_Material',                  " Reference
            type                        : #COLLECTION                   " ADDRESS_REFERENCE || BADGE_REFERENCE || CHART_REFERENCE || COLLECTION || CONTACT_REFERENCE || DATAPOINT_REFERENCE || FIELDGROUP_REFERENCE
                                                                        " HEADERINFO_REFERENCE || IDENTIFICATION_REFERENCE || LINEITEM_REFERENCE || NOTE_REFERENCE || PRESENTATIONVARIANT_REFERENCE || SELECTIONPRESENTATIONVARIANT_REFERENCE 
                                                                        " STATUSINFO_REFERENCE || URL_REFERENCE
        }
    ],
    fieldGroup: [
        { 
            emphasized                  : true,                         " Emphasized Field
            position                    : 10,                           " Field Group Position
            qualifier                   : 'WerksQualifier'              " Field Group Qualifier
        }
    ], 
    hidden                              : true,                         " Hidden in UI  
    identification: {
        importance                      : #HIGH,                        " Importance: #LOW || #MEDIUM || #HIGH  
        position                        : 10                            " Identification Position
    },
    lineItem: {
        criticality                     : 'QuantityCrytical',           " Data Visualization: Criticality
        cssDefault: {
            width                       : '10em'                        " CSS Default Width
        },
        dataAction                      : 'onCloseDocument',            " Define Action w/ UI.lineItem.type: #FOR_ACTION
        importance                      : #HIGH,                        " Importance: #LOW || #MEDIUM || #HIGH
        label                           : 'Material',                   " Text Field Name in UI       
        position                        : 10,                           " Position
        type                            : #AS_DATAPOINT,                " Rating Indicator w/ UI.dataPoint: {targetValue, visualization: #RATING}
        type                            : #FOR_ACTION,                  " Navigate to Semantic Object w/ UI.lineItem.dataAction & UI.lineItem.label
        type                            : #FOR_INTENT_BASED_NAVIGATION, " Navigate to Semantic Object w/ Consumption.semanticObject & UI.lineItem.semanticObjectAction
        type                            : #WITH_URL,                    " External URL w/ UI.lineItem.url                          
        semanticObjectAction            : 'compare',                    " Navigate to Semantic Object w/ Consumption.semanticObject & UI.lineItem.type
        qualifier                       : 'PurchItem',                  " Section Qualifier
        url                             : 'URL'                         " External URL w/ UI.lineItem.type 
    },
    selectionField: { 
        position                        : 10                            " Selection Field Position
    },
    textArrangement                     : #TEXT_FIRST                   " Text Arragements: TEXT_FIRST || TEXT_LAST || TEXT_ONLY || TEXT_SEPARATE
}

" Local Example
define view ZSM_I_001 
  as select from vbap {
    key vbeln,

    " Action
    @UI.lineItem: [
        {
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

    " Analictics Detail
    @AnalyticsDetails: {
        query: {
            axis                : #FREE,
            display             : #TEXT,
            variableSequence    : 10
        }   
    }
    CounterParty,

    " Analictics Detail II
    @AnalyticsDetails: {
        exceptionAggregationSteps: {
            exceptionAggregationBehavior    : #AVG,
            exceptionAggregationElements    : [ 'Airline', 'FlightConnection', 'FlightDate' ]
        }    
        query: {
            decimals                        : 0
            formula                         : '$projection.WeightOfLuggage',            
        }
    }

    " Calculate Field - I
    @ObjectModel: {
        virtualElement : true,                     
        virtualElementCalculatedBy : 'ABAP:ZSM_CL_TOTAL_ORDER'   
    }
    @Semantics.quantity.unitOfMeasure : 'VRKME_VL'
    cast( 0 as abap.quan( 13, 3 )) as lfimg_vl, 

    " Calculate Field - II
    @ObjectModel: {
        virtualElement : true,                     
        virtualElementCalculatedBy : 'ABAP:ZSM_CL_TOTAL_ORDER'   
    }
    @Semantics.quantity.unitOfMeasure : 'WAERK_VA'
    cast( 0 as abap.curr( 15, 2 )) as NetwrVF, 

    " Consumption: Filter
    @Consumption.filter: {
        hidden: false,
        mandatory: true,        
        multipleSelections: false,
        selectionType: #SINGLE
    },
    @Search: {
        defaultSearchElement: true
    }
    @UI: {
        selectionField: [{ position: 10 }] 
    }      
    Budat,

    " Consumption: Value Help
    @Consumption: { 
        valueHelpDefinition: [{ 
            entity: { 
                element: 'StorageLocation', 
                name: 'C_StorageLocationVH' 
            } 
        }] 
    }
    @ObjectModel.text: { element: ['Lgobe'] }
    @UI: { 
        identification: [{ position: '10' }],
        lineItem: [{ position: '30' }],
        selectionField: [{ position: '20' }],
        textArrangement: #TEXT_FIRST
    }
    key oiisocisl.lgort as StorageLocation,

    " Consumption: Value Help (Multi)
    @Consumption.valueHelpDefinition: [{ 
        entity: { 
            name: 'ZSM_I_BATCH_MATNR_VH',
            element: 'Charg' 
        },
        label: 'Batches Related to Material',
        qualifier: 'QF_Material' 
    },{ 
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

    " Currency Code: Assign
    @Semantics.amount.currencyCode: 'Currency'
    GrossAmount - Net Amount as TaxAmount,

    " Currency Code: Define
    @Semantics.currencyCode: true
    TransactionCurrency as Currency,

    " Data Visualization: Criticality -> Description
    @UI.lineItem.criticality: 'QuantityCrytical'
    case when Quantity > 100 then 'Sufficient Stock'
         when Quantity > 10 then 'Less than 100'
         else 'Less than 10' end as QuantityDescription,

    " Data Visualization: Criticality -> Value
    @UI.hidden: true
    case when Quantity > 100 then 3
         when Quantity > 10 then 2
         else 1 end as QuantityCrytical, 

    " External URL
    @UI: {
        lineItem: {
            type: #WITH_URL,
            url: 'URL'
        }
    }
    CompanyName,
    concat('http://gooogle.com/search?q=', CompanyName)              as URL,
    concat( '#PurchaseOrder-display?P_DOC_ID=', PurchasingDocument ) as URL

    " Facet (Body -> Top Of Page)
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

    " Field Group
    @UI: { 
        fieldGroup: [{ 
            qualifier: 'WerksQualifier', 
            position: 10,
            emphasized: true             
        }], 
        lineItem: [{ position: '20' }],
        selectionField: [{ position: '10' }],
        textArrangement: #TEXT_FIRST 
    }
    @ObjectModel.text: { element: ['PlantText']}
    key oiisocisl.werks as Plant,

    " Field Description
    @ObjectModel.text.element: [ 'veh_text' ]
    vehicle,

    " Field Description II
    @ObjectModel.text: { 
        association : '_MaterialText',
        element     : ['Maktx'] 
    }

    " Hidden in OData & UI
    @Consumption.hidden: true 
    posnr,

    " Measure Unit: Assign
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    kwmeng,

    " Measure Unit: Define
    @Semantics.unitOfMeasure: true
    meins,

    " Rating Indicator
    @UI.dataPoint: {
        targetValue: 6,
        visualization: #RATING
    },
    @UI.lineItem: {
        position: 10,
        type: #AS_DATAPOINT
    }
    Rating,

    " Search & Value Help
    @Consumption.valueHelpDefault.binding.usage:#FILTER_AND_RESULT
    @ObjectModel.foreignKey.association: '_Plant'
    @Search: {
        defaultSearchElement    : true,
        fuzzinessThreshold      : 0.8,
        ranking                 : #HIGH
    }
    @UI.lineItem.position: 20
    werks as Werks,

    " Text Field Name & Hidden in UI 
    @EndUserText.label: 'Material'
    @UI.hidden: true        
    matnr,

    " User Information - System ( Created At || Last Changed At )
    @Semantics.systemDateTime.createdAt: true
    @Semantics.systemDateTime.lastChangedAt: true
    created_at,

    " User Information - User  ( Created By || Last Changed By )
    @Semantics.user.createdBy: true
    @Semantics.user.lastChangedBy: true
    created_by,
}