# Classic CDS vs Modern CDS

## Why Both Appear in This Guide

A real SAP landscape is rarely one generation of technology. A single customer may run an S/4HANA system whose oldest custom CDS views predate view entities entirely, a newer stack where view entities are the default, and a BTP ABAP environment where only released APIs may be used at all — sometimes all three at once, connected to each other.

The people who work in those landscapes spend most of their time somewhere in between. A technical lead is typically maintaining classic CDS artifacts that carry real business logic *while* designing new development against the modern model, and deciding which of the two a given piece of work belongs to. That decision is the skill. Knowing where the boundary runs — what can be left alone, what should be built the new way, what genuinely has to be migrated — is worth considerably more than the ability to rewrite every artifact into the newest syntax.

This guide therefore keeps both generations, side by side and clearly labelled. Classic examples are not here because they were never updated; they are here because they are still what you will open in a productive system, and because understanding them is a prerequisite for judging whether they need to change.

The rule this guide follows:

> Classic CDS is **reference knowledge**. Modern CDS is the **recommended approach for new development**. Neither statement makes the other wrong.

---

## 1. CDS DDIC-Based Views

**Classification: CLASSIC BUT STILL RELEVANT**

The original form of an ABAP CDS view, introduced with Application Server ABAP 7.40 and defined with `define view`.

```abap
@AbapCatalog.sqlViewName: 'ZSM_V_EXAMPLE'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Example (DDIC-based view)'

define view ZSM_I_Example
  as select from mara
{
  key matnr as Material,
      mtart as MaterialType
}
```

Defining characteristics:

| Aspect | Behaviour |
|---|---|
| Statement | `define view` |
| `@AbapCatalog.sqlViewName` | **Mandatory.** Names the generated artifact |
| Generated artifact | A DDIC/database view is generated *alongside* the CDS entity — two objects, two names |
| Client handling | Explicit, via `@ClientHandling.type` / `@ClientHandling.algorithm` (default algorithm `#AUTOMATED`) |
| Extension model | `extend view`, requiring `@Metadata.allowExtensions` and a matching `@AbapCatalog.viewEnhancementCategory` |
| Buffering | Classic table buffering on the generated view, via `@AbapCatalog.buffering` |

**Where it still matters.** Enormous amounts of productive custom and SAP-standard code are built on DDIC-based views. They are not broken, and there is no general obligation to rewrite them. Chapters [03-Data-Modeling](../03-Data-Modeling/Association.md), [05-Filtering-and-Parameters](../05-Filtering-and-Parameters/Parameters.md) and [07-Query-and-Reporting](../07-Query-and-Reporting/Query.md) mostly use this syntax for exactly that reason.

**One thing to get right.** The generated database view is an implementation artifact, not a second way to read the data. Reading it instead of the CDS entity skips the entity's semantics *and* its access control. See [Program.md](Program.md).

> **SAP recommends CDS view entities over CDS DDIC-based views for new development on releases where view entities are available.**

---

## 2. CDS View Entities

**Classification: CURRENT / RECOMMENDED**

Available as of **Application Server ABAP 7.55**, defined with `define view entity`.

```abap
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Example (view entity)'

define view entity ZSM_I_Example
  as select from mara
{
  key matnr as Material,
      mtart as MaterialType
}
```

What changes, and why it is simpler:

| Aspect | Behaviour |
|---|---|
| Statement | `define view entity` |
| `@AbapCatalog.sqlViewName` | **Not allowed** — specifying it is an error |
| Generated artifact | **None.** The entity is the only object, with one name |
| Client handling | **Implicit and automatic** — no annotation required, and `@ClientHandling` should not be carried over |
| Extension model | `extend view entity` |
| Buffering | A separate mechanism (CDS entity buffer), not the classic `@AbapCatalog.buffering` annotation |

The practical effect of removing the generated view is larger than it first appears: there is no second name to keep in sync, no 16-character limit to work around, no ambiguity about which object a consumer should read, and no path by which someone can accidentally bypass the model. Several of the classic-CDS pitfalls documented elsewhere in this guide simply cannot occur in a view entity.

For the detailed side-by-side, see [Main.md](Main.md).

---

## 3. CDS Projection Views and RAP Context

**Classification: ABAP CLOUD / MODERN**

A **CDS projection view** is defined with `define view entity as projection on <entity>` and is based on a CDS view entity. Rather than modelling data from scratch, it *adapts an existing model for a specific use case* — narrowing the field list, renaming elements for a service-facing contract, and adding the UI or service annotations that belong to that consumer rather than to the underlying model.

That separation is the point. The interface layer stays reusable and consumer-agnostic; each service gets its own projection with its own annotations, and two services can project the same model differently without fighting over it.

**On `define root view entity`.** This guide uses `root` in several examples, and it is worth being precise about what it means. "Root" is not a synonym for "main view" or "the important one" — it designates the **root entity of a RAP business object's composition tree**, the entity that owns the transactional boundary and beneath which child entities are composed. Marking a view `root` when it is not the root of a business object is misleading to the next reader, even where it activates without complaint.

RAP itself — behavior definitions, behavior implementations, draft handling, managed versus unmanaged scenarios — is beyond this guide's scope. What matters here is where CDS sits in it: RAP is built **on** CDS, and every RAP business object starts as a CDS data model.

---

## 4. Service Exposure

Both generations can turn a CDS model into an OData service, by quite different routes.

**Classic — CDS OData auto-exposure:**

```abap
@OData.publish: true
```

Set on the view, this is the classic CDS OData auto-exposure mechanism: activation generates a service that is then registered and activated on the Gateway side. It is a one-annotation path, oriented toward read scenarios, and you will still encounter it across existing landscapes.

**Modern — service definition and service binding:**

```abap
@EndUserText.label: 'Example CDS Service'
define service ZUI_EXAMPLE {
  expose ZSM_C_EXAMPLE as Example;
}
```

A **service definition** selects which CDS entities form a business service. It is deliberately **protocol-independent** — it says *what* is exposed, never *how*. A **service binding** then links that definition to a specific protocol and version (OData V2 or V4, depending on the scenario and platform); the binding is created and configured in ADT rather than written as CDS source.

For current RAP and service-oriented development, SAP's service model uses service definitions and service bindings. Chapter [08-OData-and-Consumption](../08-OData-and-Consumption/OData.md) covers both routes in full, with the classic content preserved as reference.

---

## 5. The ABAP Cloud Perspective

ABAP Cloud development is governed by a different rule than on-premise custom development: code may only use **released** APIs and artifacts. Whether something is technically possible matters less than whether it has been released for cloud development.

This reframes the classic/modern question. The distinction stops being "old versus new style" and becomes a question about which development model you are working in:

- **On-premise maintenance of existing applications** — classic constructs remain relevant and are frequently the correct thing to keep using. Direct access to underlying tables, classic reporting and Gateway-oriented exposure all still have their place here.
- **Cloud-ready / ABAP Cloud development** — the released-API rule applies, and several classic constructs used in this guide are not the right starting point, even where a similar concept exists.

This guide does not attempt an "available in ABAP Cloud / not available" matrix. Such a table would need every row individually verified against current SAP documentation for a specific release, and a stale or half-verified matrix is worse than none — it invites exactly the confident wrong decision it was meant to prevent. Where a chapter uses something with a cloud-relevant restriction, the chapter says so locally.

What this guide *does* commit to is the distinction itself: reference knowledge is labelled as reference knowledge, and the recommended approach for new cloud-ready development is labelled as such.

---

## 6. Quick Decision Table

| Scenario | Preferred CDS approach | Service exposure | Notes |
|---|---|---|---|
| **New development**, release supports view entities | `define view entity` | Service definition + service binding | SAP's recommendation for new development as of AS ABAP 7.55 |
| **New development**, older release without view entities | `define view` (DDIC-based) | Whatever the release supports | Not a compromise — the modern syntax does not exist before 7.55 |
| **Existing classic productive application** | Keep `define view` | Keep the existing exposure | Do not migrate for style. Migrate when there is a concrete reason: a required feature, a cloud-readiness goal, or work that rewrites the artifact anyway |
| **RAP service** | View entity → projection view; `root` only for the actual composition root | Service definition + service binding | Behavior definition where transactional behaviour is required |
| **Classic OData maintenance** | Leave the model as it is | Existing `@OData.publish` / Gateway registration | Understand it before changing it; enforce access control on anything externally reachable |
| **ABAP Cloud development** | View entity → projection view | Service definition + service binding | Released APIs only — verify each artifact against current SAP documentation |

**Migration is a decision, not a default.** A working DDIC-based view that no one is touching is not technical debt merely for being classic. The trigger for migration should be a real requirement, not the age of the syntax.

---

## Related Chapters

- [Main.md](Main.md) — `define view` and `define view entity` side by side
- [Program.md](Program.md) — CDS entity vs. generated database view, and why the difference is a security question
- [08-OData-and-Consumption/OData.md](../08-OData-and-Consumption/OData.md) — classic auto-exposure and the service definition/binding model
- [04-CDS-Annotations/Annotation-Global.md](../04-CDS-Annotations/Annotation-Global.md) — annotations whose meaning depends on the generation (client handling, buffering, `@ObjectModel` transactional flags)
- [09-Security/AccessControl.md](../09-Security/AccessControl.md) — DCL, which applies across both generations
