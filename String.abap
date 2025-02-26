" String Functions in ABAP
Name1 = 'Dilaray'.
Name2 = 'Serhat'.

" Concat: Concatenate Strings
concat(Name1, Name2)             " => DilaraySerhat

" Concat w/ Separator: Add Separator Between Strings
concat(concat(Name1, ',', Name2)) " => Dilaray,Serhat

" Concat w/ Space: Add Space Between Strings 
concat_with_space(Name1, Name2, 1) " => Dilaray Serhat     | 1 Character Space
concat_with_space(Name1, Name2, 3) " => Dilaray   Serhat   | 3 Character Space

" Left & Right: Get Left & Right Part of String 
left(Name1, 2)   " => Di
right(Name1, 2)  " => ay

" Left & Right: Ex
left outer join /sapsll/maritc as Maritc on Maritc.matnr           = _Sip.matnr
                                        and left(Maritc.ccngn, 17) = I_ProductPlant.Commodity

" Lpad & Rpad: Add Character to Left & Right
lpad(Name1, 10, '0') " => 0000Dilaray
rpad(Name2, 10, '0') " => Serhat0000

" Lowercase & Uppercase: Convert to Lower & Upper 
lowercase(Name2) " => serhat
uppercase(Name1) " => DILARAY

" Instr: Find Position of Character
instr(Name1, 'a')   " => 4
instr(Name1, 'z')   " => 0 
instr(Name2, 'rh')  " => 3                                   

" Length: Find Length of String 
length(Name1) " => 7

" Ltrim & Rtrim: Delete Left & Right Matched Character
ltrim(Name1, 'D') " => ilaray
rtrim(Name2, 't') " => Serha

" Replace: Replace Character in String
replace(Name1, 'a', 'o')                " => Diloroy
replace(Name1, 'Dilaray','Mır Mır' )    " => Mır Mır

" Substring: Get Substring of String
substring(Name1, 2, 3) " => ila