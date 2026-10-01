# Access Control (DCL) & Authorization Checks

> **CDS generation:** DCL applies across **both** generations — `define role` and `@AccessControl.authorizationCheck` work the same way for DDIC-based views and view entities. The one generational difference is a security-relevant one: a DDIC-based view also has a generated database view, and reading *that* bypasses access control entirely. View entities have no such second path. See [02-CDS-Basics/Program.md](../02-CDS-Basics/Program.md).

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

### Bypassing Access Control: `WITH PRIVILEGED ACCESS`

> 🕒 **VERSION-DEPENDENT** — availability of this addition depends on
> the ABAP release. Verify it against the ABAP Keyword Documentation
> for your target system before relying on it.

When an ABAP SQL query reads a CDS entity directly, the DCL roles of that entity are applied implicitly. The addition `WITH PRIVILEGED ACCESS` switches CDS access control **off** for the data source it is specified for — delivered and self-defined roles alike.

> 📌 **PARTIAL SNIPPET** — ABAP statements only; `lv_ekorg` (purchasing organization) is assumed to be declared and filled.

```abap
" a) Default read: the DCL roles of I_PurchaseOrderAPI01 apply implicitly —
"    only rows the user is authorized to see are returned.
SELECT FROM I_PurchaseOrderAPI01
  FIELDS PurchaseOrder, Supplier, PurchasingOrganization
  WHERE PurchasingOrganization = @lv_ekorg
  INTO TABLE @DATA(lt_header).

" >>> Explicit authorization check for the purchasing organization (lv_ekorg) belongs here,
"     before any privileged read.

" b) Both CDS data sources privileged: the addition goes right after each
"    data source and before its alias, and is repeated per CDS data source.
SELECT FROM I_PurchaseOrderAPI01 WITH PRIVILEGED ACCESS AS hdr
         INNER JOIN I_PurchaseOrderItemAPI01 WITH PRIVILEGED ACCESS AS itm
           ON itm~PurchaseOrder = hdr~PurchaseOrder
  FIELDS hdr~PurchaseOrder, hdr~Supplier, itm~PurchaseOrderItem, itm~OrderQuantity
  WHERE hdr~PurchasingOrganization = @lv_ekorg
  INTO TABLE @DATA(lt_items_privileged).

" c) Only the header is privileged: I_PurchaseOrderItemAPI01 is still
"    access-controlled. The addition is per data source, not per statement.
SELECT FROM I_PurchaseOrderAPI01 WITH PRIVILEGED ACCESS AS hdr
         INNER JOIN I_PurchaseOrderItemAPI01 AS itm
           ON itm~PurchaseOrder = hdr~PurchaseOrder
  FIELDS hdr~PurchaseOrder, hdr~Supplier, itm~PurchaseOrderItem, itm~OrderQuantity
  WHERE hdr~PurchasingOrganization = @lv_ekorg
  INTO TABLE @DATA(lt_items_mixed).
```

#### Notes and Common Mistakes

1. ❌ **Assuming one addition covers the whole statement.** It is per data source: each CDS entity in a join needs its own `WITH PRIVILEGED ACCESS` (case *b* vs. case *c*).
2. ❌ **Expecting an effect on database tables or classic views.** They have no CDS access control, so the addition does nothing there — no syntax error, simply no effect.
3. ❌ **Combining it with a path expression.** The addition cannot be used together with a path expression on the same data source.
4. ❌ **Treating an empty result as "no data".** Under access control, the program cannot tell "no data" from "not authorized". With the addition, that filter is gone — the program alone is responsible for authorization.
5. ❌ **Adding it to lower layers.** Implicit access control applies only to direct ABAP SQL access. An entity read indirectly, as a data source of another CDS entity, is not checked anyway (see *Access control is not inherited between CDS entities*, below), so the addition matters only at the top-level read.
6. ❌ **Using it to "fix" a query that returns nothing.** Legitimate uses are technical/background processing, determinations or existence checks whose results are not shown to the user, and reads after an explicit `AUTHORITY-CHECK`. An empty result for a real user is an authorization finding to resolve, not something to bypass.

#### Best Practices

- Justify every `WITH PRIVILEGED ACCESS` with a comment stating why access control must not apply to this read.
- Keep privileged reads in a small, dedicated method so they are easy to find and review.

#### Interview Notes

- **Q: What does `WITH PRIVILEGED ACCESS` do, and why is it risky?**
  A: It switches CDS access control off for the data source it follows, so the DCL roles of that entity are not applied. It is risky because the read then returns data regardless of the user's authorizations — responsibility for authorization moves entirely to the program, and a missing explicit check silently exposes data.

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
