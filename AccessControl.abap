" Default
" View
@AccessControl.authorizationCheck : #CHECK

define view ZSM_I_001 
as select from mara {
    matnr,
    meins
}

" Access Control
@EndUserText.label : 'Access Control For ZSM_I_001'
@MappingRole       : true

define role ZSM_DCL_001
    grant
        select
            on
                ZSM_I_001
                    where
                        meins = 'ST';
