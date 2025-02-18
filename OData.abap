@AbapCatalog.sqlViewName : 'ZSM_CDS_001'
@EndUserText.label       : 'DDL View For OData Service'
@OData.publish           : true

define view ZSM_I_001 
as select from mara {
    key matnr,
    mtart
}

" GW Client
" Service Name: ZSM_I_001_CDS
" URI: /sap/opu/odata/sap/ZSM_I_001_CDS/ZSM_I_001
