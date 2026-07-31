# Access Control (DCL) & Authorization Checks

## What is it?

**Access Control (DCL — Data Control Language)** is a separate CDS artifact (`define role`) that declares row-level authorization restrictions for a CDS view, enforced automatically whenever the view is read (given `@AccessControl.authorizationCheck: #CHECK`).

## Why is it used?

- To centralize authorization logic **once**, at the data-model level, instead of re-implementing authority checks in every ABAP program/report that reads the view.
- To ensure that OData/Fiori/RAP consumers — who never pass through custom ABAP authority-check code — still get properly filtered results based on the user's authorizations.

## When should it be used?

Apply access control to any view exposing business data beyond pure technical/interface building blocks — especially anything published via OData (see [08-OData-and-Consumption/OData.md](../08-OData-and-Consumption/OData.md)) or consumed by RAP.

## Syntax and Example (original note)

```abap
" Access Control For CDS Views
" View
@AccessControl.authorizationCheck : #CHECK

define view ZSM_I_001
  as select from mara

{
  matnr,
  meins
};

" Access Control
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
| `@AccessControl.authorizationCheck: #CHECK` | On the **view**, declares that a DCL role must be evaluated for every read (see the three modes below). |
| `define role <name> { ... }` | Declares a **DCL source** — a named access-control artifact. |
| `@MappingRole: true` | Marks this DCL source as a **mapping role**, meaning the `WHERE` restriction below maps directly onto CDS view fields (as opposed to a "PFCG-based" DCL role, which checks against `SU21` authorization objects/fields via `aspect pfcg_auth`). |
| `grant select on <view> where <condition>;` | The actual restriction — every `SELECT` against `ZSM_I_001` is implicitly filtered by `meins = 'ST'`, regardless of who runs it or how (ABAP, OData, RAP). |

> 📝 In this example the restriction (`meins = 'ST'`) is a **static** condition, applied identically to every user. Real-world DCL roles usually restrict data **per user**, typically via `aspect pfcg_auth` referencing classic authorization objects, or via `$session.user` combined with an authorization/assignment table. A static condition like this is more of a fixed business rule (e.g. "this view is scoped to piece-quantity materials only") than a user-specific security check.

## `@AccessControl.authorizationCheck` Modes

| Mode | Meaning |
|---|---|
| `#CHECK` | A DCL role **must** exist and is evaluated on every read; if no role is assigned, access is denied (fails closed). |
| `#NOT_REQUIRED` | No authorization check is performed at this view's level — typically used on low-level interface views that are always consumed through a higher-level, checked consumption view. |
| `#NOT_ALLOWED` | The view cannot be selected from directly by external tools/generic access at all — reserved for very restricted, internal-only artifacts. |

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

## Common Mistakes

- ❌ Setting `@AccessControl.authorizationCheck: #CHECK` without ever creating/assigning a matching DCL role — results in access being denied for everyone, which can look like a "broken view" bug when it's actually a missing role assignment.
- ❌ Writing a DCL role with a static `WHERE` condition when the intent was a **per-user** check — static conditions apply to *all* users identically, they are not a substitute for `aspect pfcg_auth`-based checks.
- ❌ Setting `#NOT_REQUIRED` on a view that is later published via OData — this silently removes the built-in enforcement point precisely where it matters most (external access).
- ❌ Forgetting the trailing semicolon after `grant select on ... where ...;` inside `define role { }` — DCL statements are terminated individually, unlike the field list of a `define view`.

## Performance Considerations

- DCL `WHERE` restrictions are merged into the generated SQL of every consuming query — a simple, indexed field restriction (like a plant or company code) is typically cheap; deeply nested `aspect pfcg_auth` checks across multiple authorization objects can add noticeable overhead on very large data sets, so keep authorization models as simple as the business genuinely requires.

## SAP Best Practices

- Default new consumption/root views to `@AccessControl.authorizationCheck: #CHECK`; only relax to `#NOT_REQUIRED` for pure interface/building-block views that are never consumed directly.
- Prefer `aspect pfcg_auth(...)` over hardcoded/static `WHERE` conditions whenever the restriction should genuinely depend on the calling user's authorizations.
- Name DCL roles consistently and document, via `@EndUserText.label`, exactly which view and business rule they secure.
- Test authorization behavior with a real, restricted test user — not just as a "power user" who bypasses most checks (`SU53`/`ST01`/authorization trace tools help here).

## Interview Notes

- **Q: What is the difference between `@AccessControl.authorizationCheck: #CHECK` and `#NOT_REQUIRED`?**
  A: `#CHECK` requires and enforces an associated DCL role's restrictions on every read; `#NOT_REQUIRED` performs no check at that view's level (typically because it's an internal building-block view, always wrapped by a checked consumption view).
- **Q: How do you tie a DCL role to the classic SAP authorization concept (`PFCG`/`SU21`)?**
  A: Using `aspect pfcg_auth(<AuthorizationObject>, <Field>, <ActivityCondition>)` inside the role's `WHERE` clause, instead of a hardcoded/static condition.
- **Q: What does `@MappingRole: true` mean?**
  A: It marks the DCL source as a mapping role, where the `WHERE` restriction is expressed directly against the CDS view's own fields.

## Related Chapters

- [08-OData-and-Consumption/OData.md](../08-OData-and-Consumption/OData.md) — why access control matters even more once a view is externally published
- [04-CDS-Annotations/Annotation-Global.md](../04-CDS-Annotations/Annotation-Global.md) — `@AccessControl.authorizationCheck` alongside other global annotations
- [05-Filtering-and-Parameters/Session.md](../05-Filtering-and-Parameters/Session.md) — `$session.user`, sometimes used in custom authorization designs
