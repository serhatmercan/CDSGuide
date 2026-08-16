# Global Annotations

> **CDS generation:** Several annotations below are **specific to DDIC-based views** and do not apply to view entities — notably `@AbapCatalog.sqlViewName`, `@AbapCatalog.buffering` and `@ClientHandling.*`. Others belong to the pre-RAP transactional model rather than RAP. The three notes after the reference table spell out which is which; see also [Classic vs Modern CDS](../02-CDS-Basics/Classic-vs-Modern.md).

## What is it?

**Global annotations** are applied at the **view level** (placed before `define view`), affecting the CDS view as a whole — buffering, access control, OData exposure, view type, analytics behavior, and more.

## Why is it used?

Global annotations turn a plain SQL view definition into a rich, semantically described artifact that SAP tools (Fiori Elements, Gateway, Analytics, RAP) can interpret automatically, without additional manual configuration.

## When should it be used?

Apply global annotations whenever the *view as a whole* needs a behavior or piece of metadata — as opposed to **local (element-level) annotations**, which describe individual fields (see [Annotation-Local.md](Annotation-Local.md)).

## Reference List (original note, explained)

```abap
// Global Annotations for CDS Views
@AbapCatalog:

{
  buffering: {
    // View Buffer Property Status || w/ Type
    status: #ACTIVE,

    // View Buffer Property        || w/ Status
    type: #FULL
  },

  compiler: {
    // Compare Filter Behavior: true || false
    compareFilter : true
  },

  // Key Derivation - > true: From CDS Key || false: From Tables
  preserveKey : true,

  // View Name(SE11)
  sqlViewName : 'ZSM_CDS_001',

  // View Enhancement Category: GROUP_BY || NONE || UNION || PROJECTION_LIST
  viewEnhancementCategory :[#NONE]
}

// Check Access Control = #CHECK || #NOT_ALLOWED || #NOT_REQUIRED
@AccessControl.authorizationCheck: #NOT_REQUIRED

// Analytics Query
@Analytics.query : true

// Client Handling Algorithm: AUTOMATED || NONE || SESSION_VARIABLE
@ClientHandling.algorithm : #SESSION_VARIABLE

// Consumption Ranking
@Consumption.ranked : true

// CDS Description
@EndUserText.label : 'CDS Description'

// Allow Extensions: true || false
@Metadata.allowExtensions : true

@ObjectModel:

{
  createEnabled: true,
  deleteEnabled: true,
  updateEnabled: true,

  usageType: {
    // Data Class: CUSTOMIZING || MASTER || META || MIXED || ORGANIZATIONAL || TRANSACTIONAL
    dataClass: #MIXED,

    // Service Quality: A || B || C || D || X || P
    serviceQuality: #X,

    // Size Category: S || M || L || XL || XXL
    sizeCategory: #S
  },

  query: {
    // Implemented By: Class Name
    implementedBy: 'ABAP:ZSM_CL_IM_QUERY'
  }
}

// Display OData Service
@OData.publish: true

// Searchable
@Search.searchable: true

@UI:

{
  chart:[{
    chartType: #COLUMN,
    dimensionAttributes: {
        dimension: 'SalesDocument',
        role: #SERIES
    },
    dimensions :['SalesDocument'],
    measureAttributes:[{
        measure: 'NetAmount',
        role: #AXIS_1
    },
    {
        measure: 'NetPriceAmount',
        role: #AXIS_1
    }],
    measures:['NetAmount', 'NetPriceAmount'],
    title: 'Order Net Amount',
    qualifier: 'ChartLineItem'
  }],

  headerInfo: {
    description: {
        type: #STANDARD,
        value: 'CustomerName'
    },
    title: {
        type: #STANDARD,
        value: 'SalesOrderID'
    },
    typeName: 'Purchase Order',
    typeNamePlural: 'Purchase Orders'
  },

  presentationVariant:[{
    maxItems: '5',
    sortOrder:[{
        by: 'Matnr',
        direction: #DESC
    }],
    qualifier: 'Top5Changed',
    visualizations:[{
        type: #AS_LINEITEM
    }]
  }]
}

// View Types: BASIC || COMPOSITE || CONSUMPTION || EXTENSION || DERIVATION_FUNCTION || TRANSACTIONAL
@VDM.viewType: #CONSUMPTION
```

## Annotation-by-Annotation Reference

| Annotation | Purpose |
|---|---|
| `@AbapCatalog.sqlViewName` | Physical SQL view name (max 16 chars). |
| `@AbapCatalog.buffering` | **DDIC-based views only.** Enables classic table buffering on the *generated database view* — `status: #ACTIVE/#INACTIVE`, `type: #FULL/#SINGLE/#GENERIC`. View entities have no generated view and use a separate mechanism (see the buffering note below). |
| `@AbapCatalog.compiler.compareFilter` | Optimizes filter comparisons at compile time. |
| `@AbapCatalog.preserveKey` | Keeps the key definition stable across changes for compatibility. |
| `@AbapCatalog.viewEnhancementCategory` | Declares **how** the view may be extended: `#NONE`, `#PROJECTION_LIST` (fields only), `#UNION` (union branches), `#GROUP_BY` (aggregation). Required alongside `@Metadata.allowExtensions` for [view extensions](../03-Data-Modeling/Extend.md). |
| `@AccessControl.authorizationCheck` | Declares whether a DCL role is evaluated on read (see [09-Security/AccessControl.md](../09-Security/AccessControl.md)). `#CHECK` — evaluated *if* a role exists, syntax warning if none. `#NOT_REQUIRED` — same runtime behaviour, no warning. `#NOT_ALLOWED` — access control is **switched off**; any role is ignored at runtime. Note that `#NOT_ALLOWED` is the least protective value, not the most. |
| `@Analytics.query` | Marks the view as an analytical query, consumable by SAP Analytics tools / `RSRT`. |
| `@ClientHandling.algorithm` | **DDIC-based views only.** Selects *how* client handling is implemented internally: `#AUTOMATED` (the default) or `#SESSION_VARIABLE`. Both produce the same result for a client-specific view; `#SESSION_VARIABLE` can improve performance by concentrating on a single client. Neither annotation makes a view cross-client — client dependency is determined by the **data sources** the view uses. See the client-handling note below. |
| `@Consumption.ranked` | Marks the entity for automatic ranking/sorting of search results in value-help scenarios, where the required search prerequisites are in place. |
| `@EndUserText.label` | Human-readable description. |
| `@Metadata.allowExtensions` | Allows [`extend view`](../03-Data-Modeling/Extend.md) on this view. |
| `@ObjectModel.createEnabled` / `updateEnabled` / `deleteEnabled` | Transactional capability flags evaluated by **SADL / BOPF** in the classic ABAP Programming Model for SAP Fiori. They are *not* how RAP declares capabilities — see the programming-model note below. |
| `@ObjectModel.usageType` | Classifies the view's business role — `dataClass` (nature of the data), `serviceQuality`, `sizeCategory` (expected data volume). |
| `@ObjectModel.query.implementedBy` | For **custom entities** / RAP query providers, the ABAP class implementing the read logic. |
| `@OData.publish` | Auto-generates and exposes an OData service for this view (classic Gateway; see [08-OData-and-Consumption/OData.md](../08-OData-and-Consumption/OData.md)). |
| `@Search.searchable` | Enables the view for SAP Enterprise Search / Fiori search. |
| `@UI.chart` / `headerInfo` / `presentationVariant` | UI metadata driving Fiori Elements list reports and analytical apps: chart definitions, object-page header, top-N presentation variants. |
| `@VDM.viewType` | Classifies the view's role in the Virtual Data Model. The annotation definition provides `#BASIC` (interface view), `#COMPOSITE`, `#CONSUMPTION`, `#EXTENSION`, `#DERIVATION_FUNCTION` and `#TRANSACTIONAL`. |

## Three Context Notes Worth Reading Once

These three annotations are the ones most often carried over from a classic view into a view entity, or from a pre-RAP model into a RAP one, where they no longer mean what the author expects.

### Client handling: classic vs. view entity

| | DDIC-based `define view` | `define view entity` / projection view |
|---|---|---|
| How it is configured | Explicitly, via `@ClientHandling.type` and `@ClientHandling.algorithm` | **Implicit and automatic** — no annotation needed |
| Default algorithm | `#AUTOMATED` (with `@ClientHandling.type` defaulting to `#INHERITED`) | n/a |
| What makes a view cross-client | The **data sources** it selects from, not the annotation | Same — determined by the data sources |

`#AUTOMATED` and `#SESSION_VARIABLE` produce the **same result** for a client-specific view; they differ only in how client handling is implemented internally, with `#SESSION_VARIABLE` able to improve performance by concentrating on a single client. Neither value turns a client-specific view into a cross-client one.

Do **not** carry `@ClientHandling` annotations into a view entity — client handling there is handled by the framework. See [05-Filtering-and-Parameters/Session.md](../05-Filtering-and-Parameters/Session.md) for `$session.client`, and [02-CDS-Basics/Classic-vs-Modern.md](../02-CDS-Basics/Classic-vs-Modern.md) for the wider generational picture.

### `@ObjectModel` transactional flags belong to the pre-RAP model

| Model | How create/update/delete capability is declared |
|---|---|
| Classic / pre-RAP (ABAP Programming Model for SAP Fiori) | `@ObjectModel.createEnabled` / `updateEnabled` / `deleteEnabled`, evaluated by **SADL / BOPF** |
| **RAP** | A **behavior definition** for the entity: `define behavior for <entity> { create; update; delete; ... }` |

The annotations are still evaluated in the SADL/BOPF scenarios they were designed for — the point is that they are *not* the RAP mechanism. Writing them on a RAP root or projection view does not give it transactional behaviour; a behavior definition does.

### Buffering: classic annotation vs. CDS entity buffer

`@AbapCatalog.buffering` configures classic table buffering on the **generated database view** of a DDIC-based CDS view, with the same prerequisites as buffering a classic database view. A view entity has no generated database view, so that annotation does not apply to it.

Buffering for view entities is a separate mechanism: a **CDS entity buffer**, declared with the statement `define view entity buffer on <cds_view_entity>`, with the entity itself opting in via `@AbapCatalog.entityBuffer.definitionAllowed`. Two documented consequences are worth knowing: an entity that allows a buffer definition cannot be extended, and setting the annotation on a union view raises a syntax check warning, because a union may produce duplicate key records while the buffer needs a unique key in some scenarios.

> Availability of the entity-buffer mechanism is release-dependent. Check the ABAP Keyword Documentation for your target release before relying on it.

## Common Mistakes

- ❌ Enabling `@AbapCatalog.buffering` on a view with volatile/frequently-changing data — stale buffered data is a common, hard-to-diagnose production bug.
- ❌ Copying `@AbapCatalog.buffering` or `@ClientHandling.*` from a classic view into a view entity — neither applies there.
- ❌ Expecting `@ObjectModel.createEnabled`/`updateEnabled`/`deleteEnabled` to give a RAP entity transactional behaviour — that is what a behavior definition does.
- ❌ Setting `@OData.publish: true` on internal/technical views not meant for external consumption.
- ❌ Forgetting `@Metadata.allowExtensions: true` and then wondering why `extend view` fails to activate.
- ❌ Mismatching `@ObjectModel.usageType.sizeCategory` with actual data volume — this hint affects how consuming tools (e.g. Fiori Elements paging) behave.

## Performance Considerations

- **Buffering** is powerful but only appropriate for master/customizing data that rarely changes — never buffer transactional data.
- `@Analytics.query: true` changes the execution path to the analytic engine, which behaves differently (and can be faster) for aggregation-heavy scenarios than a plain transactional read.

## SAP Best Practices

- Set `@AccessControl.authorizationCheck: #CHECK` by default for consumption/root views — and create the DCL role, since the annotation on its own enforces nothing. Use `#NOT_REQUIRED` only for pure interface (building-block) views not exposed directly.
- Classify every custom view with `@VDM.viewType` consistently — it documents the view's role in your data model for future maintainers.
- Keep `@ObjectModel.usageType` accurate; SAP-delivered analysis tools and even performance recommendations rely on it.

## Interview Notes

- **Q: What is the difference between `@AccessControl.authorizationCheck: #CHECK` and `#NOT_REQUIRED`?**
  A: Runtime behaviour is effectively the same — an assigned DCL role is evaluated, and nothing is enforced if no role exists. The difference is design-time: `#CHECK` raises a syntax check warning when the role is missing, `#NOT_REQUIRED` does not.
- **Q: What does `@AbapCatalog.viewEnhancementCategory` control?**
  A: Which kind of `extend view` enhancement is allowed on this view (field list, union branch, or group-by change).

## Related Chapters

- [Annotation-Local.md](Annotation-Local.md) — element-level annotations
- [09-Security/AccessControl.md](../09-Security/AccessControl.md) — DCL roles referenced by `@AccessControl.authorizationCheck`
- [08-OData-and-Consumption/OData.md](../08-OData-and-Consumption/OData.md) — `@OData.publish` in context
