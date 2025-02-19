" Global
@AbapCatalog: {
    buffering: {
        status                      : #ACTIVE,          " View Buffer Property Status || w/ Type
        type                        : #FULL             " View Buffer Property        || w/ Status
    },
    compiler: {
        compareFilter               : true
    }
    preserveKey                     : true,             " true: From CDS Key  || false: From Tables
    sqlViewName                     : 'ZSM_CDS_001'     " View Name (SE11),
    viewEnhancementCategory         : [#NONE]           " GROUP_BY || NONE || UNION || PROJECTION_LIST 
}
@AccessControl.authorizationCheck   : #NOT_REQUIRED     " Check Access Control = #CHECK || #NOT_ALLOWED || #NOT_REQUIRED
@ClientHandling.algorithm           : #SESSION_VARIABLE " AUTOMATED || NONE || SESSION_VARIABLE
@Consumption.ranked                 : true              "  
@EndUserText.label                  : 'CDS Description' " CDS Description
@Metadata.allowExtensions           : true
@ObjectModel: {
  createEnabled                     : true,             " 
  deleteEnabled                     : true,             "   
  updateEnabled                     : true,             "
  usageType: {
    dataClass                       : #MIXED,           " CUSTOMIZING || MASTER || META || MIXED || ORGANIZATIONAL || TRANSACTIONAL
    serviceQuality                  : #X,               " A || B || C || D || X || P
    sizeCategory                    : #S                " S || M || L || XL || XXL 
  }
}
@OData.publish                      : true              " Display OData Service
@Search.searchable                  : true              " Searchable
@UI: {
    headerInfo: {
        description:{
            type                    : #STANDARD,        " OPL: Header Info Key Field Type  = STANDARD || AS_CONNECTED_FIELDS || WITH_INTENT_BASED_NAVIGATION || WITH_NAVIGATION_PATH || WITH_URL
            value                   : 'CustomerName',   " OPL: Header Info Description Field Value
        },    
        title: {
            type                    : #STANDARD,        " OPL: Header Info Key Field Type  = STANDARD || AS_CONNECTED_FIELDS || WITH_INTENT_BASED_NAVIGATION || WITH_NAVIGATION_PATH || WITH_URL
            value                   : 'SalesOrderID'    " OPL: Header Info Key Field Value   
        },
        typeName                    : 'Purchase Order', " OPL: Header Info Text
        typeNamePlural              : 'Purchase Orders' " CDS Data Table Count Plural Name  
    },
    presentationVariant: [{
        sortOrder: [{
            by                      : 'Matnr',          " Field Name
            direction               : #DESC             " ASC || DESC  
        }],
        visualizations: [{
            type                    : #AS_LINEITEM      " AS_CHART || AS_DATAPOINT || AS_LINEITEM
        }]
    }]
}
@VDM.viewType                       : #CONSUMPTION      " View Types: BASIC || COMPOSITE || CONSUMPTION || EXTENSION || DERIVATION_FUNCTION || TRANSACTIONAL