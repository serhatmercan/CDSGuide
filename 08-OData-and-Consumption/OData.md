# OData & Service Consumption

> **CDS generation:** This chapter covers **both** service-exposure generations — the classic CDS OData auto-exposure annotation, and the current service definition / service binding model. See [Classic vs Modern CDS](../02-CDS-Basics/Classic-vs-Modern.md) for the wider picture.

## What is it?

A CDS view models data; it does not, by itself, make that data reachable over HTTP. Turning a model into a consumable **business service** is a separate step, and SAP has two distinct mechanisms for it:

1. **Classic CDS auto-exposure** — a single annotation, `@OData.publish: true`, on the view itself.
2. **Service definition + service binding** — two separate artifacts that together decide *what* is exposed and *over which protocol*.

Both are covered below. The classic mechanism is retained in full because it remains widespread in existing landscapes and you will need to read it long before you need to write it.

---

## 1. Classic CDS Auto-Exposure

`@OData.publish: true` is the classic CDS OData auto-exposure mechanism: annotate the view, activate it, and a Gateway-registered OData service is generated from the view's structure — no separate Gateway project in `SEGW`, no redefinition of the data model.

### Example (original note)

```abap
@AbapCatalog.sqlViewName: 'ZSM_CDS_001'

@EndUserText.label: 'DDL View For OData Service'

@OData.publish: true

define view ZSM_I_001
  as select from mara

{
  key matnr,

      mtart
}

// GW Client
// Service Name: ZSM_I_001_CDS
// URI: /sap/opu/odata/sap/ZSM_I_001_CDS/ZSM_I_001
```

### What happens when you activate this

1. Activating the view with `@OData.publish: true` **generates** an OData service based on the view's structure (visible in `/IWFND/MAINT_SERVICE` and `/IWBEP/REG_SERVICE`).
2. The generated service name follows the pattern `<ViewName>_CDS` (here `ZSM_I_001_CDS`).
3. The service must still be **activated** in `/IWFND/MAINT_SERVICE` (Add Service) before it is callable — annotation-driven generation does not automatically activate it in the Gateway hub.
4. Once active, the entity set is reachable at a URI like:
   `/sap/opu/odata/sap/ZSM_I_001_CDS/ZSM_I_001`

### Where you will still meet it

Across existing on-premise landscapes, on views written before the service model became the standard route, and in quick read-oriented exposures that were never reworked. Encountering it is not in itself a defect to fix — but see the security note below, and treat any externally reachable service as something to check rather than assume.

### Security

Anything exposed over OData is reachable by consumers that never pass through ABAP authority-check code, so the CDS model itself has to carry the restriction. Two points, both covered in [09-Security/AccessControl.md](../09-Security/AccessControl.md):

- Set `@AccessControl.authorizationCheck: #CHECK` **and create the DCL role**. The annotation alone enforces nothing — a view annotated `#CHECK` with no role returns everything.
- Never publish a view annotated `#NOT_ALLOWED`, which switches access control off entirely.

---

## 2. Service Definition

A **service definition** is a CDS artifact that selects which CDS entities become part of a business service. It is written in CDS SDL (Service Definition Language):

```abap
@EndUserText.label: 'Example CDS Service'
define service ZUI_EXAMPLE {
  expose ZSM_C_EXAMPLE as Example;
}
```

Rules worth knowing:

| Rule | Detail |
|---|---|
| Statement | `define service <name> { ... }` (the `define` keyword is optional) |
| Exposing entities | Each entity is exposed with its own `expose` statement |
| Statement termination | Each `expose` statement **must** be closed with a semicolon |
| Minimum content | At least one CDS entity must be exposed |
| Aliases | `expose <entity> as <alias>` is optional; when given, the **alias** is the name consumers use to access the entity |

The essential property is that a service definition is **protocol-independent**. It states *what* is exposed and nothing about *how*. It contains no mention of OData, no version, no URL. That independence is what allows the same service definition to be bound to more than one protocol through multiple service bindings.

Multiple entities, with aliases:

```abap
@EndUserText.label: 'Example Sales Service'
define service ZUI_EXAMPLE_SALES {
  expose ZSM_C_SalesOrder     as SalesOrder;
  expose ZSM_C_SalesOrderItem as SalesOrderItem;
}
```

---

## 3. Service Binding

A **service binding** links a service definition to a concrete protocol, and it is where the abstract "what" becomes a callable endpoint.

- A service definition that is used in a business service **must** be linked to a RESTful protocol by a service binding.
- The binding determines the **protocol and version** — OData V2 or OData V4, depending on the scenario and platform.
- The same service definition can be used by **several** bindings, so one exposed model can be offered over more than one protocol without duplicating the definition.
- The binding object is **created and configured in ADT**. It is not written as CDS source, and there is no DDL syntax for it — which is why no code sample is shown here.
- Local publishing and the service preview belong to the service binding workflow, not to the CDS view or the service definition.

> 📝 If you are looking for "the code for a service binding", there isn't any. Trying to write one in DDL is a common early misunderstanding; the binding is an ADT artifact with a UI, and its important properties (binding type, protocol version, published state) are set there.

---

## 4. How It Fits Together with RAP

The full modern chain, from stored data to consumer:

```
CDS data model (view entity)
  └─> CDS projection view              adapts the model for one specific service
        └─> behavior definition        only where transactional behaviour is required
              └─> service definition   what is exposed
                    └─> service binding  over which protocol (OData V2 / V4)
                          └─> consumer   Fiori Elements, custom UI, API client
```

Read-only analytical or API scenarios simply omit the behavior definition — the rest of the chain is unchanged. RAP itself (managed vs. unmanaged, draft handling, behavior implementation) is beyond this chapter; the point here is only where service exposure sits in the sequence, and that CDS is the foundation of all of it.

---

## 5. Classic vs Modern Summary

| | Classic auto-exposure | Service definition + binding |
|---|---|---|
| Declared in | An annotation on the view: `@OData.publish: true` | Two separate artifacts: a CDS service definition, plus a service binding created in ADT |
| Granularity | One view, one service | Several entities selected into one service |
| Protocol choice | Fixed by the mechanism | Chosen in the binding (OData V2 or V4, per scenario/platform) |
| Protocol independence | No | Yes — the definition names no protocol |
| Reuse | One service per published view | One definition, multiple bindings |
| Transactional behaviour | Not the mechanism for it | Behavior definition, where required |
| Typical context | Existing on-premise landscapes, read-oriented exposure | Current RAP / service-oriented and cloud-ready development |

For current RAP and service-oriented development, SAP's service model uses service definitions and service bindings.

---

## Common Mistakes

- ❌ Expecting a `@OData.publish` service to be immediately callable right after activating the CDS view — it still needs to be added/activated via `/IWFND/MAINT_SERVICE` (or the equivalent automated transport step in a CI/CD pipeline).
- ❌ Publishing every interface-level view directly — this couples low-level building-block views to external consumers. Prefer exposing a dedicated **consumption view** (`@VDM.viewType: #CONSUMPTION`, see [04-CDS-Annotations/Annotation-Global.md](../04-CDS-Annotations/Annotation-Global.md)) layered on top of interface views. This applies to both mechanisms.
- ❌ Exposing a view without access control, or with `@AccessControl.authorizationCheck: #CHECK` but no DCL role — see [09-Security/AccessControl.md](../09-Security/AccessControl.md).
- ❌ Looking for service-binding *syntax* — the binding is an ADT artifact, not CDS source.
- ❌ Treating a service definition as OData-specific — it is protocol-independent by design.

## Performance Considerations

- OData requests translate into filtered/paged `SELECT`s against the underlying CDS entity — the same performance principles apply (push filtering down, avoid `SELECT *`, use associations for optional expansions).
- `$expand` on OData navigation properties triggers the corresponding CDS associations — deep `$expand` chains can produce expensive multi-way joins; be deliberate about which associations are exposed for navigation.

## SAP Best Practices

- Expose only **consumption/projection views**, never raw interface views.
- Pair any exposed view with `@AccessControl.authorizationCheck: #CHECK` **and** an actual DCL role.
- For new service-oriented development, model the service with a **service definition and service binding** rather than view-level auto-exposure.
- Keep the service definition free of protocol assumptions — that is the binding's job.

## Interview Notes

- **Q: What does `@OData.publish: true` do?**
  A: It is the classic CDS OData auto-exposure mechanism — activating the annotated view generates a Gateway OData service from the view's structure, which must then be activated in `/IWFND/MAINT_SERVICE` before it is callable.
- **Q: What is the difference between a service definition and a service binding?**
  A: The service definition selects *which* CDS entities are exposed and is protocol-independent; the service binding links that definition to a concrete protocol and version (OData V2 or V4) and is created in ADT. One definition can serve multiple bindings.
- **Q: Where does a projection view fit in?**
  A: Between the data model and the service — it adapts a CDS view entity for one specific service, carrying the consumer-facing annotations so the underlying interface model stays reusable.

## Related Chapters

- [02-CDS-Basics/Classic-vs-Modern.md](../02-CDS-Basics/Classic-vs-Modern.md) — why both exposure generations appear in this guide
- [04-CDS-Annotations/Annotation-Global.md](../04-CDS-Annotations/Annotation-Global.md) — `@VDM.viewType` and other view-level annotations relevant to consumption views
- [09-Security/AccessControl.md](../09-Security/AccessControl.md) — securing anything that is exposed
- [04-CDS-Annotations/Annotation-LocalEx.md](../04-CDS-Annotations/Annotation-LocalEx.md) — UI annotations that shape how exposed data renders in Fiori Elements
