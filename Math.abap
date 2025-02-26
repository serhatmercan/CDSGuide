" Math Operations in CDS
Amount = 17.856 as ...

" Abs: Absolute Value
abs(Amount) as AmountABS    " => 17.856

" Add & Subtract & Multiply
Amount + 10                 " => 27.856
Amount - 10                 " => 7.856
Amount * 10                 " => 178.560

" Ceil: Up Nearest Integer
ceil(Amount, 1)             " => 18

" Div: Division
div(Amount, 5)              " => 3

" Division: Division w/ Decimal
" --> 17.856 / 3
" <-- 5.952
division(Amount, 3, 2) as AmountDiv

" Floor: Down Nearest Integer
" --> 17.856
" <-- 17.8
floor(Amount, 1) as AmountFloor

" Max: Find Maximum
max( Begda ) as BeginDate

" Min: Find Minimum
min( endda ) as EndDate
min( case when o.Lictp = 'Z010' then v.Oidatto1 end ) as MinDate

" Mod: Returns the Remainder of a Number
mod(ceil(Amount), 5) as Remainder " => 3

" Numeric Value (String -> Numeric)
" --> '00015'   || '99.75'
" <-- 15        || 99.75 
get_numeric_value(Pricing.ConditionQuantity)

" Round: Rounded To The Nearest Decimal
round(Amount, 1) " => 17.9
round(Amount, 2) " => 17.87