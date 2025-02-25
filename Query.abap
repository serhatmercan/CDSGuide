" Table: ZSM_T_001
" Fields: VBELN, POSNR, AMOUNT, ERSDA, MENGE, ZZMENGE, BISMT, AUART
define view ZSM_I_001
as select from ZSM_T_001 {
    key vbeln,
    key posnr
    amount
}

" All Elements - I
define view ZSM_I_001
as select from ZSM_T_001 {
    *    
}

" All Elements - II
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
    key vbeln,
    case when T1.menge is null then T1.zzmenge
         else T1.menge 
     end as menge,
    case billing_status
         when 'P' then 'Paid'
         when ' ' then 
            case delivery_status
                when 'D' then 'Delivered'
                when ' ' then 'Open'
                else delivery_status
            end
         else billing_status
     end as BillingStatus      
}

" Condition: Coalesce (Check If Exist Property I & Property II)
select from ZSM_T_001{
    key vbeln,
    coalesce(menge, zzmenge) as menge
    coalesce(bismt, '')      as bismt,
    cast(coalesce(coalesce(zf08.kbetr * zf08.kpein, zf09.kbetr * zf09.kpein), zf14.kbetr * zf14.kpein ) as abap.dec(10,2)) as usd_kbetr
}

" Distinct
define root view entity ZSM_I_001
  as select distinct from a
  inner join b
  on b.number = a.number
{
  key a.srfxnr     as fieldI,
      b.com_idtext as fieldII
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
    key vbeln
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
