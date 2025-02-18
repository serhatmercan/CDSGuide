@AccessControl.authorizationCheck  : #NOT_REQUIRED
@EndUserText.label                 : 'Main CDS'

define view ZSM_I_001 
as select from mara {
    matnr
}
