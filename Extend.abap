" Default
" View
define view ZSM_I_001 
  as select from zsm_t_001 as T1 
  association [0..1] to zsm_t_002 as _T2 on  _T2.key = T1.key
{
    T1.key,
    _T2.description
}

" Extension View (Extend)
@AbapCatalog.sqlViewAppendName: 'ZSM_I_EXT_001'
@EndUserText.label: 'ZSM_I_001 Extend View'

extend view ZSM_I_001 with ZSM_I_EXT_001
{
    T1.value,
    _T2.explanation
}

" => ZSM_I_001 = Key, Description, Value, Explanation
