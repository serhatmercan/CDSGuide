name1 = 'Dilaray'.
name2 = 'Serhat'.

" Concat: Concatenate
concat(name1, name2)             " => DilaraySerhat
concat(concat(name1, ',', name2)) " => Dilaray,Serhat

" Concat w/ Space
concat_with_space(name1, name2, 1) " => Dilaray Serhat     | 1 Character Space
concat_with_space(name1, name2, 3) " => Dilaray   Serhat   | 3 Character Space

" Left & Right
left(name1, 2)   " => Di
right(name1, 2)  " => ay

" Left & Right: Ex
left outer join /sapsll/maritc as Maritc on Maritc.matnr           = _Sip.matnr
                                        and left(Maritc.ccngn, 17) = I_ProductPlant.Commodity

" Length
length(name1) " => 7

" Ltrim & Rtrim: Delete Left & Right Matched Character
ltrim(name1, 'D') " => ilaray
rtrim(name2, 't') " => Serha

" Substring
substring(name1, 2, 3) " => ila