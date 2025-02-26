CLASS zsm_cl_total_order DEFINITION
 PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zsm_cl_total_order IMPLEMENTATION.

* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method zsm_cl_total_order->IF_SADL_EXIT_CALC_ELEMENT_READ~CALCULATE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_ORIGINAL_DATA               TYPE        STANDARD TABLE
* | [--->] IT_REQUESTED_CALC_ELEMENTS     TYPE        TT_ELEMENTS
* | [<-->] CT_CALCULATED_DATA             TYPE        STANDARD TABLE
* | [!CX!] CX_SADL_EXIT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_data TYPE TABLE OF zsd_i_order_detail.

    lt_data = CORRESPONDING #( it_original_data ).

    CHECK lt_data IS NOT INITIAL.

    " Delivery Informations
    SELECT vgbel_vl,
           vgpos_vl,
           vbeln_vl,
           posnr_vl,
           lfimg_vl,
           ntgew_vl,
           volum_vl,
           lgmng_vl
      FROM zsd_i_delivery
      FOR ALL ENTRIES IN @lt_data
      WHERE vgbel_vl EQ @lt_data-vbeln_va
        AND vgpos_vl EQ @lt_data-posnr_va
      INTO TABLE @DATA(lt_delivery).
    
    " Delivery & Invoice Informations  
    IF lt_delivery[] IS NOT INITIAL.        
        SELECT vgbel_vf,
               vgpos_vf,
               fkimg,
               netwr_vf,
               kzwi1_vf,
               kzwi2_vf,
               kzwi3_vf,
               kzwi4_vf,
               kzwi6_vf,
               fklmg
         FROM zsd_i_invoice
         FOR ALL ENTRIES IN @lt_delivery
         WHERE vgbel_vf EQ @lt_delivery-vbeln_vl
           AND vgpos_vf EQ @lt_delivery-posnr_vl
           AND fksto    EQ @space
           AND sfakn    EQ @space
         INTO TABLE @DATA(lt_inv_dlv).
    ENDIF.

    " Order & Invoice Informations
    SELECT vgbel_vf,
           vgpos_vf,
           fkimg,
           netwr_vf,
           kzwi1_vf,
           kzwi2_vf,
           kzwi3_vf,
           kzwi4_vf,
           kzwi6_vf,
           fklmg
      FROM zsd_i_inv_ord
      FOR ALL ENTRIES IN @lt_data
      WHERE vgbel_vf EQ @lt_data-vbeln_va
        AND vgpos_vf EQ @lt_data-posnr_va
        AND fksto    EQ @space
        AND sfakn    EQ @space
      INTO TABLE @DATA(lt_inv_ord).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      LOOP AT lt_delivery INTO DATA(ls_delivery) WHERE vgbel_vl = <lfs_data>-vbeln_va
                                                   AND vgpos_vl = <lfs_data>-posnr_va.
        <lfs_data>-lfimg_vl += ls_delivery-lfimg_vl.
        <lfs_data>-ntgew_vl += ls_delivery-ntgew_vl.
        <lfs_data>-volum_vl += ls_delivery-volum_vl.
        <lfs_data>-lgmng_vl += ls_delivery-lgmng_vl.
      ENDLOOP.

      LOOP AT lt_inv_ord INTO DATA(ls_inv_ord) WHERE vgbel_vf = <lfs_data>-vbeln_va
                                                 AND vgpos_vf = <lfs_data>-posnr_va.
        <lfs_data>-fkimg    += ls_inv_ord-fkimg.
        <lfs_data>-netwr_vf += ls_inv_ord-netwr_vf.
        <lfs_data>-kzwi1_vf += ls_inv_ord-kzwi1_vf.
        <lfs_data>-kzwi2_vf += ls_inv_ord-kzwi2_vf.
        <lfs_data>-kzwi3_vf += ls_inv_ord-kzwi3_vf.
        <lfs_data>-kzwi4_vf += ls_inv_ord-kzwi4_vf.
        <lfs_data>-kzwi6_vf += ls_inv_ord-kzwi6_vf.
        <lfs_data>-fklmg    += ls_inv_ord-fklmg.
      ENDLOOP.

      LOOP AT lt_inv_dlv INTO DATA(ls_inv_dlv) WHERE vgbel_vf = <lfs_data>-vbeln_vl
                                                 AND vgpos_vf = <lfs_data>-posnr_vl.
        <lfs_data>-fkimg    += ls_inv_dlv-fkimg.
        <lfs_data>-netwr_vf += ls_inv_dlv-netwr_vf.
        <lfs_data>-kzwi1_vf += ls_inv_dlv-kzwi1_vf.
        <lfs_data>-kzwi2_vf += ls_inv_dlv-kzwi2_vf.
        <lfs_data>-kzwi3_vf += ls_inv_dlv-kzwi3_vf.
        <lfs_data>-kzwi4_vf += ls_inv_dlv-kzwi4_vf.
        <lfs_data>-kzwi6_vf += ls_inv_dlv-kzwi6_vf.
        <lfs_data>-fklmg    += ls_inv_dlv-fklmg.
      ENDLOOP.

      CASE <lfs_data>-lictp.
        WHEN 'Z010'.
          <lfs_data>-zadklno   = <lfs_data>-oih_licin_va.
          <lfs_data>-zadkln    = <lfs_data>-lctxt_va.
          <lfs_data>-zadklt    = <lfs_data>-datab_va.
          <lfs_data>-zadkllgt  = <lfs_data>-datbi_va.
        WHEN 'Z011'.
          <lfs_data>-zihrlisno = <lfs_data>-oih_licin_va.
          <lfs_data>-zihrln    = <lfs_data>-lctxt_va.
          <lfs_data>-zihrlt    = <lfs_data>-datab_va.
          <lfs_data>-zihrllgt  = <lfs_data>-datbi_va.
        WHEN 'Z012'.
          <lfs_data>-zmdnyno   = <lfs_data>-oih_licin_va.
          <lfs_data>-zmdynx    = <lfs_data>-lctxt_va.
          <lfs_data>-zmdnyt    = <lfs_data>-datab_va.
          <lfs_data>-zmdnylgt  = <lfs_data>-datbi_va.
        WHEN 'Z020'.
          <lfs_data>-zlpgltno  =  <lfs_data>-oih_licin_va.
          <lfs_data>-zlpgln    =  <lfs_data>-lctxt_va.
          <lfs_data>-zlpglt    =  <lfs_data>-datab_va.
          <lfs_data>-zlpglgt   =  <lfs_data>-datbi_va.
      ENDCASE.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_data ).
  ENDMETHOD.    

* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method zsm_cl_total_order->IF_SADL_EXIT_CALC_ELEMENT_READ~GET_CALCULATION_INFO
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_REQUESTED_CALC_ELEMENTS     TYPE        TT_ELEMENTS
* | [--->] IV_ENTITY                      TYPE        STRING
* | [<---] ET_REQUESTED_ORIG_ELEMENTS     TYPE        TT_ELEMENTS
* | [!CX!] CX_SADL_EXIT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.