" Cross Join: The cross join is a join operation that produces the Cartesian product of two tables.
define view ZSM_I_001 
  as select from ekko 
  cross join ekpo on ekpo.ebeln = ekko.ebeln { 
    ekko.ebeln,
    ekpo.ebelp      
  }

" Inner Join: The inner join is a join operation that produces the result of the intersection of two tables.
define view ZSM_I_001 
  as select from ekko 
  inner join ekpo on ekpo.ebeln = ekko.ebeln { 
    ekko.ebeln,
    ekpo.ebelp      
}

" Left Outer Join: The left outer join is a join operation that produces the result of the intersection of two tables, plus all the rows from the left table that do not have a match in the right table.
define view ZSM_I_001 
  as select from ekko 
  left outer join ekpo on ekpo.ebeln = ekko.ebeln { 
    ekko.ebeln,
    ekpo.ebelp      
}

" Left Outer Join: Case When (Check If Exist Property I & Property II)
define view ZSM_I_001 
  as select from ZSM_T_001 as T1 
  left outer join ZSM_T_002 as T2 on T2.matnr = T1.matnr and T2.lgort = T1.lgort  
  left outer join ZSM_T_003 as T3 on T3.matnr = T1.matnr and T3.lgort = T1.lgort { 
    T1.matnr                                  as MaterialNumber,
    case when T2.menge is null then T3.menge
         else T2.menge
     end                                      as Quantity     
}

" Left Outer Join: Coalesce (Check If Exist Property I & Property II) 
define view ZSM_I_001 
  as select from ZSM_T_001  as T1 
  left outer join ZSM_T_002 as T2 on T2.matnr = T1.matnr and T2.lgort = T1.lgort  
  left outer join ZSM_T_003 as T3 on T3.matnr = T1.matnr and T3.lgort = T1.lgort { 
    T1.matnr                    as MaterialNumber,
    coalesce(T2.menge,T3.menge) as Quantity
}

" Right Outer Join: The right outer join is a join operation that produces the result of the intersection of two tables, plus all the rows from the right table that do not have a match in the left table.
define view ZSM_I_001 
  as select from ekko 
  right outer join ekpo on ekpo.ebeln = ekko.ebeln { 
    ekko.ebeln,
    ekpo.ebelp      
}