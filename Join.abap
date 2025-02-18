" Cross Join
define view ZSM_I_001 
as select from ekko 
cross join ekpo on ekpo.ebeln = ekko.ebeln { 
  ekko.ebeln,
  ekpo.ebelp      
}

" Inner Join
define view ZSM_I_001 
as select from ekko 
inner join ekpo on ekpo.ebeln = ekko.ebeln { 
  ekko.ebeln,
  ekpo.ebelp      
}

" Left Outer Join: Default
define view ZSM_I_001 
as select from ekko 
left outer join ekpo on ekpo.ebeln = ekko.ebeln { 
  ekko.ebeln,
  ekpo.ebelp      
}

" Left Outer Join: Case 
define view ZSM_I_001 
as select from ZSM_T_001 as T1 
left outer join ZSM_T_002 as T2 on T2.matnr = T1.matnr and T2.lgort = T1.lgort  
left outer join ZSM_T_003 as T3 on T3.matnr = T1.matnr and T3.lgort = T1.lgort { 
  T1.matnr,
  case when T2.menge is null then T3.menge
       else T2.menge as Menge     
}

" Left Outer Join: Coalesce (Check If Exist Property I & Property II) 
define view ZSM_I_001 
as select from ZSM_T_001 as T1 
left outer join ZSM_T_002 as T2 on T2.matnr = T1.matnr and T2.lgort = T1.lgort  
left outer join ZSM_T_003 as T3 on T3.matnr = T1.matnr and T3.lgort = T1.lgort { 
  T1.matnr,
  coalesce(T2.menge,T3.menge) as Menge
}

" Right Outer Join
define view ZSM_I_001 
as select from ekko 
right outer join ekpo on ekpo.ebeln = ekko.ebeln { 
  ekko.ebeln,
  ekpo.ebelp      
}