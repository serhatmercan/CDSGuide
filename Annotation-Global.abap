" Global Annotations for CDS Views
@AbapCatalog: {
    buffering: {
        status                      : #ACTIVE,                              " View Buffer Property Status || w/ Type
        type                        : #FULL                                 " View Buffer Property        || w/ Status
    },
    compiler: {
        compareFilter               : true                                  " Compare Filter
    }
    preserveKey                     : true,                                 " true: From CDS Key  || false: From Tables
    sqlViewName                     : 'ZSM_CDS_001'                         " View Name (SE11),
    viewEnhancementCategory         : [#NONE]                               " View Enhancement Category: GROUP_BY || NONE || UNION || PROJECTION_LIST 
}
@AccessControl.authorizationCheck   : #NOT_REQUIRED                         " Check Access Control = #CHECK || #NOT_ALLOWED || #NOT_REQUIRED
@Analytics.query                    : true                                  " Analytics Query 
@ClientHandling.algorithm           : #SESSION_VARIABLE                     " AUTOMATED || NONE || SESSION_VARIABLE
@Consumption.ranked                 : true                                  " Consumption Ranking
@EndUserText.label                  : 'CDS Description'                     " CDS Description 
@Metadata.allowExtensions           : true                                  " Allow Extensions  
@ObjectModel: {
  createEnabled                     : true,                                 " Create Enabled
  deleteEnabled                     : true,                                 " Delete Enabled
  updateEnabled                     : true,                                 " Update Enabled    
  usageType: {
    dataClass                       : #MIXED,                               " Data Class: CUSTOMIZING || MASTER || META || MIXED || ORGANIZATIONAL || TRANSACTIONAL
    serviceQuality                  : #X,                                   " Service Quality: A || B || C || D || X || P
    sizeCategory                    : #S                                    " Size Category:   S || M || L || XL || XXL 
  },
  query: {
    implementedBy                   : 'ABAP:ZSM_CL_IM_QUERY'                " Implemented By        
  }
}
@OData.publish                      : true                                  " Display OData Service
@Search.searchable                  : true                                  " Searchable
@UI: {
    chart: [{
        chartType                   : #COLUMN,                              " Chart Type:
                                                                            " AREA || AREA_STACKED || AREA_STACKED_100 ||    
                                                                            " BAR || BAR_DUAL || BAR_STACKED || BAR_STACKED_100 || BAR_STACKED_DUAL || BAR_STACKED_DUAL_100 || 
                                                                            " BUBBLE || BULLET ||
                                                                            " COLUMN || COLUMN_DUAL || COLUMN_STACKED || COLUMN_STACKED_100 || COLUMN_STACKED_DUAL || COLUMN_STACKED_DUAL_100  ||
                                                                            " COMBINATION || COMBINATION_DUAL || COMBINATION_STACKED || COMBINATION_STACKED_DUAL ||
                                                                            " DONUT || DONUT_100 || HEAT_MAP ||
                                                                            " HORIZONTAL_AREA || HORIZONTAL_AREA_STACKED || HORIZONTAL_AREA_STACKED_100 ||
                                                                            " HORIZONTAL_COMBINATION_DUAL || HORIZONTAL_COMBINATION_STACKED || HORIZONTAL_COMBINATION_STACKED_DUAL || HORIZONTAL_WATERFALL ||
                                                                            " LINE || LINE_DUAL || PIE || RADAR || SCATTER || TREE_MAP || WATERFALL || VERTICAL_BULLET
        dimensionAttributes: {
            dimension               : 'SalesDocument',                      " Dimension Field Name 
            role                    : #SERIES                               " Dimension Role: CATEGORY || CATEGORY2 || SERIES
        },
        dimensions                  : ['SalesDocument'],                    " Dimension Field Name
        measureAttributes: [{
            measure                 : 'NetAmount',                          " Measure Field Name 
            role                    : #AXIS_1                               " Measure Role: AXIS_1 || AXIS_2 || AXIS_3
            }, {
            measure                 : 'NetPriceAmount',                     " Measure Field Name 
            role                    : #AXIS_1                               " Measure Role: AXIS_1 || AXIS_2 || AXIS_3                 
        }]
        measures                    : ['NetAmount', 'NetPriceAmount'],      " Measure Field Names
        title                       : 'Order Net Amount',                   " Chart Title        
        qualifier                   : 'ChartLineItem'                       " Chart Qualifier    
    }],
    headerInfo: {
        description:{
            type                    : #STANDARD,                            " OPL: Header Info Key Field Type  = STANDARD || AS_CONNECTED_FIELDS || WITH_INTENT_BASED_NAVIGATION || WITH_NAVIGATION_PATH || WITH_URL
            value                   : 'CustomerName'                        " OPL: Header Info Description Field Value
        },    
        title: {
            type                    : #STANDARD,                            " OPL: Header Info Key Field Type  = STANDARD || AS_CONNECTED_FIELDS || WITH_INTENT_BASED_NAVIGATION || WITH_NAVIGATION_PATH || WITH_URL
            value                   : 'SalesOrderID'                        " OPL: Header Info Key Field Value   
        },
        typeName                    : 'Purchase Order',                     " OPL: Header Info Text
        typeNamePlural              : 'Purchase Orders'                     " CDS Data Table Count Plural Name  
    },
    presentationVariant: [{
        maxItems                    : '5',                                  " Max Items       
        sortOrder: [{
            by                      : 'Matnr',                              " Field Name
            direction               : #DESC                                 " Sort Order: ASC || DESC  
        }],
        qualifier                   : 'Top5Changed',                        " Presentation Variant Qualifier
        visualizations: [{
            type                    : #AS_LINEITEM                          " Visualization Type: AS_CHART || AS_DATAPOINT || AS_LINEITEM
        }]
    }]
}
@VDM.viewType                       : #CONSUMPTION                          " View Types: BASIC || COMPOSITE || CONSUMPTION || EXTENSION || DERIVATION_FUNCTION || TRANSACTIONAL