# Global Annotations

## What is it?

**Global annotations** are applied at the **view level** (placed before `define view`), affecting the CDS view as a whole — buffering, access control, OData exposure, view type, analytics behavior, and more.

## Why is it used?

Global annotations turn a plain SQL view definition into a rich, semantically described artifact that SAP tools (Fiori Elements, Gateway, Analytics, RAP) can interpret automatically, without additional manual configuration.

## When should it be used?

Apply global annotations whenever the *view as a whole* needs a behavior or piece of metadata — as opposed to **local (element-level) annotations**, which describe individual fields (see [Annotation-Local.md](Annotation-Local.md)).

## Reference List (original note, explained)

```abap
" Global Annotations for CDS Views
@AbapCatalog:

{
  buffering: {
    " View Buffer Property Status || w/ Type
    status: #ACTIVE,

    " View Buffer Property        || w/ Status
    type: #FULL
  },

  compiler: {
    " Compare Filter Behavior: true || false
    compareFilter : true
  }

  preserveKey : true,

  " View Name(SE11) - > true: From CDS Key  || false: From Tables
  sqlViewName : 'ZSM_CDS_001',

  " View Enhancement Category: GROUP_BY || NONE || UNION || PROJECTION_LIST
  viewEnhancementCategory :[#NONE]
}

" Check Access Control = #CHECK || #NOT_ALLOWED || #NOT_REQUIRED
@AccessControl.authorizationCheck: #NOT_REQUIRED

" Analytics Query
@Analytics.query : true

" Client Handling Algorithm: AUTOMATED || NONE || SESSION_VARIABLE
@ClientHandling.algorithm : #SESSION_VARIABLE

" Consumption Ranking
@Consumption.ranked : true

" CDS Description
@EndUserText.label : 'CDS Description'

" Allow Extensions: true || false
@Metadata.allowExtensions : true

@ObjectModel:

{
  createEnabled: true,
  deleteEnabled: true,
  updateEnabled: true,

  usageType: {
    " Data Class: CUSTOMIZING || MASTER || META || MIXED || ORGANIZATIONAL || TRANSACTIONAL
    dataClass: #MIXED,

    " Service Quality: A || B || C || D || X || P
    serviceQuality: #X,

    " Size Category: S || M || L || XL || XXL
    sizeCategory: #S
  },

  query: {
    " Implemented By: Class Name
    implementedBy: 'ABAP:ZSM_CL_IM_QUERY'
  }
}

" Display OData Service
@OData.publish: true

" Searchable
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

" View Types: BASIC || COMPOSITE || CONSUMPTION || EXTENSION || DERIVATION_FUNCTION || TRANSACTIONAL
@VDM.viewType: #CONSUMPTION
```

## Annotation-by-Annotation Reference

| Annotation | Purpose |
|---|---|
| `@AbapCatalog.sqlViewName` | Physical SQL view name (max 16 chars). |
| `@AbapCatalog.buffering` | Enables **table buffering** for the generated view — `status: #ACTIVE/#INACTIVE`, `type: #FULL/#SINGLE/#GENERIC`. |
| `@AbapCatalog.compiler.compareFilter` | Optimizes filter comparisons at compile time. |
| `@AbapCatalog.preserveKey` | Keeps the key definition stable across changes for compatibility. |
| `@AbapCatalog.viewEnhancementCategory` | Declares **how** the view may be extended: `#NONE`, `#PROJECTION_LIST` (fields only), `#UNION` (union branches), `#GROUP_BY` (aggregation). Required alongside `@Metadata.allowExtensions` for [view extensions](../03-Data-Modeling/Extend.md). |
| `@AccessControl.authorizationCheck` | `#CHECK` enforces a DCL role (see [09-Security/AccessControl.md](../09-Security/AccessControl.md)); `#NOT_REQUIRED` skips it; `#NOT_ALLOWED` blocks direct external access. |
| `@Analytics.query` | Marks the view as an analytical query, consumable by SAP Analytics tools / `RSRT`. |
| `@ClientHandling.algorithm` | `#SESSION_VARIABLE` (default, filters by session client automatically), `#AUTOMATED` (client field auto-detected), or `#NONE` (cross-client view). |
| `@Consumption.ranked` | Enables ranking-related consumption behavior for value helps/search. |
| `@EndUserText.label` | Human-readable description. |
| `@Metadata.allowExtensions` | Allows [`extend view`](../03-Data-Modeling/Extend.md) on this view. |
| `@ObjectModel.createEnabled` / `updateEnabled` / `deleteEnabled` | RAP-relevant flags describing which operations the entity supports. |
| `@ObjectModel.usageType` | Classifies the view's business role — `dataClass` (nature of the data), `serviceQuality`, `sizeCategory` (expected data volume). |
| `@ObjectModel.query.implementedBy` | For **custom entities** / RAP query providers, the ABAP class implementing the read logic. |
| `@OData.publish` | Auto-generates and exposes an OData service for this view (classic Gateway; see [08-OData-and-Consumption/OData.md](../08-OData-and-Consumption/OData.md)). |
| `@Search.searchable` | Enables the view for SAP Enterprise Search / Fiori search. |
| `@UI.chart` / `headerInfo` / `presentationVariant` | UI metadata driving Fiori Elements list reports and analytical apps: chart definitions, object-page header, top-N presentation variants. |
| `@VDM.viewType` | Classifies the view's role in the Virtual Data Model: `#BASIC` (interface view), `#COMPOSITE`, `#CONSUMPTION`, `#EXTENSION`, `#DERIVATION_FUNCTION`, `#TRANSACTIONAL`. |

## Common Mistakes

- ❌ Enabling `@AbapCatalog.buffering` on a view with volatile/frequently-changing data — stale buffered data is a common, hard-to-diagnose production bug.
- ❌ Setting `@OData.publish: true` on internal/technical views not meant for external consumption.
- ❌ Forgetting `@Metadata.allowExtensions: true` and then wondering why `extend view` fails to activate.
- ❌ Mismatching `@ObjectModel.usageType.sizeCategory` with actual data volume — this hint affects how consuming tools (e.g. Fiori Elements paging) behave.

## Performance Considerations

- **Buffering** is powerful but only appropriate for master/customizing data that rarely changes — never buffer transactional data.
- `@Analytics.query: true` changes the execution path to the analytic engine, which behaves differently (and can be faster) for aggregation-heavy scenarios than a plain transactional read.

## SAP Best Practices

- Set `@AccessControl.authorizationCheck: #CHECK` by default for consumption/root views, using `#NOT_REQUIRED` only for pure interface (building-block) views not exposed directly.
- Classify every custom view with `@VDM.viewType` consistently — it documents the view's role in your data model for future maintainers.
- Keep `@ObjectModel.usageType` accurate; SAP-delivered analysis tools and even performance recommendations rely on it.

## Interview Notes

- **Q: What is the difference between `@AccessControl.authorizationCheck: #CHECK` and `#NOT_REQUIRED`?**
  A: `#CHECK` enforces the associated DCL role's `WHERE` restrictions on every read; `#NOT_REQUIRED` skips authorization checking entirely (typically used on low-level interface views that are always wrapped by a checked consumption view).
- **Q: What does `@AbapCatalog.viewEnhancementCategory` control?**
  A: Which kind of `extend view` enhancement is allowed on this view (field list, union branch, or group-by change).

## Related Chapters

- [Annotation-Local.md](Annotation-Local.md) — element-level annotations
- [09-Security/AccessControl.md](../09-Security/AccessControl.md) — DCL roles referenced by `@AccessControl.authorizationCheck`
- [08-OData-and-Consumption/OData.md](../08-OData-and-Consumption/OData.md) — `@OData.publish` in context
