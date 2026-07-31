# OData Exposure

## What is it?

`@OData.publish: true` is the simplest way to expose a CDS view as an **OData V2 service** through the classic SAP Gateway, without manually building a Gateway project in `SEGW`.

## Why is it used?

- To make CDS view data consumable by external clients: Fiori apps, Excel, Postman/API testing, third-party integrations.
- To avoid manually redefining the data model in a separate Gateway service — the CDS view *is* the service definition.

## When should it be used?

Use `@OData.publish: true` for straightforward, read-oriented OData V2 exposure of a single CDS view. For **RAP**-based, full CRUD, transactional OData V4 services, the view instead becomes part of a **RAP business object** (behavior definitions/projections) — a more involved topic beyond a single annotation, only summarized here since it builds on everything in [04-CDS-Annotations](../04-CDS-Annotations/Annotation-Global.md).

## Example (original note)

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

" GW Client
" Service Name: ZSM_I_001_CDS
" URI: /sap/opu/odata/sap/ZSM_I_001_CDS/ZSM_I_001
```

### What happens when you activate this

1. Activating the view with `@OData.publish: true` automatically **generates and registers** a Gateway OData service (visible in `/IWFND/MAINT_SERVICE` and `/IWBEP/REG_SERVICE`).
2. The generated service name follows the pattern `<ViewName>_CDS` (here `ZSM_I_001_CDS`).
3. The service must still be **activated** in `/IWFND/MAINT_SERVICE` (Add Service) before it is callable — annotation-driven generation does not automatically activate it in the Gateway hub.
4. Once active, the entity set is reachable at a URI like:
   `/sap/opu/odata/sap/ZSM_I_001_CDS/ZSM_I_001`

## Common Mistakes

- ❌ Expecting the service to be immediately callable right after activating the CDS view — it still needs to be added/activated via `/IWFND/MAINT_SERVICE` (or the equivalent automated transport step in a CI/CD pipeline).
- ❌ Publishing every interface-level view directly via `@OData.publish` — this couples low-level building-block views to external consumers. Prefer publishing a dedicated **consumption view** (`@VDM.viewType: #CONSUMPTION`, see [04-CDS-Annotations/Annotation-Global.md](../04-CDS-Annotations/Annotation-Global.md)) layered on top of interface views instead.
- ❌ Forgetting `@AccessControl.authorizationCheck: #CHECK` on a published, externally-reachable view — anything exposed via OData should almost always enforce access control (see [09-Security/AccessControl.md](../09-Security/AccessControl.md)).

## Performance Considerations

- OData requests translate into filtered/paged `SELECT`s against the underlying CDS view — the same performance principles apply (push filtering down, avoid `SELECT *`, use associations for optional expansions).
- `$expand` on OData navigation properties triggers the corresponding CDS associations — deep `$expand` chains can produce expensive multi-way joins; be deliberate about which associations are exposed for navigation.

## SAP Best Practices

- Publish only **consumption views**, not raw interface views, as OData services.
- Always pair `@OData.publish` with proper `@AccessControl.authorizationCheck: #CHECK` and a DCL role.
- For anything beyond simple read scenarios (create/update/delete, complex business logic, drafts), model the service through **RAP** instead of the classic `@OData.publish` annotation — it is the SAP-recommended path for new, transactional Fiori apps.

## Interview Notes

- **Q: What does `@OData.publish: true` actually do?**
  A: It auto-generates and registers a classic Gateway OData V2 service based on the CDS view's structure, which must still be activated via `/IWFND/MAINT_SERVICE` before use.
- **Q: What's the difference between this classic approach and RAP-based OData exposure?**
  A: `@OData.publish` gives you a quick, mostly read-oriented service directly from one view; RAP builds a full business object (with behavior definitions, projections, and V4 OData) supporting proper transactional CRUD, drafts, and validations.

## Related Chapters

- [04-CDS-Annotations/Annotation-Global.md](../04-CDS-Annotations/Annotation-Global.md) — `@VDM.viewType` and other view-level annotations relevant to consumption views
- [09-Security/AccessControl.md](../09-Security/AccessControl.md) — securing published services
- [04-CDS-Annotations/Annotation-LocalEx.md](../04-CDS-Annotations/Annotation-LocalEx.md) — UI annotations that shape how the exposed data renders in Fiori Elements
