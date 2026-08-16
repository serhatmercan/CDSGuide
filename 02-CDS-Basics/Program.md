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
  " Read the CDS entity — this is the correct, supported way
  SELECT * FROM zsm_i_001
    INTO TABLE @DATA(lt_view).

  " Parameterized CDS entity
  SELECT *
    FROM zsm_v_002( p_meins = 'ST' )
    INTO TABLE @DATA(lt_parameters_view).
```

### Explanation

| Line | What it does |
|---|---|
| `SELECT * FROM zsm_i_001` | Reads the **CDS entity** by its DDL source name (e.g. `ZSM_I_001`). Client handling is implicit, so the client field is **not** returned as a normal column. This is the name RAP, OData and analytics tooling expect. |
| `SELECT * FROM zsm_v_002( p_meins = 'ST' )` | Reads a **parameterized** CDS view, passing input parameter values in parentheses. See [05-Filtering-and-Parameters/Parameters.md](../05-Filtering-and-Parameters/Parameters.md). |
| `@DATA(lt_view)` | Inline declaration — creates the internal table on the fly with the exact structure of the selected fields. |

## Three Names, One Model — and Only One Consumption API

This is a very common interview and real-world question, and the original version of these notes treated the two names as interchangeable read paths. They are not.

| What | What it is | Use it to read data? |
|---|---|---|
| **CDS entity** (`ZSM_I_001`) | The CDS artifact itself — the DDL source name. Carries the full model: annotations, associations, client handling, access control. | ✅ **Yes — this is the consumption API.** |
| **Generated DDIC/database view** (`ZSM_CDS_001`) | For a *classic* `define view`, `@AbapCatalog.sqlViewName` generates a plain DDIC/database view alongside the entity. It exposes the raw columns only — including the client field as an ordinary column. | ❌ **No.** |
| **CDS view entity** (`define view entity`) | Has **no** generated SQL view at all — `@AbapCatalog.sqlViewName` does not exist for view entities, so there is nothing else to select from. | — (only the entity exists) |

> ⚠️ **Do not read the generated database view from ABAP.** SAP documents use of the CDS database view in ABAP SQL read statements as **obsolete**, and it is **rejected by the syntax check in strict mode from Release 7.50**. SAP's guidance is to use only the CDS entity, because only the entity covers all properties of the model.

> 🔐 **Security implication.** Implicit CDS access control (DCL) is evaluated only when the **CDS entity** is accessed via ABAP SQL or an SADL query. Reading the generated database view instead — or reaching the data through Native SQL (ADBC, `EXEC SQL`) — does **not** evaluate the entity's DCL role, so every row-level restriction is silently skipped. The difference between the two names is therefore not cosmetic and not primarily about `MANDT`: one path is access-controlled and one is not. See [09-Security/AccessControl.md](../09-Security/AccessControl.md).

The generated view remains visible in `SE11` and is useful for *inspecting* what was activated. Browsing it is fine; consuming it from application code is not.

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

- ❌ Selecting from the generated database view instead of the CDS entity — obsolete, rejected in ABAP SQL strict mode from 7.50, bypasses CDS access control, and drops the entity's semantics (client handling, associations, annotations). The stray `MANDT` column is the least of the problems.
- ❌ Not checking `sy-subrc` after the `SELECT`.
- ❌ Selecting the entire view (`*`) when only a handful of fields are actually used.

## Performance Considerations

- Filtering (`WHERE`) should be pushed as close to the CDS `SELECT` as possible rather than filtering the internal table afterward in a `LOOP` — this keeps the filter logic on the database side.
- Avoid nested `SELECT`s inside loops (`SELECT ... FOR ALL ENTRIES` is the classic mass-fetch pattern) — see [10-Examples/Class.md](../10-Examples/Class.md) for a worked example.

## SAP Best Practices

- Always read CDS views through their **CDS entity name**. The generated database view is not an alternative consumption API — it is an implementation artifact of classic `define view`, and it does not exist at all for view entities.
- Keep ABAP `SELECT`s thin — let the CDS view do the joining/aggregation.

## Interview Notes

- **Q: Can you use a CDS view in an `OPEN SQL` `SELECT` just like a table?**
  A: Yes — activated CDS views appear in the ABAP Dictionary and can be used in `SELECT`, `JOIN`, and `FOR ALL ENTRIES` statements like any other DDIC object.
- **Q: What is the difference between reading the CDS entity and reading its generated database view?**
  A: The CDS entity is the consumption API — it applies client handling, associations, annotations and CDS access control. The generated database view is a plain DDIC view exposing raw columns (including `MANDT`), evaluates **no** DCL role, is obsolete in ABAP SQL, and is rejected in strict mode from 7.50. CDS view entities have no generated view at all.

## Related Chapters

- [Main.md](Main.md) — defining the view being consumed here
- [05-Filtering-and-Parameters/Parameters.md](../05-Filtering-and-Parameters/Parameters.md) — passing parameters into a view from ABAP
- [07-Query-and-Reporting/Report.md](../07-Query-and-Reporting/Report.md) — displaying CDS view data via ALV
