" Table: ZSM_T_001
" Fields: VBELN, POSNR, AMOUNT, ERSDA, MENGE, ZZMENGE, BISMT, AUART
define view ZSM_I_001
as select from ZSM_T_001 {
    key vbeln,
    key posnr,

    amount
}

" All Elements - I: Select All Elements
define view ZSM_I_001
as select from ZSM_T_001 {
    *    
}

" All Elements - II: Select All Elements
define view ZSM_I_001
as select from ZSM_T_001 {
    " Insert All Elements
}

" Average & Count & Count(Distinct) & Min & Max & Sum 
select from ZSM_T_001 {
    vbeln,
    avg(amount)                 as POAverage,
    count(*)                    as POCount,
    count( distinct amount )    as POCountDistinct,
    min(amount)                 as POMin,
    max(amount)                 as POMax,
    sum(amount)                 as POSum
}
group by vbeln

" Condition: Case
select from ZSM_T_001{
    key vbeln                                   as Vbeln,
    case when T1.menge is null then T1.zzmenge
         else T1.menge 
     end                                        as Menge,
    case BillingStatus
         when 'P' then 'Paid'
         when ' ' then 
            case DeliveryStatus
                when 'D' then 'Delivered'
                when ' ' then 'Open'
                else DeliveryStatus
            end
         else BillingStatus
     end                                        as Status      
}

" Condition: Coalesce (Check If Exist Property I & Property II)
select from ZSM_T_001{
    key vbeln                                                                                                               as Vbeln,
    coalesce(menge, zzmenge)                                                                                                as Menge
    coalesce(bismt, '')                                                                                                     as Bismt,
    cast(coalesce(coalesce(zf08.kbetr * zf08.kpein, zf09.kbetr * zf09.kpein), zf14.kbetr * zf14.kpein ) as abap.dec(10,2))  as Amount
}

" Distinct
define root view entity ZSM_I_001
  as select distinct from T1
  inner join T2 on T2.number = T1.number
{
  key T1.srfxnr     as FieldI,
      T2.com_idtext as FieldII
}

" Function
define view entity ZSM_I_WORKING_DAYS
  as select from ZSM_F_WORKING_DAYS( p_client: $session.client , p_fabkl: 'PI' )
{
  key CalendarDate,
      FactoryCalendar,
      MonthFirstDate,
      MonthLastDate,
      WorkingDaysMonth,
      IsWorkingDay
}
where
  IsWorkingDay <> 0

" Group By II
select from ZSM_T_001 {
    key vbeln,
    key posnr
}
group by vbeln, posnr

" Where Condition
select from ZSM_T_001 {
    key vbeln,

    meins
}
where meins =  'ST'
  and auart <> 'Z113'
  and ersda =  $session.system_date
  and s_fiscyear = left( $session.system_date, 4 )
  and ( ekko.bsart like 'ZH%' or ekko.bsart like 'ZU%' )
  and not( likp.vbeln is null and vbrk.sfakn = '' )
   or vbap.matnr between '000000000000005000' and '000000000000006999'
   or vbrk.vbeln is null
   or funcarea is not initial

" Having Sum    
having sum(SNWD_SO.gross_amount) > 100000