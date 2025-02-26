" Case w/ Date + Mod: Get the Day of the Week for a Given Date
" Note: The 'dats_days_between' Function is used to Calculate the Number of Days Between Two Dates
case mod( dats_days_between( cast( '20250101' as abap.dats ), $projection.due_date ), 7 )
    when 0 then 'Monday'
    when 1 then 'Tuesday'
    when 2 then 'Wednesday'
    when 3 then 'Thursday'
    when 4 then 'Friday'
    when 5 then 'Saturday'
    when 6 then 'Sunday'
end as DayOfWeek 

" Case w/ Indicator: Get the Indicator Value
case matdoc.shkzg
   when 'H' then - matdoc.menge
   when 'S' then + matdoc.menge
end as Quantity

" Case w/ String: Get the Unit of Measure
case mara.meins
    when 'ST' then 'X'
    else '' 
end as UOM