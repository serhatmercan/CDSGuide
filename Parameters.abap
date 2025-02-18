@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Parameters'

define view ZSM_I_002
with parameters p_meins: meins, p_mtart: mtart 
as select from mara {
    matnr,
    matkl,
    meins,
    
    cast(substring($parameters.p_datab,1,6) as abap.numc(6)) as spmon " Optional
}
where meins  = $parameters.p_meins
  and mtart  = $parameters.p_mtart
  and datbi >= $parameters.p_datab
  and matkl  = 'AP'   

" Call Another Parameters View
define root view entity ZSD_I_0002
  with parameters p_datab : abap.dats,
                  p_datbi : abap.dats
  as select from zsd_i_0001 ( p_datab : $parameters.p_datab,
                              p_datbi : $parameters.p_datbi )
{
  key zsd_i_0001.vkorg,
  key zsd_i_0001.matnr,
  key zsd_i_0001.spmon,
  
  sum( zsd_i_0001.kbetr ) as kbetr
}
group by
  zsd_i_0001.bonus_group,
  zsd_i_0001.vkorg,
  zsd_i_0001.matnr,
  zsd_i_0001.spmon

" Call Another Parameters View w/ Left Outer Join
define root view entity ZSD_I_0003
  left outer join zsd_i_0002 ( p_meins: 'M3' ) as i0002
{
  i0002.KonsimentoDate
}