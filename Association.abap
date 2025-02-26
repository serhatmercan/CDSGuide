"   Cardinality   Minumum   Maximum 
"      [1]           0         1
"     [0..1]         0         1
"     [1..1]         1         1
"     [0..*]         0      Unlimited
"     [1..*]         1      Unlimited

" Default Cardinality
define view ZSM_I_001 
  as select from mara         as Mara 
  association [0..1] to makt  as _Makt on _Makt.Matnr = Mara.Matnr
{
    key Mara.matnr  as MaterialNo,
        _Makt.maktx as MaterialText
}

" Multi Cardinality
define view ZSM_I_001
  as select from snwd_so          as SO
  association [1..*] to snwd_so_i as _SOI on _SOI.parent_key = $projection.SalesOrder
  association [1..1] to snwd_bpa  as _BPA on _BPA.node_key   = $projection.SalesOrder
{
  key SO.node_key         as SalesOrder,
      SO.so_id            as SalesOrderID,
      SO.currency_code    as Currency,
      SO.gross_amount     as GrossAmount,
      SO.net_amount       as NetAmount,

      _SOI.tax_amount     as TaxAmount
      _BPA.phone_number   as PhoneNumber
}

" Filter Cardinality
define view ZSM_I_001
  as select from snwd_pd            as Product
  association [0..*] to snwd_texts  as _ProductText on _ProductText.parent_key = $projection.ProductNameGuid
{
  key Product.node_key                                        as ProductKey,
      Product.product_id                                      as ProductID,
      Product.name_guid                                       as ProductNameGuid,
      _ProductText[language = $session.system_language].text  as ProductName
}

" Parent Child Cardinality
define view entity ZSM_I_001
  as select from zsm_t_0001       as T1
  association to parent ZOG_I_002 as _T2 on _T2.UUID = $projection.UUID
{
  key T1.UUID,      
      _T2
}

" Projection Cardinality
define view ZSM_I_001 
  as select from mara as Mara 
  association [0..1] to makt as _Makt on _Makt.matnr = $projection.MaterialNo
{
    Mara.matnr  as MaterialNo,
    _Makt.maktx as MaterialText
}