amount = '28.1907'

" Case
cast(   
    case mara.meins
         when 'ST' then 'X'
         else '' 
    end as xfeld preserving type ) as Unit

" Character
cast(amount as abap.char( 20 )) as AmountChar " => 28.1907             (20 Characters)

" Currency
cast(wrbtr as abap.curr( 20, 3 )) as Curr

" Currency Conversion
" Table: T0001
" --> Budat: 20250220 & Waers: EUR & Wrbtr: 100
" <-- Exchange Rate: 1.10 & DocumentAmount: 110
@Semantics.amount.currencyCode: 'DocumentCurrency'
sum( currency_conversion( amount                => T0001.Wrbtr,
                          exchange_rate_date    => T0001.Budat,
                          round                 => 'X',
                          source_currency       => T0001.Waers,
                          target_currency       => $projection.DocumentCurrency,
                          error_handling        => 'SET_TO_NULL' ) )                as DocumentAmount,
cast('USD' as abap.cuky( 5 ))                                                       as DocumentCurrency

" Date - I
cast( '00000000' as abap.dats) as zdate

" Date - II
cast( '20241114' as abap.dats ) " =>  2024-11-14 || YYYY-MM-DD

" Date & Time To Timestamp
" StartDate (DATS)              : 20250221 
" StartTime (TIMS)              : 121500
" Timestamp (YYYYMMDDHHMMSS)    : 20250221121500
dats_tims_to_tstmp( StartDate,
                    StartTime,
                    abap_system_timezone( $session.client, 'NULL' ),
                    $session.client,
                    'NULL' ) as Timestamp

" Decimal - I
cast(amount as abap.dec( 10, 2 )) " => 28.19

" Decimal - II
cast( cast( mmh.mcount as abap.dec(16,3) ) / 1000 as abap.dec(16,3) ) as Total_Height

" Decimal - III
0.25 AS DecimalValue " => 0.25

" Decimal - IV
" --> '99.75'
" <-- 99
cast(get_numeric_value(Pricing.ConditionQuantity) as abap.dec(5,0)) as ConditionQuantity

" Decimal - Float
" --> 12345.678
" <-- 1.2345678E+4
cast( nsum.ScheduledQuantity as abap.decfloat34 )

" Default Type
'1000000017' as MatNumc " => NUMC 11 => 1000000017

" Floating Point Number (FLTP)
cast( 0 as abap.fltp ) as kdv

" Floating Point Number (FLTP) -> Decimal (DEC)
" --> 23.456789
" <-- 23.457
fltp_to_dec( diptemp.par_fltp as abap.dec( 13, 3 ) ) as Temperature

" Integer
cast(0 as abap.int2) as intvalue

" Numeric
" --> YYYYMMDD: 20250213 
" <-- YYYYMM  : 202502
cast(substring(vbep.edatu, 1, 6) as abap.numc(6)) as endmn

" Standard Type
cast('1000000028' as matnr) as MatnrEx " => CHAR 40 : '0000000000000000000000000000001000000028'

" Time
" --> '123456' || '999999'
" <--  123456  ||  000000 
tims_to_timn( Main.DocumentTime, 'NULL' )
tims_to_timn( cast( '000000' as abap.tims ), 'NULL' )

" Timestamp
cast ( dip.etmstm as timestamp ) as item_time

" Timestamp Current
" --> 21 February 2025, 14:50:45.123 UTC
" <-- 20250221145045.123
tstmp_current_utctimestamp()

" Timestamp to Date (YYYYMMDDHHMMSS -> YYYYMMDD)
" --> 20240212083000 (2024-02-12 08:30:00)
" <-- 20240212       (12 February 2024)
tstmp_to_dats( cast( dip.etmstm as abap.dec( 15, 0 )),
                     abap_system_timezone( $session.client, 'NULL' ),
                     $session.client,
                     'NULL' ) as StartDate

" Timestamp to Time (YYYYMMDDHHMMSS -> HHMMSS)
" --> 20250217153000    (2025-02-17 15:30:00)
" <-- 153000            (15:30:00)
tstmp_to_tims( cast(ftmstm as abap.dec( 15, 0 )), 
                    abap_system_timezone( $session.client,'NULL' ), 
                    $session.client, 'NULL' ) as StartTime

" Quantity
" --> 9876543.21
" <-- 9876543.210
cast( 0 as abap.quan( 13, 3 )) as lfimg_vl