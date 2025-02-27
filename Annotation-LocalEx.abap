" Local Annotation - Example for CDS Views
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

    " Rating Indicator II (Bar Chart)
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
    key count(*) as TotalPlants,

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