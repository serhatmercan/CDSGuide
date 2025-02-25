CLASS ZSM_CL_IM_QUERY DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider.
    INTERFACES if_rap_query_request.
  PROTECTED SECTION.
  PRIVATE SECTION.
    
    METHODS _get_data
        IMPORTING
            !io_request TYPE REF TO if_rap_query_request
        EXPORTING
            !et_data    TYPE zsm_tt_0001.      

    methods _get_goods_movement
        IMPORTING
            !io_filter TYPE REF TO if_rap_query_filter
        EXPORTING
            !et_data   TYPE zsm_tt_0002.
ENDCLASS.

CLASS ZSM_CL_IM_QUERY IMPLEMENTATION.

* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZSM_CL_IM_QUERY->IF_RAP_QUERY_PROVIDER~SELECT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_REQUEST                     TYPE REF TO IF_RAP_QUERY_REQUEST
* | [--->] IO_RESPONSE                    TYPE REF TO IF_RAP_QUERY_RESPONSE
* | [!CX!] CX_RAP_QUERY_PROV_NOT_IMPL
* | [!CX!] CX_RAP_QUERY_PROVIDER
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD if_rap_query_provider~select.
    DATA: lt_0001                    TYPE TABLE OF zsm_s_0001,
          lt_docitem_guid            TYPE cpet_docitemguid_tab,
          lt_formdoc                 TYPE cpet_formdoc_tab,
          lt_perioddtout             TYPE cpet_perioddtout_tab,
          lt_termgrpout              TYPE cpet_termgrpout_tab,
          lv_total_number_of_records TYPE int8.

    IF io_request->is_data_requested( ).
      DATA(lv_top) = io_request->get_paging( )->get_page_size( ).
      
      lv_top = COND #( WHEN lv_top < 0 THEN 1 ELSE lv_top ).

      DATA(lv_skip) = io_request->get_paging( )->get_offset( ).
      DATA(lt_sort) = io_request->get_sort_elements( ).

      LOOP AT lt_sort INTO DATA(ls_sort).
        DATA(lv_orderby) = COND string( WHEN ls_sort-descending EQ abap_true
                                        THEN |{ lv_orderby } { ls_sort-element_name } DESCENDING |
                                        ELSE |{ lv_orderby } { ls_sort-element_name } ASCENDING | ).
      ENDLOOP.

      lv_orderby = COND #( WHEN lv_orderby IS INITIAL THEN 'PurchaseOrder' ELSE lv_orderby ).

      DATA(lv_conditions) = io_request->get_filter( )->get_as_sql_string( ).

      SELECT *
        FROM zsm_i_po_nom AS t1
        WHERE (lv_conditions)
          AND NOT EXISTS ( SELECT *
                             FROM oij_el_ticket_i
                             WHERE ticket_key     EQ t1~nominationticketkey
                               AND ticket_item    EQ t1~nominationticketitem
                               AND ticket_purpose EQ '5' )
        ORDER BY (lv_orderby)
        UP TO @lv_top ROWS OFFSET @lv_skip 
        INTO TABLE @DATA(lt_purch_nom).

      IF lt_purch_nom IS NOT INITIAL.  
        SELECT * 
          FROM zsm_i_po_inv  
          FOR ALL ENTRIES IN @lt_purch_nom
          WHERE purchaseorder     EQ @lt_purch_nom-purchaseorder
            AND purchaseorderitem EQ @lt_purch_nom-purchaseorderitem
          INTO TABLE @DATA(lt_po_inv).
      ENDIF.    

      TRY.
          IF io_request->is_total_numb_of_rec_requested(  ).
            lv_total_number_of_records = 10000.
            io_response->set_total_number_of_records( lv_total_number_of_records ).
          ENDIF.

          lt_docitem_guid = CORRESPONDING #( lt_purch_nom ).

          CALL FUNCTION 'CPE_FORMULA_ALL_READ_MULTI_DB'
            EXPORTING
              it_docitem_guid      = lt_docitem_guid
            IMPORTING
              et_formdoc           = lt_formdoc
              et_termgrpout        = lt_termgrpout
              et_perioddtout       = lt_perioddtout
            EXCEPTIONS
              nothing_found        = 1
              formula_part_missing = 2
              OTHERS               = 3.
          IF sy-subrc <> 0.
          ENDIF.

          SORT: lt_po_inv      BY purchaseorder purchaseorderitem,
                lt_formdoc     BY docitem_guid,
                lt_termgrpout  BY forminput_guid,
                lt_perioddtout BY perioddtout_guid.

          LOOP AT lt_purch_nom INTO DATA(ls_purch_nom).
            DATA(ls_0001) = CORRESPONDING #( ls_purch_nom ).

            READ TABLE lt_po_inv INTO DATA(ls_zsm_i_po_inv) WITH KEY purchaseorder      = ls_purch_nom-purchaseorder
                                                                     purchaseorderitem  = ls_purch_nom-purchaseorderitem 
                                                            BINARY SEARCH.
            IF sy-subrc EQ 0.
              MOVE-CORRESPONDING ls_zsm_i_po_inv TO ls_0001.
            ENDIF.

            READ TABLE lt_formdoc INTO DATA(ls_formdoc) WITH KEY docitem_guid = ls_purch_nom-docitem_guid.
            IF sy-subrc EQ 0.
              LOOP AT lt_termgrpout INTO DATA(ls_termgrpout) WHERE forminput_guid = ls_formdoc-forminput_guid.
                IF ls_termgrpout-provis NE space.
                    MOVE-CORRESPONDING ls_termgrpout TO ls_0001.
                ELSE.
                    ls_termgrpout = CORRESPONDING #( ls_0001 MAPPING termrate_df34_f = termrate_df34 
                                                                     termcurr_f      = termcurr 
                                                                     termprun_f      = termprun).
                ENDIF.
              ENDLOOP.

              LOOP AT lt_perioddtout INTO DATA(ls_perioddtout) WHERE perioddtout_guid = ls_purch_nom-docitem_guid.
                IF ls_termgrpout-provis NE space.
                  ls_0001-firsttimestamp    = ls_perioddtout-firsttimestamp+0(10).
                  ls_0001-lasttimestamp     = ls_perioddtout-lasttimestamp+0(10).
                  ls_0001-refdate           = ls_perioddtout-refdate.
                ELSE.
                  ls_0001-firsttimestamp_f  = ls_perioddtout-firsttimestamp+0(10).
                  ls_0001-lasttimestamp_f   = ls_perioddtout-lasttimestamp+0(10).
                  ls_0001-refdate_f         = ls_perioddtout-refdate.
                ENDIF.
              ENDLOOP.
            ENDIF.

            APPEND ls_0001 TO lt_0001.
          ENDLOOP.

          io_response->set_data( lt_0001 ).

        CATCH cx_root INTO DATA(lo_exception).
          DATA(lv_exception_message) = cl_message_helper=>get_latest_t100_exception( lo_exception )->if_message~get_longtext( ).
      ENDTRY.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZSM_CL_IM_QUERY->IF_RAP_QUERY_PROVIDER~SELECT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_REQUEST                     TYPE REF TO IF_RAP_QUERY_REQUEST
* | [--->] IO_RESPONSE                    TYPE REF TO IF_RAP_QUERY_RESPONSE
* | [!CX!] CX_RAP_QUERY_PROV_NOT_IMPL
* | [!CX!] CX_RAP_QUERY_PROVIDER
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD if_rap_query_provider~select.
    DATA: lt_po_deadline TYPE STANDARD TABLE OF zsm_c_po,
          lt_po_goods    TYPE STANDARD TABLE OF zsm_c_po_item.

    DATA(lo_paging)             = io_request->get_paging( ).
    DATA(lt_filter_condition)   = io_request->get_filter( )->get_as_ranges( ).
    DATA(lt_requested_fields)   = io_request->get_requested_elements( ).
    DATA(lv_offset)             = lo_paging->get_offset( ).
    DATA(lv_page_size)          = lo_paging->get_page_size( ).

    CASE io_request->get_entity_id( ) .
      WHEN 'ZSM_C_PO'.
        _get_data( EXPORTING io_request = io_request
                   IMPORTING et_data    = DATA(lt_line_data) ).

        lt_po_deadline = VALUE #( FOR ls_data IN lt_line_data ( BASE CORRESPONDING #( ls_data ) ) ).                   
        
        IF lt_po_deadline IS NOT INITIAL.
            IF lv_page_size > 0.
              io_response->set_data( lt_po_deadline[ lv_offset : lv_offset + lv_page_size ] ).
            ELSE.
              io_response->set_data( lt_po_deadline ).
            ENDIF.
    
            io_response->set_total_number_of_records( lines( lt_po_deadline ) ).
        ENDIF.

        " DATA(lv_lines) = lines( lt_po_deadline ).
        
        " IF lv_lines EQ 1 .
        "   io_response->set_data( lt_po_deadline ).
        "   io_response->set_total_number_of_records( lines( lt_po_deadline ) ).
        " ELSE.
        "   DATA(lv_top)   = lo_paging->get_page_size( ).
        "   DATA(lv_skip)  = lo_paging->get_offset( ).
        "   DATA(lv_start) = lv_skip + 1.
        "   DATA(lv_end)   = lv_skip + lv_top.

        "   APPEND LINES OF lt_po_deadline FROM lv_start TO lv_end TO lt_po_deadline_out.
          
        "   io_response->set_data( lt_po_deadline_out ).
        "   io_response->set_total_number_of_records( lines( lt_po_deadline ) ).          
        " ENDIF.
      WHEN 'ZSM_C_PO_ITEM'.
        _get_goods_movement( EXPORTING io_filter = io_request->get_filter( )
                             IMPORTING et_data   = DATA(lt_goods_mvm) ).

        lt_po_goods = VALUE #( FOR ls_goods_mvm IN lt_goods_mvm ( BASE CORRESPONDING #( ls_goods_mvm ) ) ).

        io_response->set_total_number_of_records( lines( lt_po_goods ) ).
        io_response->set_data( lt_po_goods ).
    ENDCASE.
  ENDMETHOD.

* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZSM_CL_IM_QUERY->_GET_DATA
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_REQUEST                     TYPE REF TO IF_RAP_QUERY_REQUEST
* | [<---] ET_DATA                        TYPE        ZSM_TT_0001
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD _get_data.
    METHOD _get_data.
        DATA: lt_data             TYPE TABLE OF zsm_c_po,
              lt_filter_condition TYPE RANGE OF rsparams,
              lt_matdoc           TYPE TABLE OF matdoc,
              lt_sort             TYPE TABLE OF if_rap_query_sort,
              lt_t052             TYPE TABLE OF t052,
              lt_t161t            TYPE TABLE OF t161t,
              lv_orderby_string   TYPE string,.
      
        lt_filter_condition = io_request->get_filter( )->get_as_ranges( ).
      
        lt_sort = io_request->get_sort_elements( ).

        LOOP AT lt_sort INTO DATA(ls_sort).
          DATA(lv_prefix) = SWITCH string( ls_sort-element_name WHEN 'EBELN' OR 'BEDAT' OR 'BSART' OR 'AEDAT' OR 'LIFNR' OR 'ZTERM' OR 'WAERS' OR 'BUKRS'                                   THEN 'K~'
                                                                WHEN 'EBELP' OR 'MATNR' OR 'TXZ01' OR 'WERKS' OR 'LGORT' OR 'MENGE' OR 'PEINH' OR 'MEINS' OR 'NETPR' OR 'NETWR' OR 'ELIKZ'  THEN 'P~'
                                                                WHEN 'ETENR' OR 'EINDT' OR 'EMENGE'                                                                                         THEN 'T~'
                                                                                                                                                                                            ELSE 'K~' ).
      
          CONCATENATE lv_prefix ls_sort-element_name INTO ls_sort-element_name.
      
          CONCATENATE lv_orderby_string ls_sort-element_name 
            CONDENSED
            INTO lv_orderby_string
            SEPARATED BY space
            USING ( WHEN ls_sort-descending THEN 'DESCENDING' ELSE 'ASCENDING' ).
        ENDLOOP.
      
        IF lv_orderby_string IS INITIAL.
          lv_orderby_string = 'K~EBELN'.
        ENDIF.
      
        SELECT k~ebeln, p~ebelp, t~etenr, k~bedat, k~bsart, k~aedat, k~lifnr, l~name1, 
               k~zterm, p~matnr, p~txz01, p~werks, p~lgort, p~menge, p~peinh, 
               t~eindt, t~menge AS emenge, p~meins, p~netpr, p~netwr, k~waers, 
               k~bukrs, p~elikz
          FROM ekko AS k
          INNER JOIN ekpo AS p ON k~ebeln EQ p~ebeln
          LEFT OUTER JOIN eket AS t ON p~ebeln EQ t~ebeln AND p~ebelp EQ t~ebelp
          LEFT OUTER JOIN lfa1 AS l ON k~lifnr EQ l~lifnr
          WHERE k~ebeln IN @FILTER #( lt_filter_condition[ name = 'EBELN' ]-range )
            AND k~bstyp EQ 'F'
            AND k~bsart IN @FILTER #( lt_filter_condition[ name = 'BSART' ]-range )
            AND k~aedat IN @FILTER #( lt_filter_condition[ name = 'AEDAT' ]-range )
            AND k~ernam IN @FILTER #( lt_filter_condition[ name = 'ERNAM' ]-range )
            AND p~ebelp IN @FILTER #( lt_filter_condition[ name = 'EBELP' ]-range )
            AND p~matnr IN @FILTER #( lt_filter_condition[ name = 'MATNR' ]-range )
            AND p~bukrs IN @FILTER #( lt_filter_condition[ name = 'BUKRS' ]-range )
            AND p~werks IN @FILTER #( lt_filter_condition[ name = 'WERKS' ]-range )
            AND p~matkl IN @FILTER #( lt_filter_condition[ name = 'MATKL' ]-range )
            AND p~loekz EQ abap_false
            AND p~mtart IN @FILTER #( lt_filter_condition[ name = 'MTART' ]-range )
            AND p~elikz IN @FILTER #( lt_filter_condition[ name = 'ELIKZ' ]-range )
            AND k~ekorg IN ( '1010', '1020', '3010', '3020' )
          ORDER BY (lv_orderby_string)
          INTO TABLE @lt_data.
      
        IF lt_data[] IS NOT INITIAL.
          SELECT ebeln, ebelp, budat
            FROM matdoc
            FOR ALL ENTRIES IN @lt_data
            WHERE ebeln EQ @lt_data-ebeln
              AND ebelp EQ @lt_data-ebelp
              AND cancelled EQ ''
              INTO TABLE @lt_matdoc.
      
          SELECT zterm, ztag1
            FROM t052
            FOR ALL ENTRIES IN @lt_data
            WHERE zterm = @lt_data-zterm
            INTO TABLE @lt_t052.
      
          SELECT bsart, batxt
            FROM t161t
            FOR ALL ENTRIES IN @lt_data
            WHERE spras = @sy-langu
              AND bsart = @lt_data-bsart
              AND bstyp = 'F'
            INTO TABLE @lt_t161t.
      
          LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
            <fs_data>-emeins = <fs_data>-meins.
            <fs_data>-ewaers = <fs_data>-waers.
            <fs_data>-waers_try = <fs_data>-ewaers_try = 'TRY'.
      
            <fs_data>-batxt = VALUE #( lt_t161t[ bsart = <fs_data>-bsart ]-batxt OPTIONAL )
            <fs_data>-eindt = VALUE #( lt_matdoc[ ebeln = <fs_data>-ebeln ebelp = <fs_data>-ebelp ]-budat OPTIONAL ).

            <fs_data>-enetwr = ( <fs_data>-emenge / ( <fs_data>-peinh WHEN <fs_data>-peinh NE 0 ELSE 1 ) ) * <fs_data>-netpr.
      
            <fs_data>-ztag1 = VALUE #( lt_t052[ zterm = <fs_data>-zterm ]-ztag1 OPTIONAL ).
            <fs_data>-neindt = <fs_data>-eindt + <fs_data>-ztag1.
      
            IF <fs_data>-waers = 'TRY'.
              <fs_data>-netpr_try  = <fs_data>-netpr.
              <fs_data>-netwr_try  = <fs_data>-netwr.
              <fs_data>-enetwr_try = <fs_data>-enetwr.
            ELSE.
              CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
                EXPORTING
                  date             = <fs_data>-bedat
                  foreign_amount   = <fs_data>-netpr
                  foreign_currency = <fs_data>-waers
                  local_currency   = 'TRY'
                IMPORTING
                  local_amount     = <fs_data>-netpr_try
                EXCEPTIONS
                  no_rate_found    = 1 
                  OTHERS = 6.
      
              IF <fs_data>-netpr_try IS NOT INITIAL.
                <fs_data>-netwr_try  = <fs_data>-menge * <fs_data>-netpr_try.
                <fs_data>-enetwr_try = <fs_data>-emenge * <fs_data>-netpr_try.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
      
      ENDMETHOD.
  ENDMETHOD.

* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZSM_CL_IM_QUERY->_GET_GOODS_MOVEMENT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_FILTER                      TYPE REF TO IF_RAP_QUERY_FILTER
* | [<---] ET_DATA                        TYPE        ZSM_TT_0002
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD _get_goods_movement.
    DATA(lt_filter_condition) = io_filter->get_as_ranges( ).

    READ TABLE lt_filter_condition INTO DATA(ls_fiter_ebeln) WITH KEY name = 'EBELN'.
    READ TABLE lt_filter_condition INTO DATA(ls_fiter_ebelp) WITH KEY name = 'EBELP'.

    IF ls_fiter_ebeln IS NOT INITIAL AND ls_fiter_ebelp IS NOT INITIAL.
        SELECT matdoc~ebeln,
               matdoc~ebelp, 
               matdoc~budat, 
               matdoc~bwart, 
               t156t~btext_l, 
               matdoc~stock_qty, 
               matdoc~meins, 
               matdoc~mblnr, 
               matdoc~mjahr, 
               matdoc~zeile
          FROM matdoc 
          INNER JOIN t156t 
            ON  t156t~bwart EQ matdoc~bwart
            AND t156t~sobkz EQ matdoc~sobkz
            AND t156t~kzbew EQ matdoc~kzbew
            AND t156t~kzzug EQ matdoc~kzzug
            AND t156t~kzvbr EQ matdoc~kzvbr    
          WHERE ebeln IN ls_fiter_ebeln-range
            AND ebelp IN ls_fiter_ebelp-range
            AND cancelled EQ ''
            AND spras EQ sy-langu 
           INTO CORRESPONDING FIELDS OF TABLE et_data.
    ENDIF.    
  ENDMETHOD.