" Math Operations in ABAP
amount = 17.856 as ...

" Abs: Absolute Value
abs(amount) as AmountABS    " => 17.856

" Add & Subtract & Multiply
amount + 10                 " => 27.856
amount - 10                 " => 7.856
amount * 10                 " => 178.560

" Ceil: Up Nearest Integer
ceil(amount, 1)             " => 18

" Div: Division
div(amount, 5)              " => 3

" Division: Division w/ Decimal
" --> 17.856 / 3
" <-- 5.952
division(amount, 3, 2) as AmountDiv

" Floor: Down Nearest Integer
" --> 17.856
" <-- 17.8
floor(amount, 1) as AmountFloor

" Max: Find Maximum
max( begda ) as BeginDate

" Min: Find Minimum
min( endda ) as EndDate
min( case when o.lictp = 'Z010' then v.oidatto1 end ) as Amount

" Mod: Returns the Remainder of a Number
mod(ceil(amount),5)         " => 3

" Numeric Value (String -> Numeric)
" --> '00015'   || '99.75'
" <-- 15        || 99.75 
get_numeric_value(Pricing.ConditionQuantity)

" Round: Rounded To The Nearest Decimal
round(amount,1) " => 17.9
round(amount,2) " => 17.87


