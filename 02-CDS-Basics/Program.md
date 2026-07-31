# Using CDS Views in ABAP Programs

## What is it?

Once a CDS view is activated, it behaves like any other DDIC entity — you can `SELECT` from it in a classic ABAP `REPORT`, class, or function module, exactly as you would from a table.

## Why is it used?

CDS views are meant to be **consumed**. Reading them from ABAP is the most direct way to reuse the modeling, filtering, and calculation logic that already lives in the view, instead of re-implementing joins/aggregations in ABAP.

## When should it be used?

- When a report or program needs data that a CDS view already models (joins, associations, calculated fields).
- When you want to benefit from **code push-down** — the database does the join/aggregation work, and only the final result set is transferred to the application server.

## Syntax (original note)

```abap
" Description: ABAP Program to Demonstrate the Usage of CDS Views in ABAP
REPORT zsm_p_001.

START-OF-SELECTION.
  SELECT * FROM zsm_cds_001
    INTO TABLE @DATA(lt_cds). " SQL View Name: w/ Mandt

  SELECT * FROM zsm_i_001
    INTO TABLE @DATA(lt_view). " DDL View Name: w/out Mandt

  SELECT *
    FROM zsm_v_002( p_meins = 'ST' )
    INTO TABLE @DATA(lt_parameters_view). " w/ Parameters
```

### Explanation

| Line | What it does |
|---|---|
| `SELECT * FROM zsm_cds_001` | Reads via the **SQL view name** (`@AbapCatalog.sqlViewName`) — this is the physical database view name as seen in `SE11`. It typically **includes** the client field (`MANDT`) as a regular column since it is a plain DB view. |
| `SELECT * FROM zsm_i_001` | Reads via the **DDL source name** (the CDS entity name, e.g. `ZSM_I_001`) — the client field is handled automatically/implicitly by client handling, so it is **not** returned as a normal column. |
| `SELECT * FROM zsm_v_002( p_meins = 'ST' )` | Reads a **parameterized** CDS view, passing input parameter values in parentheses. See [05-Filtering-and-Parameters/Parameters.md](../05-Filtering-and-Parameters/Parameters.md). |
| `@DATA(lt_cds)` | Inline declaration — creates the internal table on the fly with the exact structure of the selected fields. |

> ⚠️ **SQL view name vs. DDL/CDS entity name** — this is a very common interview and real-world gotcha. Always prefer selecting by the **CDS entity name** (`ZSM_I_001`) in new ABAP code; it is client-aware and is the name RAP/OData tooling expects. The SQL view name is mostly useful for direct HANA-level tooling (e.g. calculation views, `SE11` browsing).

## Additional Example — Filtering and Field List

```abap
REPORT zsm_p_002.

SELECT matnr, mtart, meins
  FROM zsm_i_001
  WHERE mtart = 'FERT'
  INTO TABLE @DATA(lt_materials).

IF sy-subrc = 0.
  cl_demo_output=>display( lt_materials ).
ENDIF.
```

Selecting only the fields you need (rather than `*`) reduces transferred data and is closer to how CDS views are consumed in practice (OData/RAP never select `*`).

## Common Mistakes

- ❌ Selecting from the SQL view name and forgetting that `MANDT` now appears as a normal field — leads to `TYPE MISMATCH` errors when mapping into a structure that doesn't have `MANDT`.
- ❌ Not checking `sy-subrc` after the `SELECT`.
- ❌ Selecting the entire view (`*`) when only a handful of fields are actually used.

## Performance Considerations

- Filtering (`WHERE`) should be pushed as close to the CDS `SELECT` as possible rather than filtering the internal table afterward in a `LOOP` — this keeps the filter logic on the database side.
- Avoid nested `SELECT`s inside loops (`SELECT ... FOR ALL ENTRIES` is the classic mass-fetch pattern) — see [10-Examples/Class.md](../10-Examples/Class.md) for a worked example.

## SAP Best Practices

- Always read CDS views through their **DDL entity name**, not the generated SQL view name, unless you have a specific technical reason (e.g. native SQL tooling).
- Keep ABAP `SELECT`s thin — let the CDS view do the joining/aggregation.

## Interview Notes

- **Q: Can you use a CDS view in an `OPEN SQL` `SELECT` just like a table?**
  A: Yes — activated CDS views appear in the ABAP Dictionary and can be used in `SELECT`, `JOIN`, and `FOR ALL ENTRIES` statements like any other DDIC object.
- **Q: What happens to the client field (`MANDT`) when reading via the CDS name vs. the SQL view name?**
  A: Through the CDS entity name, client handling is automatic and `MANDT` is not exposed as a field; through the raw SQL view name, `MANDT` behaves like a normal column.

## Related Chapters

- [Main.md](Main.md) — defining the view being consumed here
- [05-Filtering-and-Parameters/Parameters.md](../05-Filtering-and-Parameters/Parameters.md) — passing parameters into a view from ABAP
- [07-Query-and-Reporting/Report.md](../07-Query-and-Reporting/Report.md) — displaying CDS view data via ALV
