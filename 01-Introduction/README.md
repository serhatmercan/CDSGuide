# 01. Introduction to SAP ABAP CDS

## What is CDS?

**Core Data Services (CDS)** is SAP's modern, database-independent way of defining data models directly on top of database tables. Instead of writing complex `SELECT` logic inside ABAP reports, you define **views** in a declarative language (similar to SQL, but richer) that are pushed down and executed **inside the database** (typically SAP HANA).

A CDS view is defined using **DDL (Data Definition Language)** source code and, once activated, generates:

- A **database view** (visible in `SE11`)
- An **ABAP Dictionary structure/entity** you can use in `SELECT` statements, RAP applications, OData services, and analytics.

## Why is CDS used?

| Classic ABAP approach | CDS approach |
|---|---|
| Data fetched into ABAP, then filtered/joined/aggregated in application layer | Filtering, joins, and aggregation pushed down to the database (**code-to-data paradigm**) |
| Reusability achieved through custom function modules | Reusability through associations, views on views, and extensions |
| UI/OData metadata scattered across Gateway projects | Metadata declared once via **annotations** directly on the view |
| Authorization checks hardcoded in ABAP | Declarative **Access Control (DCL)** |

**Key benefits:**

- 🚀 **Performance** — computation happens close to the data (HANA push-down), reducing data transfer between DB and application server.
- 🧩 **Reusability** — views can be built on top of other views/associations instead of duplicating joins.
- 🎨 **Single source of metadata** — UI, OData, and analytical annotations live with the data model.
- 🔐 **Centralized security** — access control views (DCL) decouple authorization logic from view logic.

## When should CDS be used?

- Whenever you need to **read** data for reports, Fiori apps, OData services, or analytics.
- When building **RAP (ABAP RESTful Application Programming Model)** business objects — CDS is the foundation of RAP.
- When you want annotated, semantically rich data models that Fiori Elements or SAP Analytics tools can consume without additional configuration.

> 📝 **Note:** CDS views are primarily a **read** technology. Data changes still go through business logic (BAPIs, RAP behavior definitions), not directly through the view.

## Prerequisites

Before diving into the chapters, you should be comfortable with:

- Core **ABAP** syntax (internal tables, `SELECT`, classes/methods)
- The **ABAP Dictionary** — tables, data elements, domains, foreign keys
- Basic **relational database / SQL** concepts (joins, `GROUP BY`, aggregate functions)
- Navigating **ABAP Development Tools (ADT)** in Eclipse (or the web-based ABAP environment for cloud)

## How This Guide is Organized

Each chapter follows the same structure:

1. **What is it? / Why is it used? / When should it be used?**
2. **Syntax explanation**
3. **Code examples** (original notes preserved, plus additional examples)
4. **Common mistakes**
5. **Performance considerations**
6. **SAP best practices**
7. **Interview notes**

Continue to [02-CDS-Basics](../02-CDS-Basics/Main.md) to write your first CDS view.
