# Access Control (DCL) & Authorization Checks

## What is it?

**Access Control (DCL — Data Control Language)** is a separate CDS artifact (`define role`) that declares row-level authorization restrictions for a CDS view. Once such a role exists, its restrictions are applied implicitly whenever the CDS entity is read via ABAP SQL or an SADL query — provided the entity does not switch access control off with `@AccessControl.authorizationCheck: #NOT_ALLOWED`.

> ⚠️ The protection comes from the **role**, not from the annotation. A view annotated `#CHECK` with no DCL role is not protected — see the mode table below.

## Why is it used?

- To centralize authorization logic **once**, at the data-model level, instead of re-implementing authority checks in every ABAP program/report that reads the view.
- To ensure that OData/Fiori/RAP consumers — who never pass through custom ABAP authority-check code — still get properly filtered results based on the user's authorizations.

## When should it be used?

Apply access control to any view exposing business data beyond pure technical/interface building blocks — especially anything published via OData (see [08-OData-and-Consumption/OData.md](../08-OData-and-Consumption/OData.md)) or consumed by RAP.

## Syntax and Example (original note)

```abap
// Access Control For CDS Views
// View
@AbapCatalog.sqlViewName          : 'ZSM_V_DCL01'
@AccessControl.authorizationCheck : #CHECK

define view ZSM_I_001
  as select from mara

{
  matnr,
  meins
};

// Access Control
@EndUserText.label : 'Access Control For ZSM_I_001'
@MappingRole       : true

define role ZSM_DCL_001

{
  grant select on ZSM_I_001 where meins = 'ST';
}
```

### Explanation

| Element | Meaning |
|---|---|
| `@AccessControl.authorizationCheck: #CHECK` | On the **view**, declares that this entity is meant to be access-controlled: an assigned DCL role is evaluated on every read, and a missing role raises a syntax check warning (see the three modes below). |
| `define role <name> { ... }` | Declares a **DCL source** — a named access-control artifact. |
| `@MappingRole: true` | Marks this DCL source as a **mapping role**, meaning the `WHERE` restriction below maps directly onto CDS view fields (as opposed to a "PFCG-based" DCL role, which checks against `SU21` authorization objects/fields via `aspect pfcg_auth`). |
| `grant select on <view> where <condition>;` | The actual restriction — every `SELECT` against `ZSM_I_001` is implicitly filtered by `meins = 'ST'`, regardless of who runs it or how (ABAP, OData, RAP). |

> 📝 In this example the restriction (`meins = 'ST'`) is a **static** condition, applied identically to every user. Real-world DCL roles usually restrict data **per user**, typically via `aspect pfcg_auth` referencing classic authorization objects, or via `$session.user` combined with an authorization/assignment table. A static condition like this is more of a fixed business rule (e.g. "this view is scoped to piece-quantity materials only") than a user-specific security check.

## `@AccessControl.authorizationCheck` Modes

| Mode | Meaning |
|---|---|
| `#CHECK` | Access control is evaluated on read **if a DCL role is assigned** to the entity. If **no** role exists, there is **no check and no protection** — the development tooling raises a syntax check *warning*, but the read still returns all rows. |
| `#NOT_REQUIRED` | Runtime behaviour is the **same as `#CHECK`** — a role is evaluated if one exists, and nothing is enforced if none does. The difference is design-time only: no syntax check warning is issued for the missing role. Used on low-level interface views deliberately left unchecked. |
| `#NOT_ALLOWED` | CDS access control is **switched off** for this entity. Any DCL role defined for it is **ignored at runtime**, and defining one produces a syntax check warning in the DCL source. Intended for entities whose data should not be subject to user-related CDS restrictions — for example technical or framework data. |

> ⚠️ **`#NOT_ALLOWED` is not a restrictive setting.** Despite the name, it does not block or limit access — it disables the access-control mechanism entirely. It is the *least* protective of the three values, not the most. Never reach for it expecting it to lock a view down.

> ⚠️ **`#CHECK` does not fail closed.** Setting `#CHECK` on a view does not, by itself, protect anything. Protection comes from the DCL role; the annotation only determines whether the tooling warns you when the role is missing. A view annotated `#CHECK` with no role behaves exactly like an unprotected view at runtime — treat the syntax check warning as a real security finding, not editor noise.

## A More Realistic, User-Aware DCL Example

```abap
@EndUserText.label: 'Access Control For ZSM_I_001 by Plant Authorization'
@MappingRole: true

define role ZSM_DCL_002 {
  grant select on ZSM_I_001
    where ( werks ) = aspect pfcg_auth( M_MSEG_WWA, WERKS, actvt = '03' );
}
```

`aspect pfcg_auth(<AuthObject>, <Field>, actvt = '03')` checks the current user's authorizations for the classic authorization object `M_MSEG_WWA` (plant), field `WERKS`, activity `03` (display) — this is how most production DCL roles are actually written, tying CDS-level access control back into the standard SAP authorization concept (`SU21`/`PFCG`) rather than a hardcoded value.

## Where Access Control Does **Not** Apply

CDS access control is implicit, but it is not universal. Two cases are worth knowing before relying on a DCL role as a security boundary.

### `WITH PRIVILEGED ACCESS`

ABAP SQL can deliberately switch access control off for a single read:

```abap
SELECT *
  FROM zsm_i_001 WITH PRIVILEGED ACCESS
  INTO TABLE @DATA(lt_data).
```

`WITH PRIVILEGED ACCESS` disables CDS access control for that statement, overriding both delivered and self-defined roles. Two details matter:

- It applies **only** to the CDS entity it is specified for — not to entities reached through that entity's associations.
- It cannot be combined with a path expression.

It exists for legitimate framework/technical reads that must see all data. Treat every occurrence in application code as something that needs justifying in review.

### Access control is not inherited between CDS entities

When one CDS entity is used as a **data source inside another** CDS entity, the inner entity's access control is **not** evaluated. The check applies to the entity the consumer actually selects from — not to each layer beneath it.

This is the most common real-world surprise with DCL: layering a `#CHECK`ed interface view underneath an unchecked consumption view does **not** carry the restriction upward. Each entity that is consumed directly needs its own access control.

## Common Mistakes

- ❌ Setting `@AccessControl.authorizationCheck: #CHECK` and assuming the view is now protected — without a matching DCL role there is **no check at all**. This fails *open*, not closed: the view returns everything, and the only signal is a syntax check warning at development time.
- ❌ Using `#NOT_ALLOWED` believing it to be the strictest setting — it switches access control **off** and causes any DCL role for the entity to be ignored.
- ❌ Writing a DCL role with a static `WHERE` condition when the intent was a **per-user** check — static conditions apply to *all* users identically, they are not a substitute for `aspect pfcg_auth`-based checks.
- ❌ Setting `#NOT_REQUIRED` on a view that is later published via OData — this suppresses the warning that would otherwise flag the missing role, precisely where external access makes it matter most.
- ❌ Assuming a checked view stays checked when it is consumed by another CDS entity — it does not (see *Where Access Control Does **Not** Apply*, above).
- ❌ Forgetting the trailing semicolon after `grant select on ... where ...;` inside `define role { }` — DCL statements are terminated individually, unlike the field list of a `define view`.

## Performance Considerations

- DCL `WHERE` restrictions are merged into the generated SQL of every consuming query — a simple, indexed field restriction (like a plant or company code) is typically cheap; deeply nested `aspect pfcg_auth` checks across multiple authorization objects can add noticeable overhead on very large data sets, so keep authorization models as simple as the business genuinely requires.

## SAP Best Practices

- Default new consumption/root views to `@AccessControl.authorizationCheck: #CHECK` **and create the matching DCL role** — the annotation alone protects nothing. Only relax to `#NOT_REQUIRED` for pure interface/building-block views that are never consumed directly.
- Prefer `aspect pfcg_auth(...)` over hardcoded/static `WHERE` conditions whenever the restriction should genuinely depend on the calling user's authorizations.
- Name DCL roles consistently and document, via `@EndUserText.label`, exactly which view and business rule they secure.
- Test authorization behavior with a real, restricted test user — not just as a "power user" who bypasses most checks (`SU53`/`ST01`/authorization trace tools help here).

## Interview Notes

- **Q: What is the difference between `@AccessControl.authorizationCheck: #CHECK` and `#NOT_REQUIRED`?**
  A: At runtime, effectively nothing — both evaluate a DCL role if one exists and enforce nothing if none does. The difference is design-time intent: `#CHECK` says "this view is meant to be protected", so a missing role raises a syntax check warning; `#NOT_REQUIRED` says "this view is deliberately unchecked", so no warning is issued.
- **Q: Is a view annotated `#CHECK` protected even without a DCL role?**
  A: No. Without a role there is no check and no protection — the view returns all rows. `#CHECK` fails open, and the only indication is a development-time warning.
- **Q: How do you tie a DCL role to the classic SAP authorization concept (`PFCG`/`SU21`)?**
  A: Using `aspect pfcg_auth(<AuthorizationObject>, <Field>, <ActivityCondition>)` inside the role's `WHERE` clause, instead of a hardcoded/static condition.
- **Q: What does `@MappingRole: true` mean?**
  A: It marks the DCL source as a mapping role, where the `WHERE` restriction is expressed directly against the CDS view's own fields.

## Related Chapters

- [08-OData-and-Consumption/OData.md](../08-OData-and-Consumption/OData.md) — why access control matters even more once a view is externally published
- [04-CDS-Annotations/Annotation-Global.md](../04-CDS-Annotations/Annotation-Global.md) — `@AccessControl.authorizationCheck` alongside other global annotations
- [05-Filtering-and-Parameters/Session.md](../05-Filtering-and-Parameters/Session.md) — `$session.user`, sometimes used in custom authorization designs
