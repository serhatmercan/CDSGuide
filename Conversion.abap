" Conversion Functions      
Amount = '28.1907'

" Case
cast(   
    case mara.meins
         when 'ST' then 'X'
         else '' 
    end as xfeld preserving type ) as Unit

" Character (CHAR)
" --> 28.1907
" <-- 28.1907             (20 Characters)
cast(Amount as abap.char( 20 )) as AmountChar

" Currency (CUKY)
cast(Wrbtr as abap.curr( 20, 3 )) as Currency

" Currency Conversion
" Table: T0001
" --> Budat: 20250220 
" --> Waers: EUR 
" --> Wrbtr: 100
" --- Exchange Rate: 1.10
" <-- DocumentAmount: 110
@Semantics.amount.currencyCode: 'DocumentCurrency'
sum( currency_conversion( amount                => T0001.Wrbtr,
                          exchange_rate_date    => T0001.Budat,
                          round                 => 'X',
                          source_currency       => T0001.Waers,
                          target_currency       => $projection.DocumentCurrency,
                          error_handling        => 'SET_TO_NULL' ) )                as DocumentAmount,
cast('USD' as abap.cuky( 5 ))                                                       as DocumentCurrency

" Date - I (YYYYMMDD -> YYYY-MM-DD)
" --> 00000000
" <-- 0000-00-00
cast( '00000000' as abap.dats) as Date

" Date - II (YYYYMMDD -> YYYY-MM-DD)
" --> 20250221
" <-- 2025-02-21
cast( '20241114' as abap.dats ) as Date

" Date & Time To Timestamp (DATS & TIMS -> YYYYMMDDHHMMSS)
" --> StartDate: 20250221 & StartTime: 121500
" <-- Timestamp: 20250221121500
dats_tims_to_tstmp( StartDate,
                    StartTime,
                    abap_system_timezone( $session.client, 'NULL' ),
                    $session.client,
                    'NULL' ) as Timestamp

" Decimal - I (DEC)
" --> 28.1907
" <-- 28.19
cast(Amount as abap.dec( 10, 2 )) as AmountDec

" Decimal - II (DEC)
" --> 1000
" <-- 1
cast( cast( mmh.mcount as abap.dec(16,3) ) / 1000 as abap.dec(16,3) ) as TotalHeight

" Decimal - III (DEC)
" --> 0.25  
" <-- 0.25    
0.25 as DecimalValue

" Decimal - IV (DEC)
" --> '99.75'
" <-- 99
cast(get_numeric_value(Pricing.ConditionQuantity) as abap.dec(5,0)) as ConditionQuantity

" Decimal - Float
" --> 12345.678
" <-- 1.2345678E+4
cast( nsum.ScheduledQuantity as abap.decfloat34 ) as ScheduledQuantity

" Default Type (Default)
" -->                              1000000017
" <-- 1000000017    
cast( '1000000017' as abap.default ) as MatNumd " => CHAR 40 : '1000000017'

" Floating Point Number (FLTP)
cast( 0 as abap.fltp ) as KDV

" Floating Point Number (FLTP) -> Decimal (DEC)
" --> 23.456789
" <-- 23.457
fltp_to_dec( diptemp.par_fltp as abap.dec( 13, 3 ) ) as Temperature

" Integer (INT1)
cast(0 as abap.int2) as IntValue

" Numeric (NUMC)
" --> YYYYMMDD: 20250213 
" <-- YYYYMM  : 202502
cast(substring(vbep.edatu, 1, 6) as abap.numc(6)) as Endmn

" Standard Type (STANDARD)  
" --> '1000000028'
" <-- '0000000000000000000000000000001000000028' (CHAR40)
cast('1000000028' as matnr) as MatnrEx

" Time (TIMS)
" --> '123456' || '999999'
" <--  123456  ||  000000 
tims_to_timn( Main.DocumentTime, 'NULL' )
tims_to_timn( cast( '000000' as abap.tims ), 'NULL' )

" Timestamp (TIMESTAMP)
" --> 2025-02-21 14:50:45.123
" <-- 20250221145045.123
cast ( dip.etmstm as timestamp ) as ItemTime

" Timestamp Current (UTC)
" --> 2025-02-21 14:50:45.123 UTC
" <-- 20250221145045.123    
tstmp_current_utctimestamp() as CurrentTime

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

" Quantity (QUAN)
" --> 9876543.21
" <-- 9876543.210
cast( 0 as abap.quan( 13, 3 )) as Quantity

" Unit
" --> Distance: 100
" --> DistanceUnit: 'KM'
" --> TargetUnit: 'MI or cast( 'MI' as abap.unit )
" <-- 62.1371
unit_conversion( quantity    => Distance,
                 source_unit => DistanceUnit,
                 target_unit => TargetUnit ) as DistanceMI