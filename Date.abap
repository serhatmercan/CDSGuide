" Date Functions
BirthDate = '20241114' " YYYYMMDD

" Add & Subtract Days
" dats_add_days( date, days, timezone )
dats_add_days(BirthDate, 10,  null)    " => 2024-11-24
dats_add_days(BirthDate, -10, null)    " => 2024-11-04

" Add & Subtract Days w/ Projection
" dats_add_days( date, days, timezone, projection )
" --> projection.p_wadat = '20241114'
" --> projection.p_valtg = 10
" <-- DueDate = '20241124'
dats_add_days( $projection.p_wadat, cast( $projection.p_valtg as int4 ), 'INITIAL' ) as DueDate

" Add & Subtract Months
" dats_add_months( date, months, timezone )
dats_add_months(BirthDate, 2, null)    " => 2025-01-24
dats_add_months(BirthDate, -2, null)   " => 2024-09-24

" Calculate Between Days
" dats_days_between( date1, date2 )
dats_days_between(BirthDate, cast('20241104' as abap.dats)) " => -10
dats_days_between(BirthDate, cast('20241124' as abap.dats)) " => 10

dats_days_between(cast( $session.system_date as abap.dats ), TransactionCashFlow.PaymentDate) as abap.dec( 10, 2 )  

" Check Date
" dats_is_valid( date )
dats_is_valid(BirthDate) " => 0: False || 1: True

" Convert Date & Time To Timestamp
" StartDate (DATS)              : 20250221 
" StartTime (TIMS)              : 121500
" Timestamp (YYYYMMDDHHMMSS)    : 20250221121500
dats_tims_to_tstmp( StartDate,
                    StartTime,
                    abap_system_timezone( $session.client, 'NULL' ),
                    $session.client,
                    'NULL' ) as Timestamp