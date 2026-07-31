# Worked Example — Virtual Element Exit Class

## What is it?

This chapter walks through a real ABAP class implementing `IF_SADL_EXIT_CALC_ELEMENT_READ` — the interface behind a CDS **virtual element** (`@ObjectModel.virtualElement: true` / `virtualElementCalculatedBy`, see [04-CDS-Annotations/Annotation-Local.md](../04-CDS-Annotations/Annotation-Local.md) and [04-CDS-Annotations/Annotation-LocalEx.md](../04-CDS-Annotations/Annotation-LocalEx.md)).

## Why is it used?

Some field values genuinely **cannot** be computed with declarative CDS alone — for example, summing related delivery/invoice quantities across several documents with fallback/priority rules, or business logic too intricate for `CASE`/joins. A virtual element hands that specific field's calculation to an ABAP class, invoked by the SADL (Service Adaptation Definition Language) framework whenever the field is actually requested.

## When should it be used?

Use a virtual element exit class only when the calculation truly cannot reasonably be expressed as CDS joins/associations/built-in functions — it is significantly more expensive (per-row ABAP-side processing) and harder to maintain than declarative fields. Prefer plain CDS calculated fields, and reserve this pattern for genuinely complex, multi-table aggregation logic like the one shown here.

## Full Example (original note)

```abap
CLASS zsm_cl_total_order DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
ENDCLASS.


CLASS zsm_cl_total_order IMPLEMENTATION.
  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_data TYPE TABLE OF zsd_i_order_detail.

    lt_data = CORRESPONDING #( it_original_data ).

    IF lt_data IS INITIAL.
      RETURN.
    ENDIF.

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
      WHERE vgbel_vl = @lt_data-vbeln_va
        AND vgpos_vl = @lt_data-posnr_va
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
        WHERE vgbel_vf = @lt_delivery-vbeln_vl
          AND vgpos_vf = @lt_delivery-posnr_vl
          AND fksto    = @space
          AND sfakn    = @space
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
      WHERE vgbel_vf = @lt_data-vbeln_va
        AND vgpos_vf = @lt_data-posnr_va
        AND fksto    = @space
        AND sfakn    = @space
      INTO TABLE @DATA(lt_inv_ord).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      LOOP AT lt_delivery INTO DATA(ls_delivery) WHERE     vgbel_vl = <lfs_data>-vbeln_va
                                                       AND vgpos_vl = <lfs_data>-posnr_va.
        <lfs_data>-lfimg_vl += ls_delivery-lfimg_vl.
        <lfs_data>-ntgew_vl += ls_delivery-ntgew_vl.
        <lfs_data>-volum_vl += ls_delivery-volum_vl.
        <lfs_data>-lgmng_vl += ls_delivery-lgmng_vl.
      ENDLOOP.

      LOOP AT lt_inv_ord INTO DATA(ls_inv_ord) WHERE     vgbel_vf = <lfs_data>-vbeln_va
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

      LOOP AT lt_inv_dlv INTO DATA(ls_inv_dlv) WHERE     vgbel_vf = <lfs_data>-vbeln_vl
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
          <lfs_data>-zadklno  = <lfs_data>-oih_licin_va.
          <lfs_data>-zadkln   = <lfs_data>-lctxt_va.
          <lfs_data>-zadklt   = <lfs_data>-datab_va.
          <lfs_data>-zadkllgt = <lfs_data>-datbi_va.
        WHEN 'Z011'.
          <lfs_data>-zihrlisno = <lfs_data>-oih_licin_va.
          <lfs_data>-zihrln    = <lfs_data>-lctxt_va.
          <lfs_data>-zihrlt    = <lfs_data>-datab_va.
          <lfs_data>-zihrllgt  = <lfs_data>-datbi_va.
        WHEN 'Z012'.
          <lfs_data>-zmdnyno  = <lfs_data>-oih_licin_va.
          <lfs_data>-zmdynx   = <lfs_data>-lctxt_va.
          <lfs_data>-zmdnyt   = <lfs_data>-datab_va.
          <lfs_data>-zmdnylgt = <lfs_data>-datbi_va.
        WHEN 'Z020'.
          <lfs_data>-zlpgltno = <lfs_data>-oih_licin_va.
          <lfs_data>-zlpgln   = <lfs_data>-lctxt_va.
          <lfs_data>-zlpglt   = <lfs_data>-datab_va.
          <lfs_data>-zlpglgt  = <lfs_data>-datbi_va.
      ENDCASE.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_data ).
  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
```

## Step-by-Step Explanation

1. **`CORRESPONDING #( it_original_data )`** — the SADL framework passes in the rows currently being read (`it_original_data`); the method copies them into a strongly-typed working table (`lt_data`) matching the view's structure.
2. **Mass-fetch delivery data** — `SELECT ... FOR ALL ENTRIES IN @lt_data` retrieves all delivery rows related to the orders currently being processed, **in a single round trip** rather than one `SELECT` per order row (the classic anti-pattern of selecting inside a loop).
3. **Mass-fetch invoice data — twice** — once for invoices tied to deliveries (`lt_inv_dlv`), once for invoices tied directly to the order (`lt_inv_ord`), since invoices in SD can reference either a delivery or an order depending on the billing scenario.
4. **Aggregate via nested `LOOP ... WHERE`** — for each order row, the matching delivery/invoice rows are summed into running totals (`+=`). This is standard ABAP aggregation over an internal table, done once all the mass-fetches are complete.
5. **`CASE <lfs_data>-lictp`** — maps a license/certificate type code (`lictp`) to one of several sets of output fields, depending on which "slot" (`Z010`/`Z011`/`Z012`/`Z020`) the license data belongs in — a business-specific pivot pattern.
6. **`CORRESPONDING #( lt_data )`** — the enriched working table is copied back into the framework's expected output structure (`ct_calculated_data`).

## Common Mistakes

- ❌ Selecting inside a `LOOP` instead of mass-fetching with `FOR ALL ENTRIES` first — this class correctly avoids that anti-pattern, fetching all related data up front before looping to aggregate.
- ❌ Forgetting the `IF lt_data IS INITIAL. RETURN. ENDIF.` guard before a `FOR ALL ENTRIES` — an empty driving table in `FOR ALL ENTRIES` is a classic bug (behavior differs across releases/settings; guarding against it explicitly, as done here, is the safe practice).
- ❌ Not filtering out cancelled/reversed documents (`fksto`, `sfakn`) when summing invoice amounts — this example correctly excludes them (`WHERE fksto = @space AND sfakn = @space`), which is easy to forget and leads to overstated totals.

## Performance Considerations

- Every field marked `virtualElementCalculatedBy` triggers this method for the **entire current result page**, not per individual field access — so the mass-fetch pattern here (bulk `SELECT`s before the aggregation loop) is essential; without it, this would degenerate into per-row `SELECT`s and become a severe performance bottleneck.
- Because this logic runs in ABAP (not pushed down to the database), it is inherently slower than an equivalent CDS-native calculation — reserve virtual elements for logic that truly cannot be modeled declaratively, exactly as this multi-table, multi-fallback aggregation cannot.

## SAP Best Practices

- Always mass-fetch (`FOR ALL ENTRIES`) related data before any aggregation loop inside an exit class — never issue a `SELECT` per row.
- Guard every `FOR ALL ENTRIES` with an emptiness check on the driving internal table.
- Keep exit classes `FINAL`/`CREATE PUBLIC` and focused on a single calculation responsibility, as shown here.
- Implement `get_calculation_info` meaningfully if the framework needs to know which original fields are required to perform the calculation — an empty implementation (as in this example) works only when no extra input-field declaration is needed.

## Interview Notes

- **Q: What interface does an ABAP class implement to serve as a CDS virtual element calculation exit?**
  A: `IF_SADL_EXIT_CALC_ELEMENT_READ`, with the `CALCULATE` method producing the computed values and `GET_CALCULATION_INFO` describing what original data the calculation needs.
- **Q: Why is `FOR ALL ENTRIES` used here instead of a `SELECT` inside the aggregation loop?**
  A: To avoid one database round trip per row (a major performance anti-pattern); all related data is fetched in bulk first, then aggregated in ABAP.

## Related Chapters

- [04-CDS-Annotations/Annotation-Local.md](../04-CDS-Annotations/Annotation-Local.md) — the `virtualElement` / `virtualElementCalculatedBy` annotations that invoke this class
- [04-CDS-Annotations/Annotation-LocalEx.md](../04-CDS-Annotations/Annotation-LocalEx.md) — the CDS fields (`lfimg_vl`, `NetwrVF`) calculated by this exact class
- [06-Built-In-Functions/Function.md](../06-Built-In-Functions/Function.md) — AMDP/table functions, a different way to push complex logic closer to the data
