" Case w/ Date + Mod
case mod( dats_days_between( cast( '20250101' as abap.dats ), $projection.due_date ), 7 )
    when 0 then 'Monday'
    when 1 then 'Tuesday'
    when 2 then 'Wednesday'
    when 3 then 'Thursday'
    when 4 then 'Friday'
    when 5 then 'Saturday'
    when 6 then 'Sunday'
end as due_date_t

" Case w/ Indicator
case matdoc.shkzg
   when 'H' then - matdoc.menge
   when 'S' then + matdoc.menge
end as menge

" Case w/ String
case mara.meins
    when 'ST' then 'X'
    else '' 
end as unit