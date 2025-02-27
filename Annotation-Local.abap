" Local Annotation for CDS Views
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
    criticalityCalculation: {
        deviationRangeHighValue         : 10,                           " Deviation Range High Value
        deviationRangeLowValue          : 000,                          " Deviation Range Low Value
        improvementDirection            : #TARGET,                      " Improvement Direction: #MAXIMIZE || #MINIMIZE || #TARGET
        toleranceRangeHighValue         : 1000,                         " Tolerance Range High Value    
        toleranceRangeLowValue          : 8                             " Tolerance Range Low Value        
    },
    dataPoint: {
        title                           : 'Material',                   " Text Field Name in UI      
        targetValue                     : 6,                            " Rating Indicator w/ UI.dataPoint.visualization: #RATING, UI.lineItem.type: #AS_DATAPOINT
        valueFormat:{
            numberOfFractionalDigits    : 2                             " Number of Fractional Digits
        }
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