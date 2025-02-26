" Description: ABAP Program to Demonstrate the Usage of CDS Views in ABAP
REPORT zsm_p_001.

START-OF-SELECTION.

  SELECT *
    FROM zsm_cds_001
    INTO TABLE @DATA(lt_cds). " SQL View Name: w/ Mandt

  SELECT *
   FROM ZSM_I_001
   INTO TABLE @DATA(lt_view). " DDL View Name: w/out Mandt

  SELECT *
    FROM zsm_v_002( p_meins = 'ST' )
    INTO TABLE @DATA(lt_parameters_view)." w/ Parameters