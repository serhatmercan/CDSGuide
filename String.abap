" String Functions in ABAP
name1 = 'Dilaray'.
name2 = 'Serhat'.

" Concat: Concatenate Strings
concat(name1, name2)             " => DilaraySerhat

" Concat w/ Separator: Add Separator Between Strings
concat(concat(name1, ',', name2)) " => Dilaray,Serhat

" Concat w/ Space: Add Space Between Strings 
concat_with_space(name1, name2, 1) " => Dilaray Serhat     | 1 Character Space
concat_with_space(name1, name2, 3) " => Dilaray   Serhat   | 3 Character Space

" Left & Right: Get Left & Right Part of String 
left(name1, 2)   " => Di
right(name1, 2)  " => ay

" Left & Right: Ex
left outer join /sapsll/maritc as Maritc on Maritc.matnr           = _Sip.matnr
                                        and left(Maritc.ccngn, 17) = I_ProductPlant.Commodity

" Lpad & Rpad: Add Character to Left & Right
lpad(name1, 10, '0') " => 0000Dilaray
rpad(name2, 10, '0') " => Serhat0000

" Lowercase & Uppercase: Convert to Lower & Upper 
lowercase(name2) " => serhat
uppercase(name1) " => DILARAY

" Instr: Find Position of Character
instr(name1, 'a')   " => 4
instr(name1, 'z')   " => 0 
instr(name2, 'rh')  " => 3                                   

" Length: Find Length of String 
length(name1) " => 7

" Ltrim & Rtrim: Delete Left & Right Matched Character
ltrim(name1, 'D') " => ilaray
rtrim(name2, 't') " => Serha

" Replace: Replace Character in String
replace(name1, 'a', 'o')                " => Diloroy
replace(name1, 'Dilaray','Mır Mır' )    " => Mır Mır

" Substring: Get Substring of String
substring(name1, 2, 3) " => ila