# Reporting — Displaying CDS Data via ALV

## What is it?

Once a CDS view is activated, it can be displayed directly via **ALV (SAP List Viewer)** using `CL_SALV_GUI_TABLE_IDA`, which is purpose-built to render CDS views without manually fetching data into an internal table first.

## Why is it used?

- Quick, ready-made tabular display (sorting, filtering, export, layout variants) for a CDS view — ideal for ad hoc reports, quick data checks, or lightweight custom reports.
- Avoids manually building a field catalog for the classic ALV APIs (`REUSE_ALV_GRID_DISPLAY`/`CL_GUI_ALV_GRID`) — the "IDA" (Integrated Data Access) variant reads the CDS view's own metadata (labels, key fields) automatically.

## When should it be used?

Use `CL_SALV_GUI_TABLE_IDA` for straightforward, read-only, ALV-style display reports built directly on top of a CDS view. For OData/Fiori consumption, see [08-OData-and-Consumption/OData.md](../08-OData-and-Consumption/OData.md) instead — ALV is for classic SAP GUI reporting.

## Example (original note)

```abap
REPORT zsm_cds_alv.

CLASS lcl_alv DEFINITION CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS create_alv
      RETURNING VALUE(ro_result) TYPE REF TO lcl_alv.

    METHODS run_alv.
ENDCLASS.


CLASS lcl_alv IMPLEMENTATION.
  METHOD create_alv.
    ro_result = NEW lcl_alv( ).
  ENDMETHOD.

  METHOD run_alv.
    TRY.
        cl_salv_gui_table_ida=>create_for_cds_view( 'ZSM_I_001' )->fullscreen( )->display( ).
      CATCH cx_root INTO DATA(lx_msg). " TODO: variable is assigned but never used (ABAP cleaner)
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  lcl_alv=>create_alv( )->run_alv( ).
```

### Explanation

| Element | Meaning |
|---|---|
| `cl_salv_gui_table_ida=>create_for_cds_view( 'ZSM_I_001' )` | Factory method creating an ALV instance directly bound to the named CDS view — pass the **CDS entity name**, not the SQL view name (see [02-CDS-Basics/Program.md](../02-CDS-Basics/Program.md)). |
| `->fullscreen( )` | Configures the ALV to display in a full-screen container. |
| `->display( )` | Triggers the actual rendering/display. |
| `CATCH cx_root INTO DATA(lx_msg)` | Catches any exception raised during ALV creation/display. |

> 📝 The `TODO` comment flags that `lx_msg` is assigned but never used — this is exactly the kind of warning ABAP's static checks (Code Inspector / ABAP cleaner / ATC) raise. In production code, either actually use the caught exception (e.g. log its `get_text( )`, or re-raise a more specific exception) or catch without a variable (`CATCH cx_root.`) if truly nothing needs to be done with it.

## Improved Example — Handling the Exception Properly

```abap
REPORT zsm_cds_alv.

CLASS lcl_alv DEFINITION CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS create_alv
      RETURNING VALUE(ro_result) TYPE REF TO lcl_alv.

    METHODS run_alv.
ENDCLASS.

CLASS lcl_alv IMPLEMENTATION.
  METHOD create_alv.
    ro_result = NEW lcl_alv( ).
  ENDMETHOD.

  METHOD run_alv.
    TRY.
        cl_salv_gui_table_ida=>create_for_cds_view( 'ZSM_I_001' )->fullscreen( )->display( ).
      CATCH cx_root INTO DATA(lx_error).
        MESSAGE lx_error->get_text( ) TYPE 'E'.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  lcl_alv=>create_alv( )->run_alv( ).
```

## Common Mistakes

- ❌ Passing the SQL view name instead of the CDS entity/DDL name to `create_for_cds_view()`.
- ❌ Catching an exception into a variable and never using it — flagged by ABAP cleaner/ATC; either use it or omit the `INTO` entirely.
- ❌ Using `CL_SALV_GUI_TABLE_IDA` for very large data sets without considering paging/filtering — IDA is optimized for large data but should still be paired with sensible selection screens/filters for usability.

## Performance Considerations

- `CL_SALV_GUI_TABLE_IDA` reads data directly through **Integrated Data Access**, pushing filtering/sorting/paging down to the database as the user interacts with the ALV — this is generally far more efficient for large CDS-backed data sets than fetching everything into an internal table first and displaying with classic ALV.

## SAP Best Practices

- Prefer `CL_SALV_GUI_TABLE_IDA` over manually selecting into an internal table and using classic ALV APIs when the data source is a CDS view — it's less code and benefits from IDA's push-down behavior.
- Wrap the ALV creation in a local class (as in the original example) to keep `START-OF-SELECTION` minimal and testable.
- Always handle exceptions meaningfully rather than silently swallowing them.

## Interview Notes

- **Q: What is `CL_SALV_GUI_TABLE_IDA` and when would you use it?**
  A: An ALV class built specifically for displaying CDS views via Integrated Data Access, pushing filtering/sorting down to the database; use it for straightforward CDS-view-backed ALV reports.
- **Q: Why is it a problem to catch an exception into a variable you never use?**
  A: It hides potentially useful error information from the user/log and is flagged by static code checks as dead code — either use the exception object (e.g. display its message) or omit the `INTO` clause.

## Related Chapters

- [02-CDS-Basics/Program.md](../02-CDS-Basics/Program.md) — reading CDS views from ABAP directly
- [Query.md](Query.md) — shaping the data that ends up displayed here
- [08-OData-and-Consumption/OData.md](../08-OData-and-Consumption/OData.md) — the web/Fiori-facing alternative to classic ALV reporting
