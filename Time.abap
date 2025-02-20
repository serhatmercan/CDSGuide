" Validation: Return => 0 || 1
tims_is_valid( Main.DocumentTime ) = 1

" Validation & Conversion
" --> '123456' || '999999' || NULL
" <--  123456  ||  000000  || 000000
case when tims_is_valid( Main.DocumentTime ) = 1 then tims_to_timn( Main.DocumentTime, 'NULL' )
                                                 else tims_to_timn( cast( '000000' as abap.tims ), 'NULL' )
end as ConvertedDocumentTime                                                 