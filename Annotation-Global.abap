" Global Annotations for CDS Views
@AbapCatalog:

{
  buffering: {
    " View Buffer Property Status || w/ Type
    status: #ACTIVE,

    " View Buffer Property        || w/ Status
    type: #FULL
  },

  compiler: {
    " Compare Filter Behavior: true || false
    compareFilter : true
  }

  preserveKey : true,

  " View Name(SE11) - > true: From CDS Key  || false: From Tables
  sqlViewName : 'ZSM_CDS_001',

  " View Enhancement Category: GROUP_BY || NONE || UNION || PROJECTION_LIST
  viewEnhancementCategory :[#NONE]
}

" Check Access Control = #CHECK || #NOT_ALLOWED || #NOT_REQUIRED
@AccessControl.authorizationCheck: #NOT_REQUIRED

" Analytics Query
@Analytics.query : true

" Client Handling Algorithm: AUTOMATED || NONE || SESSION_VARIABLE
@ClientHandling.algorithm : #SESSION_VARIABLE

" Consumption Ranking
@Consumption.ranked : true

" CDS Description
@EndUserText.label : 'CDS Description'

" Allow Extensions: true || false
@Metadata.allowExtensions : true

@ObjectModel:

{
  createEnabled: true,
  deleteEnabled: true,
  updateEnabled: true,

  usageType: {
    " Data Class: CUSTOMIZING || MASTER || META || MIXED || ORGANIZATIONAL || TRANSACTIONAL
    dataClass: #MIXED,

    " Service Quality: A || B || C || D || X || P
    serviceQuality: #X,

    " Size Category: S || M || L || XL || XXL
    sizeCategory: #S
  },

  query: {
    " Implemented By: Class Name
    implementedBy: 'ABAP:ZSM_CL_IM_QUERY'
  }
}

" Display OData Service
@OData.publish: true

" Searchable
@Search.searchable: true

@UI:

{
  chart:[{
    " Chart Types:
    " AREA || AREA_STACKED || AREA_STACKED_100 ||
    " BAR || BAR_DUAL || BAR_STACKED || BAR_STACKED_100 || BAR_STACKED_DUAL || BAR_STACKED_DUAL_100 ||
    " BUBBLE || BULLET ||
    " COLUMN || COLUMN_DUAL || COLUMN_STACKED || COLUMN_STACKED_100 || COLUMN_STACKED_DUAL || COLUMN_STACKED_DUAL_100  ||
    " COMBINATION || COMBINATION_DUAL || COMBINATION_STACKED || COMBINATION_STACKED_DUAL ||
    " DONUT || DONUT_100 || HEAT_MAP ||
    " HORIZONTAL_AREA || HORIZONTAL_AREA_STACKED || HORIZONTAL_AREA_STACKED_100 ||
    " HORIZONTAL_COMBINATION_DUAL || HORIZONTAL_COMBINATION_STACKED || HORIZONTAL_COMBINATION_STACKED_DUAL || HORIZONTAL_WATERFALL ||
    " LINE || LINE_DUAL || PIE || RADAR || SCATTER || TREE_MAP || WATERFALL || VERTICAL_BULLET
    chartType: #COLUMN,

    dimensionAttributes: {
        dimension: 'SalesDocument',

        " Dimension Role: CATEGORY || CATEGORY2 || SERIES
        role: #SERIES
    },

    " Dimension Field Names
    dimensions :['SalesDocument'],

    measureAttributes:[{
        " Measure Field Name
        measure: 'NetAmount',

        " Measure Role: AXIS_1 || AXIS_2 || AXIS_3
        role: #AXIS_1
    },
    {
        measure: 'NetPriceAmount',
        role: #AXIS_1
    }],

    " Measure Field Names
    measures:['NetAmount', 'NetPriceAmount'],

    " Chart Title
    title: 'Order Net Amount',

    " Chart Qualifier
    qualifier: 'ChartLineItem'
  }],

  headerInfo: {
    description: {
        " OPL: Header Info Key Field Type  = STANDARD || AS_CONNECTED_FIELDS || WITH_INTENT_BASED_NAVIGATION || WITH_NAVIGATION_PATH || WITH_URL
        type: #STANDARD,

        " OPL: Header Info Description Field Value
        value: 'CustomerName'
    },

    title: {
        type: #STANDARD,
        value: 'SalesOrderID'
    },

    " OPL: Header Info Text
    typeName: 'Purchase Order',

    " CDS Data Table Count Plural Name
    typeNamePlural: 'Purchase Orders'
  },

  presentationVariant:[{
    " Max Items
    maxItems: '5',

    sortOrder:[{
        " Field Name
        by: 'Matnr',

        " Sort Order: ASC || DESC
        direction: #DESC
    }],

    " Presentation Variant Qualifier
    qualifier: 'Top5Changed',

    visualizations:[{
        " Visualization Type: AS_CHART || AS_DATAPOINT || AS_LINEITEM
        type: #AS_LINEITEM
    }]
  }]
}

" View Types: BASIC || COMPOSITE || CONSUMPTION || EXTENSION || DERIVATION_FUNCTION || TRANSACTIONAL
@VDM.viewType: #CONSUMPTION
