# Input Parameters

## What is it?

**Input parameters** let a CDS view accept values from the caller at query time (`WITH PARAMETERS`), similar to arguments passed into a function. Parameters can be used in the `WHERE` clause, in the field list, or passed on to a nested parameterized view.

## Why is it used?

- To make a view **dynamic** without hardcoding filter values inside the view itself.
- To pass in a reference/key date, currency, or unit needed for conversions ([06-Built-In-Functions/Conversion.md](../06-Built-In-Functions/Conversion.md)).
- To let a report or Fiori app control filtering criteria that can't be expressed as a simple field filter (e.g. "as of this date").

## When should it be used?

Use input parameters when the view's logic genuinely depends on a caller-supplied value (currency for conversion, key date for time-dependent data, a business-specific selection criterion) — not as a substitute for ordinary `WHERE` filtering on exposed fields, which any consumer can already do.

## Syntax and Example (original note)

```abap
// Examples of Parameters in CDS View
@AbapCatalog.sqlViewName: 'ZSM_V_PARAM01'
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Parameters'

define view ZSM_I_002
  with parameters
    p_displaycurrency                     : vdm_v_display_currency,

    @Environment.systemField: #SYSTEM_DATE
    p_key_date                            : vdm_v_key_date,

    p_datab                               : abap.dats,
    p_meins                               : meins,
    p_mtart                               : mtart,

    @Consumption.defaultValue: 5
    P_number_of_years_of_time_to_maturity : ftr_years_to_maturity

  as select from mara

{
  matnr                                                      as Material,
  matkl                                                      as MaterialGroup,
  meins                                                      as BaseUnit,

  cast(substring($parameters.p_datab, 1, 6) as abap.numc(6)) as Spmon
}

where meins  = $parameters.p_meins
  and mtart  = $parameters.p_mtart
  and datbi >= $parameters.p_datab
  and matkl  = 'AP'
```

### Explanation

| Element | Meaning |
|---|---|
| `with parameters <name> : <type>, ...` | Declares the parameter list, each with a name and a DDIC data element/type. |
| `@Environment.systemField: #SYSTEM_DATE` | Auto-fills the parameter with the current system date if the caller does not supply one — a common pattern for "key date" parameters. |
| `@Consumption.defaultValue: 5` | Supplies a default value when the caller omits the parameter, used in UI/OData value-help scenarios. |
| `$parameters.<name>` | References a parameter's value anywhere inside the view (field list, `WHERE`, further associations). |

> 📝 **Corrected from the original note.** The original parameter list did not declare `p_datab`, even though the field list and `WHERE` clause both referenced `$parameters.p_datab` — which would fail activation. The declaration `p_datab : abap.dats` has been added above. Referencing a `$parameters.<name>` that was never declared is one of the most common copy-paste errors when reusing a `WHERE` clause across similar views. The original note also left a trailing comma after the last element, which is likewise invalid.

## Calling a Parameterized View

```abap
SELECT *
  FROM zsm_v_002( p_meins = 'ST' )
  INTO TABLE @DATA(lt_parameters_view).
```

See also [02-CDS-Basics/Program.md](../02-CDS-Basics/Program.md) for using parameterized views from ABAP.

## Calling Another Parameterized View (original note)

```abap
// Call Another Parameters View
define root view entity ZSD_I_0002
  with parameters
    p_datab                               : abap.dats,
    p_datbi                               : abap.dats

  as select from zsd_i_0001(
                   p_datab : $parameters.p_datab,
                   p_datbi : $parameters.p_datbi)

{
  key zsd_i_0001.vkorg      as SalesOrg,
  key zsd_i_0001.matnr      as Material,
  key zsd_i_0001.spmon      as Period,

      sum(zsd_i_0001.kbetr) as NetAmount
}

group by zsd_i_0001.bonus_group,
         zsd_i_0001.vkorg,
         zsd_i_0001.matnr,
         zsd_i_0001.spmon
```

A parameterized view can pass its own parameters straight through to a *nested* parameterized view (`zsd_i_0001(...)`) — this is how parameters propagate down a chain of layered views (interface → composite → consumption).

## Joining a Parameterized View (original note, corrected)

```abap
// Call Another Parameters View w/ Left Outer Join
define root view entity ZSD_I_0003
  as select from zsd_i_0001 as I0001

  left outer join zsd_i_0002( p_meins : 'M3' ) as I0002
    on I0002.Material = I0001.Material

{
  key I0001.Material,
      I0002.BillOfLadingDate
}
```

> 📝 The original note only fragmented this pattern ("Left Outer Join define root view entity..."). The corrected form above shows the actual usable pattern: a parameterized view can be the **target of a join**, with its parameter values supplied as literals (or passed-through parameters) directly in the `FROM`/`JOIN` clause, exactly like calling a function.

## Common Mistakes

- ❌ Referencing `$parameters.<name>` for a parameter that was never declared (see the warning above) — a frequent copy-paste error when reusing a `WHERE` clause across similar views.
- ❌ Forgetting that **all** parameters are mandatory by default unless a default value (`@Consumption.defaultValue`) or `@Environment.systemField` is supplied — every caller must then pass every parameter.
- ❌ Using parameters for filtering that could simply be expressed with a `WHERE` on an exposed field — adds unnecessary complexity for callers.

## Performance Considerations

- Parameters used inside a currency/unit conversion function (see [06-Built-In-Functions/Conversion.md](../06-Built-In-Functions/Conversion.md)) are resolved once per query, not per row — cheap.
- A parameterized view cannot be buffered — keep this in mind if you were relying on `@AbapCatalog.buffering` for performance (see [04-CDS-Annotations/Annotation-Global.md](../04-CDS-Annotations/Annotation-Global.md)).

## SAP Best Practices

- Use `@Environment.systemField: #SYSTEM_DATE` / `#SYSTEM_LANGUAGE` etc. so that consumers who don't care about the parameter get a sensible default automatically.
- Prefix parameters with `p_` (or `P_`, matching the surrounding code's casing convention) for immediate recognizability.
- Keep the parameter's DDIC type as close as possible to the field it will be compared against, to avoid implicit conversions.

## Interview Notes

- **Q: How do you access a parameter's value inside a CDS view?**
  A: Via `$parameters.<parameter_name>`, usable in the field list, `WHERE` clause, or when passing to a nested parameterized view.
- **Q: Are CDS view parameters optional?**
  A: Only if given a default value (`@Consumption.defaultValue`) or an automatically-filled system field (`@Environment.systemField`); otherwise every parameter must be supplied by the caller.

## Related Chapters

- [Condition.md](Condition.md) — combining parameters with `WHERE`/`CASE` logic
- [Session.md](Session.md) — the related `$session` built-in variables
- [06-Built-In-Functions/Conversion.md](../06-Built-In-Functions/Conversion.md) — currency/unit conversion, a common use of parameters
