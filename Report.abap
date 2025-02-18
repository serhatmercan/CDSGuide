REPORT zsm_cds_alv.

CLASS lcl_alv DEFINITION CREATE PRIVATE.
    PUBLIC SECTION.
        CLASS-METHODS create_alv
            RETURNING VALUE(ro_result) TYPE REF TO lcl_alv.
        METHODS run_alv.
    PROTECTED SECTION.
    PRIVATE SECTION.
ENDCLASS.

CLASS lcl_alv IMPLEMENTATION.
    METHOD create_alv.
        ro_result = NEW lcl_alv( ).
    ENDMETHOD.

    METHOD run_alv.
        TRY.
            cl_salv_gui_table_ida=>create_for_cds_view( 'ZSM_I_001' )->fullscreen(  )->display(  ).
        CATCH cx_root INTO DATA(lx_msg).
        ENDTRY.
    ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
    lcl_alv=>create_alv(  )->run_alv( ).