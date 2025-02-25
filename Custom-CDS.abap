@EndUserText.label: 'Custom CDS Entity'
@ObjectModel.query.implementedBy: 'ABAP:ZSM_CL_IM_QUERY'

define root custom entity ZSM_C_PO

{   
    @Consumption.valueHelpDefinition: [{ entity: { element: 'CompanyCode' }, name: 'I_COMPANYCODESTDVH' }]
    @ObjectModel.text.element       : [ 'CompanyCode' ]
    @Search.defaultSearchElement    : true  
    @UI: {
        identification              : [{ position: 10 }],
        lineItem                    : [{ cssDefault.width: '10em', position: 10, importance: #HIGH}],
        selectionField              : [{ position: 10 }]
    }  
    key COMPANYCODE                 : Bukrs;
    
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZSM_I_BSART', element: 'bsart' } }]
    @ObjectModel.text.element       : [ 'batxt' ]
    @Search.defaultSearchElement    : true
    @UI: {
        identification              : [{ position: 20 }],
        lineItem                    : [{ position: 20, importance: #HIGH }],
        selectionField              : [{ position: 20 }] 
    }
    PURCHASEORDERTYPE               : Bsart;

    @Search.defaultSearchElement    : true
    @UI: {
        identification              : [{ position: 30 }],  
        lineItem                    : [{ position: 30, importance: #HIGH}],
        selectionField              : [{ position: 30 }] 
    }
    PURCHASEORDER                   : VDMPurchaseOrder;

    @UI: {
        identification              : [{ position: 190 }],        
        lineItem                    : [{ position: 190, importance: #HIGH }]
    },  
    PURCHASEORDERITEM               : VDMPurchaseOrderItem;

    @Consumption.filter.hidden      : true
    @UI: {
        identification              : [{ position: 620 }],        
        lineItem                    : [{ position: 620, importance: #HIGH }]
    }, 
    FIRSTTIMESTAMP                  : Datum;


    _Header                         : association to parent ZSM_C_PO on _Header.EBELN = $projection.EBELN
                                                                    and _Header.EBELP = $projection.EBELP;

    _Item                           : composition [0..*] of ZSM_C_PO_ITEM;
}