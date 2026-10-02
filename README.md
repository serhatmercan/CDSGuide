# CDSGuide — A Practical SAP ABAP CDS Reference

A structured, example-driven engineering reference for **SAP ABAP Core Data Services** — covering data modeling, annotations, parameters and built-in functions, access control, and service exposure, across both the classic `define view` generation and modern CDS view entities.

> **Scope.** This is a practical engineering reference maintained from accumulated SAP development notes and examples — not official SAP documentation. Examples span different SAP releases and both CDS generations; where that matters, the chapter says so. Code blocks are labelled as complete examples, partial snippets, or conceptual catalogues. For anything release-sensitive, verify against the [ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_latest_index_htm/latest/en-US/index.htm) for your target system.

---

## Highlights

- **11 structured chapters** — fundamentals through service exposure, each following the same *what / why / when → syntax → examples → common mistakes → performance → best practices* shape.
- **Both CDS generations, clearly separated** — classic DDIC-based `define view` and modern `define view entity`, with an explicit chapter on where the boundary runs.
- **Data modeling in depth** — associations and cardinality, path expressions, joins, unions, extensions, input parameters and `$session`.
- **Annotation coverage** — global and element-level, including UI, ObjectModel, Consumption, Analytics and Semantics, with notes on which annotations are generation-specific.
- **Built-in functions** — string, math, date/time, casts, plus currency and unit conversion; table functions and AMDP as a deliberate escape hatch.
- **Access control (DCL)** — `define role`, `aspect pfcg_auth`, and the cases where CDS access control does *not* apply.
- **Service exposure, both routes** — classic CDS OData auto-exposure alongside the service definition / service binding model.

---

## Classic vs Modern CDS

Real SAP landscapes contain more than one generation of CDS, and most engineering work happens in between them — maintaining classic artifacts while designing new development against the modern model. This guide keeps both, labelled, rather than pretending the older one no longer exists.

Classic CDS here is **reference knowledge**; view entities and the service model are the **recommended approach for new development**. Which one applies to a given piece of work is a decision, not a default.

**→ [02-CDS-Basics/Classic-vs-Modern.md](02-CDS-Basics/Classic-vs-Modern.md)** — DDIC-based views, view entities, projection views and RAP context, service exposure, the ABAP Cloud perspective, and a quick decision table.

---

## Chapter Reference

| Folder | Topic | Contents | CDS generation |
|---|---|---|---|
| [01-Introduction](01-Introduction/) | What CDS is, prerequisites | `README.md` | — |
| [02-CDS-Basics](02-CDS-Basics/) | First CDS view, consuming views from ABAP, classic vs modern | `Main.md`, `Program.md`, `Classic-vs-Modern.md` | Both |
| [03-Data-Modeling](03-Data-Modeling/) | Associations, joins, unions, extensions | `Association.md`, `Join.md`, `Union.md`, `Extend.md` | Mostly classic |
| [04-CDS-Annotations](04-CDS-Annotations/) | Global & element-level annotations, UI/OData metadata | `Annotation-Global.md`, `Annotation-Local.md`, `Annotation-LocalEx.md` | Both, flagged per annotation |
| [05-Filtering-and-Parameters](05-Filtering-and-Parameters/) | Input parameters, conditions, session variables | `Parameters.md`, `Condition.md`, `Session.md` | Both |
| [06-Built-In-Functions](06-Built-In-Functions/) | String, math, date, time, conversion, table functions & AMDP | `String.md`, `Math.md`, `Date.md`, `Time.md`, `Conversion.md`, `Function.md` | Generation-neutral |
| [07-Query-and-Reporting](07-Query-and-Reporting/) | Aggregation, grouping, filtering, ALV reporting | `Query.md`, `Report.md` | Mostly classic |
| [08-OData-and-Consumption](08-OData-and-Consumption/) | Classic auto-exposure, service definition & binding | `OData.md` | Both |
| [09-Security](09-Security/) | Access control (DCL), authorization checks | `AccessControl.md` | Both |
| [10-Examples](10-Examples/) | Worked ABAP example — virtual element exit class | `Class.md` | Classic |
| [Appendix](Appendix/) | ADT tips, comment syntax, transaction codes | `Tips-and-Tcodes.md` | — |

---

## How to Use

- **Browse by chapter**, or jump straight to a topic from the table above — chapters cross-link heavily rather than repeating each other.
- **Try the examples in ADT** (ABAP Development Tools) or the SAP BTP ABAP Environment.
- **Check the code-block labels.** Blocks are marked as complete examples, `PARTIAL SNIPPET`, or `CONCEPTUAL CATALOGUE`. A partial snippet is a fragment on purpose; it will not activate as written.
- **Read the generation note at the top of a chapter** before copying anything — it tells you which syntax the examples use and whether that matters.
- **Note the comment syntax.** CDS DDL/DCL uses `//` and `/* */`; ABAP uses `"` and `*`. The samples follow this distinction, and mixing the two is a common first-time error — see [Appendix/Tips-and-Tcodes.md](Appendix/Tips-and-Tcodes.md).

Each chapter ends with **Common Mistakes**, **Performance Considerations**, **SAP Best Practices** and **Interview Notes** — the "why" behind the syntax.

---

## Compatibility & Version Notes

Availability is stated per **Application Server ABAP** release, since that is what the syntax depends on:

| Capability | Available from |
|---|---|
| Classic CDS views (`define view`) | AS ABAP **7.40** |
| CDS view entities (`define view entity`) | AS ABAP **7.55** — and recommended over DDIC-based views for new development from that release |
| Reading a CDS view's generated database view in ABAP SQL | Obsolete; rejected by the syntax check in **strict mode from AS ABAP 7.50**. Use the CDS entity |

> ⚠️ `define view entity` does not exist before AS ABAP 7.55. On older systems only classic `define view` is available — which is one reason the classic examples in this guide are kept rather than rewritten.

Other capabilities referenced in this guide (RAP scope, service binding protocol versions, CDS entity buffering, ABAP Cloud released-API status) are release- and platform-dependent. This guide deliberately does not state release numbers for them; check the ABAP Keyword Documentation for your target system.

---

## Who This Is For

- **SAP developers** working with CDS in S/4HANA projects who want a searchable reference rather than a tutorial.
- **Teams maintaining classic CDS** while adopting view entities, who need the differences stated precisely.
- **Developers moving toward RAP / ABAP Cloud** who want to know which existing habits carry over and which do not.
- **Technical leads** reviewing CDS design, annotation usage and access-control patterns.

---

## Prerequisites

Core **ABAP** syntax (internal tables, `SELECT`, classes) · the **ABAP Dictionary** (tables, data elements, domains) · basic **SQL** (joins, aggregation, filtering) · **ADT** in Eclipse or the BTP-based ABAP environment.

Transaction codes and ADT navigation tips: [Appendix/Tips-and-Tcodes.md](Appendix/Tips-and-Tcodes.md).

---

## Contributing

Corrections and improvements are welcome — particularly technical inaccuracies, missing functions or annotations, and release-specific clarifications. Please keep additions consistent with the existing chapter structure, and cite SAP documentation for version-sensitive claims.

## Related Guides

| Guide | Focus |
|---|---|
| [ABAPGuide](https://github.com/serhatmercan/ABAPGuide) | ABAP language and techniques, classic to modern |
| **CDSGuide** (this repository) | ABAP CDS, structured route through both generations |
| [CDS-Cookbook](https://github.com/serhatmercan/CDS-Cookbook) | CDS and AMDP pattern library |
| [GWGuide](https://github.com/serhatmercan/GWGuide) | SAP Gateway: SEGW and OData V2 |
| [UIGuide](https://github.com/serhatmercan/UIGuide) | SAPUI5 and Fiori control and pattern reference |
| [JSGuide](https://github.com/serhatmercan/JSGuide) | Plain JavaScript and browser APIs |
| [PYGuide](https://github.com/serhatmercan/PYGuide) | Python reference with verified outputs |

## Author

**Serhat Mercan** — SAP BTP & AI Technical Lead | Generative AI for SAP | ABAP & SAP Fiori/UI5

- LinkedIn: [serhat-mercan](https://www.linkedin.com/in/serhat-mercan/)
- E-mail: serhatmercan94@gmail.com
- GitHub: [serhatmercan](https://github.com/serhatmercan)

## License

[MIT](LICENSE).
