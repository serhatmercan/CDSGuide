"   Cardinality   Minumum   Maximum 
"      [1]           0         1
"     [0..1]         0         1
"     [1..1]         1         1
"     [0..*]         0      Unlimited
"     [1..*]         1      Unlimited

" Default
define view ZSM_I_001 
  as select from mara as Mara 
  association [0..1] to makt as _Makt on _Makt.matnr = Mara.matnr
{
    Mara.matnr,
    _Makt.maktx
}

" Multi
define view ZSM_I_001
  as select from snwd_so as SO
  association [1..*] to snwd_so_i as _SOI on _SOI.parent_key = $projection.node_key
  association [1..1] to snwd_bpa  as _BPA on _BPA.node_key   = $projection.buyer_guid
{
  key SO.node_key,
      SO.so_id,
      SO.currency_code,
      SO.gross_amount,
      SO.net_amount,
      _SOI.tax_amount,
      _BPA.phone_number
}

" Filter
define view ZSM_I_001
  as select from snwd_pd as Product
  association [0..*] to snwd_texts as ProductText on ProductText.parent_key = $projection.name_guid
{
  key Product.node_key,
      Product.product_id,
      Product.name_guid,
      ProductText[language = $session.system_language].text as ProductName
}

" Parent
define view entity ZSM_I_001
  as select from zsm_t_0001       as T1
  association to parent ZOG_I_002 as _T2 on _T2.UUID = $projection.UUID
{
  key T1.UUID,
  _T2
}

" Projection
define view ZSM_I_001 
  as select from mara as Mara 
  association [0..1] to makt as _Makt on _Makt.matnr = $projection.MaterialNo
{
    Mara.matnr  as MaterialNo,
    _Makt.maktx as MaterialText
}