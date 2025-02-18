" Union
define view ZSM_CDS_TEST_VIEW 
as select from ZSM_T_001
{
    column1
} 
union all select from ZSM_T_002
{
    column1
}

" Union: Unique Values
union select from ZSM_T_002

" Add: Where Condition
as select from ZSM_T_001
{
    column1
} 
where 
    column1 > 10
union all select from ZSM_T_002
{
    column1
}
where 
    column1 < 10

