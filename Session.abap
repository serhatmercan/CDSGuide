" Definition
$session.client          as CurrentClient,  " => T4D
$session.system_date     as SystemDate,     " => 2024-11-14
$session.system_language as SystemLanguage, " => TR
$session.user            as Username        " => XSMERCAN  
$

" Example
define view ZSM_I_001 
as select from mara {
    matnr,
    $session.client as CurrentClient
}
where ersda = $session.system_date

" Ex: System Date in Association
define root view entity ZSM_I_0005
  as select from I_BillingDocumentItem  as BDI
  association [0..1] to /sapsll/maritc  as _Maritc  on _Maritc.matnr = BDI.Product
                                                   and _Maritc.stcts = 'TR01'
                                                   and _Maritc.datab <= $session.system_date
                                                   and _Maritc.datbi >= $session.system_date
{
  key BDI.BillingDocument     as VbelnVF,
  key BDI.BillingDocumentItem as PosnrVF,
      _Maritc.ccngn           as GTIP
}

" Ex: System Language
define root view entity ZSD_I_0002
  as select from ZSD_I_0003 as I0003
  association [0..1] to I_BillingDocumentItem as _BDI on _BDI.BillingDocument     = $projection.VbelnVF 
                                                     and _BDI.BillingDocumentItem = $projection.PosnrVF 
{
  key vbeln_vf                                                                                                  as VbelnVF,
      posnr_vf                                                                                                  as PosnrVF,                           
      _BDI._BillingDocument._SalesOrganization.SalesOrganization                                                as Vkorg,
      _BDI._BillingDocument._SalesOrganization._Text[Language = $session.system_language].SalesOrganizationName as VkorgText
}

" Ex: System Language w/ Parameter
@Semantics.text: true
_Equipment._EquipmentText[ 1:Language = $session.system_language ].EquipmentName