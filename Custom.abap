@EndUserText.label: 'Custom CDS Entity'
@ObjectModel.query.implementedBy: 'ABAP:ZSM_CL_IM_QUERY'

define root custom entity ZSM_C_PO

{   
    @Consumption.valueHelpDefinition: [{ entity: { element: 'CompanyCode' }, name: 'I_COMPANYCODESTDVH' }]
    @ObjectModel.text.element       : [ 'CompanyCode' ]
    @Search.defaultSearchElement    : true  
    @UI: {
        identification              : [{ position: 10 }],
        lineItem                    : [{ cssDefault.width: '10em', position: 10, importance: #HIGH}],
        selectionField              : [{ position: 10 }]
    }  
    key COMPANYCODE                 : bukrs;
    
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZSM_I_BSART', element: 'bsart' } }]
    @ObjectModel.text.element       : [ 'batxt' ]
    @Search.defaultSearchElement    : true
    @UI: {
        identification              : [{ position: 20 }],
        lineItem                    : [{ position: 20, importance: #HIGH }],
        selectionField              : [{ position: 20 }] 
    }
    PURCHASEORDERTYPE               : bsart;

    @Search.defaultSearchElement    : true
    @UI: {
        identification              : [{ position: 30 }],  
        lineItem                    : [{ position: 30, importance: #HIGH}],
        selectionField              : [{ position: 30 }] 
    }
    PURCHASEORDER                   : vdm_purchaseorder;

    @UI: {
        identification              : [{ position: 190 }],        
        lineItem                    : [{ position: 190, importance: #HIGH }]
    },  
    PURCHASEORDERITEM               : vdm_purchaseorderitem;

    @Consumption.filter.hidden      : true
    @UI: {
        identification              : [{ position: 620 }],        
        lineItem                    : [{ position: 620, importance: #HIGH }]
    }, 
    FIRSTTIMESTAMP                  : datum;
}

---

CLASS ZSM_CL_IM_QUERY DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
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