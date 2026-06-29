<div align="center">

<img src="./assets/hero-banner.svg" width="100%" alt="Inventory & Warehouse Management System"/>

<img src="./assets/divider.svg" width="100%" height="4"/>

**Inventory & Warehouse Management System**
MySQL · DBeaver · Triggers · Procedures · Views

<p align="center">
  <img src="https://img.shields.io/badge/Author-Surya%20T-F5A623?style=for-the-badge&logo=github&logoColor=white&labelColor=0d1117" alt="author"/>
  <img src="https://img.shields.io/badge/Internship-Elevate%20Labs-3DA9FC?style=for-the-badge&logo=googleclassroom&logoColor=white&labelColor=0d1117" alt="elevate labs"/>
  <img src="https://img.shields.io/github/last-commit/SURYATSG786/WaRehouse-and-Inventory-Management-System---Elevate-Labs-?color=00F5D4&style=for-the-badge&logo=github&logoColor=white&labelColor=0d1117" alt="last commit"/>
</p>

<img src="./assets/divider.svg" width="100%" height="4"/>

<p align="center">
  <img src="https://img.shields.io/badge/Database-MySQL%208-4479A1?style=for-the-badge&logo=mysql&logoColor=white&labelColor=0d1117" alt="mysql"/>
  <img src="https://img.shields.io/badge/Tool-DBeaver-372923?style=for-the-badge&logo=databricks&logoColor=white&labelColor=0d1117" alt="dbeaver"/>
  <img src="https://img.shields.io/badge/Objects-Tables%20%C2%B7%20Views%20%C2%B7%20Triggers%20%C2%B7%20Procedures-3DA9FC?style=for-the-badge&logo=databricks&logoColor=white&labelColor=0d1117" alt="objects"/>
  <img src="https://img.shields.io/badge/License-MIT-00F5D4?style=for-the-badge&logo=opensourceinitiative&logoColor=white&labelColor=0d1117" alt="license"/>
</p>

**Tested on:** MySQL 8.0 (verified against MariaDB 10.11 as well) · DBeaver 26

</div>

<img src="./assets/divider.svg" width="100%" height="4"/>

## 🧰 Technologies Used

- MySQL 8
- DBeaver
- SQL (DDL/DML)
- Stored Procedures
- Triggers
- Views
- Window Functions
- Transactions (`START TRANSACTION` / `COMMIT`)

<img src="./assets/divider.svg" width="100%" height="4"/>

## ✅ Features

- ✔ Multi-product, multi-category inventory management
- ✔ Multi-warehouse support with per-warehouse capacity tracking
- ✔ Supplier-linked purchase order workflow
- ✔ Automatic stock balance updates via triggers (no manual quantity edits)
- ✔ Automatic low-stock alerting, with auto-resolution once restocked
- ✔ Full transaction logging for auditability
- ✔ Reporting views and analytical queries (top movers, dead stock, supplier scorecard, etc.)

<img src="./assets/divider.svg" width="100%" height="4"/>

## 🎯 What This Project Actually Does

This project follows a **transaction-based inventory design**, where stock movements are recorded as transactions instead of directly updating quantities. Every stock change — a sale, a delivery, a transfer between warehouses — is written as an immutable row in `stock_transactions`. A trigger then syncs the live `stock` balance automatically, and a second trigger watches for low-stock thresholds and opens reorder alerts on its own. This improves **auditability, consistency, and data integrity**, since the database enforces the business rules rather than relying on the application layer to get it right every time.

That single design decision is what makes this worth explaining in an interview: it demonstrates **triggers, transactions, referential integrity, and audit-trail design** in one coherent system.

<img src="./assets/divider.svg" width="100%" height="4"/>

## 🧩 Entity-Relationship Diagram

```mermaid
erDiagram
    SUPPLIERS ||--o{ PRODUCTS : supplies
    CATEGORIES ||--o{ PRODUCTS : groups
    PRODUCTS ||--o{ STOCK : "tracked in"
    WAREHOUSES ||--o{ STOCK : holds
    PRODUCTS ||--o{ STOCK_TRANSACTIONS : "moves via"
    WAREHOUSES ||--o{ STOCK_TRANSACTIONS : "recorded at"
    PRODUCTS ||--o{ LOW_STOCK_ALERTS : triggers
    WAREHOUSES ||--o{ LOW_STOCK_ALERTS : "raised at"
    SUPPLIERS ||--o{ PURCHASE_ORDERS : "ordered from"
    WAREHOUSES ||--o{ PURCHASE_ORDERS : "delivered to"
    PURCHASE_ORDERS ||--o{ PURCHASE_ORDER_ITEMS : contains
    PRODUCTS ||--o{ PURCHASE_ORDER_ITEMS : "ordered as"

    SUPPLIERS {
        int supplier_id PK
        string supplier_name
        string phone
        string city
    }
    PRODUCTS {
        int product_id PK
        string sku
        string product_name
        int category_id FK
        int supplier_id FK
        decimal unit_price
        int reorder_level
        int reorder_quantity
    }
    WAREHOUSES {
        int warehouse_id PK
        string warehouse_name
        string city
        int capacity_units
    }
    STOCK {
        int stock_id PK
        int product_id FK
        int warehouse_id FK
        int quantity
    }
    STOCK_TRANSACTIONS {
        int transaction_id PK
        int product_id FK
        int warehouse_id FK
        string transaction_type
        int quantity
        int related_warehouse_id FK
    }
    LOW_STOCK_ALERTS {
        int alert_id PK
        int product_id FK
        int warehouse_id FK
        string status
    }
    PURCHASE_ORDERS {
        int po_id PK
        int supplier_id FK
        int warehouse_id FK
        string status
    }
    PURCHASE_ORDER_ITEMS {
        int po_item_id PK
        int po_id FK
        int product_id FK
        int quantity_ordered
    }
```

<img src="./assets/divider.svg" width="100%" height="4"/>

## 📸 Screenshots

> GitHub renders the ER diagram above natively as an actual diagram, so that part's already covered. The screenshots below are from this project's own DBeaver session — add yours here when you open the project locally, since a database screenshot is only meaningful if it's from a session you actually ran.

| Screenshot | What to capture |
|---|---|
| `screenshots/tables.png` | Database Navigator → `warehouse_db` → Tables (all 9 expanded) |
| `screenshots/triggers.png` | Database Navigator → Triggers, showing all 4 |
| `screenshots/procedures.png` | Database Navigator → Procedures, showing all 5 |
| `screenshots/query-output.png` | Result grid from `CALL sp_reorder_report();` |
| `screenshots/er-diagram.png` | DBeaver's own ER Diagram tab for `warehouse_db` |

```md
![Tables](screenshots/tables.png)
![Triggers](screenshots/triggers.png)
![Procedures](screenshots/procedures.png)
![Query Output](screenshots/query-output.png)
```

<img src="./assets/divider.svg" width="100%" height="4"/>

## 🗂️ Schema Overview

| Table | Purpose |
|---|---|
| `suppliers` | Vendor master data |
| `categories` | Product grouping |
| `warehouses` | Physical storage locations + capacity |
| `products` | SKU master, price, reorder thresholds |
| `stock` | **Current** quantity per product per warehouse (maintained by trigger, never written to directly) |
| `stock_transactions` | **Source of truth** — every IN / OUT / TRANSFER as an immutable log row |
| `low_stock_alerts` | Auto-opened (and auto-resolved) by trigger |
| `purchase_orders` / `purchase_order_items` | Reorder workflow with suppliers |

<img src="./assets/divider.svg" width="100%" height="4"/>

## ⚡ Triggers

<table>
<tr><th>Trigger</th><th>Fires On</th><th>What it does</th></tr>
<tr><td><code>trg_after_insert_transaction</code></td><td>AFTER INSERT on <code>stock_transactions</code></td><td>Recalculates the live balance in <code>stock</code> — the app never touches <code>stock</code> directly</td></tr>
<tr><td><code>trg_prevent_negative_stock</code></td><td>BEFORE UPDATE on <code>stock</code></td><td>Blocks any update that would push quantity below zero, via <code>SIGNAL SQLSTATE</code></td></tr>
<tr><td><code>trg_low_stock_alert</code></td><td>AFTER UPDATE on <code>stock</code></td><td>Opens an alert when quantity drops to/below reorder level; auto-resolves it once restocked</td></tr>
<tr><td><code>trg_low_stock_alert_on_insert</code></td><td>AFTER INSERT on <code>stock</code></td><td>Same check for the very first stock row of a new product/warehouse pair</td></tr>
</table>

**Example test execution** — issuing 9,999 units against a product that only had 7 in stock:

```sql
mysql> CALL sp_issue_stock(3, 1, 9999, 'should fail');
ERROR 1644 (45000): Stock quantity cannot go below zero for this product/warehouse.
```

The original `INSERT` into `stock_transactions` rolled back completely — no orphaned audit row, no partial update. That's the trigger chain (insert → sync trigger → guard trigger) protecting data integrity end-to-end, confirmed by re-querying `stock_transactions` and finding zero matching rows afterward.

<img src="./assets/divider.svg" width="100%" height="4"/>

## 🔧 Stored Procedures

| Procedure | What it does |
|---|---|
| `sp_transfer_stock(product, source_wh, destination_wh, qty)` | Transactional inter-warehouse transfer; rolls back entirely if source has insufficient stock |
| `sp_receive_stock(product, warehouse, qty, note)` | Records an inbound delivery |
| `sp_issue_stock(product, warehouse, qty, note)` | Records an outbound dispatch (sale/internal use) |
| `sp_reorder_report()` | Every product at/below reorder level, ranked by severity, with supplier contact |
| `sp_create_purchase_order(supplier, warehouse, product, qty, cost, lead_days)` | Multi-table transactional PO creation (header + line item) |

**Example test execution** — transferring stock between warehouses:

```sql
mysql> CALL sp_transfer_stock(9, 2, 1, 20);
+--------------------------------------------------------------------+
| result                                                              |
+--------------------------------------------------------------------+
| Transferred 20 unit(s) of product #9 from warehouse #2 to warehouse #1 |
+--------------------------------------------------------------------+
```
The source warehouse's quantity decreased by 20 and the destination warehouse's quantity increased by 20, confirmed by re-querying `stock` immediately after. Exact before/after numbers depend on whatever is currently in your `stock` table, since this is live, mutable data.

<img src="./assets/divider.svg" width="100%" height="4"/>

## 📊 Reporting Output

> Example output from the sample dataset in `02_sample_data.sql`. These numbers will differ once you start running transactions of your own — that's expected, since the whole point of this design is that the numbers move as real activity happens.

**Reorder report** (`CALL sp_reorder_report();`) — sample run flagged several products at/below their reorder level, for example:

| SKU | Product | Warehouse | Qty | Reorder Level | Supplier |
|---|---|---|---|---|---|
| OFF-3002 | Ballpoint Pen Box | Chennai | 18 | 60 | Apex Office Essentials |
| ELE-1004 | Power Bank 10000mAh | Mumbai | 8 | 20 | Crescent Electronics |
| ELE-1003 | Bluetooth Speaker Mini | Chennai | 7 | 15 | BrightTech Distributors |
| ELE-1002 | Wireless Mouse 2.4GHz | Bengaluru | 14 | 25 | BrightTech Distributors |

**Warehouse KPI view** (`SELECT * FROM vw_warehouse_summary;`) — example output:

| Warehouse | SKUs | Units | Stock Value (₹) | Capacity Used |
|---|---|---|---|---|
| Chennai Central | 15 | 1,762 | 5,67,888 | 11.7% |
| Bengaluru Tech Park | 15 | 928 | 3,00,942 | 7.7% |
| Mumbai Distribution | 15 | 1,043 | 3,82,857 | 5.8% |

<details>
<summary>📋 <strong>See all 10 queries in <code>06_queries.sql</code> (click to expand)</strong></summary>

1. Current stock level + status per product/warehouse
2. Open reorder alerts with supplier contact
3. Warehouse-level KPI summary
4. Total company-wide inventory value
5. Top 5 fastest-moving products (last 30 days)
6. Dead-stock detector (zero outbound movement, stock still on hand)
7. Supplier scorecard (SKUs supplied + value held)
8. Monthly IN vs OUT transaction volume trend
9. Pending purchase orders with days-remaining countdown
10. Stock value ranked within category using `RANK() OVER (PARTITION BY ...)`

</details>

<img src="./assets/divider.svg" width="100%" height="4"/>

## 🛠️ How to Run This in DBeaver

1. **Install MySQL** (or use any reachable MySQL 8 / MariaDB 10.2+ server) and connect to it in DBeaver via *Database → New Database Connection → MySQL*.
2. Open a **SQL Editor** against your connection.
3. Run the files **in this exact order**:
   ```
   sql/01_schema.sql        -- creates the database + all tables
   sql/02_sample_data.sql   -- realistic seed data (15 products, 3 warehouses, 5 suppliers)
   sql/03_triggers.sql      -- the auto-sync + alerting logic
   sql/04_procedures.sql    -- transfer / receive / issue / reorder / PO procedures
   sql/05_views.sql         -- dashboard views
   sql/06_queries.sql       -- the 10 analytical queries above
   ```
4. In DBeaver's **Database Navigator**, expand `warehouse_db → Triggers` and `→ Procedures` to see every object listed and inspect its source.
5. Try it yourself:
   ```sql
   CALL sp_reorder_report();
   CALL sp_transfer_stock(9, 2, 1, 20);
   SELECT * FROM vw_open_alerts;
   ```

<img src="./assets/divider.svg" width="100%" height="4"/>

## 📁 Folder Structure

```
WaRehouse-and-Inventory-Management-System---Elevate-Labs-/
├── README.md
├── assets/
│   ├── hero-banner.svg
│   └── divider.svg
├── screenshots/
│   └── (add your DBeaver screenshots here)
└── sql/
    ├── 01_schema.sql
    ├── 02_sample_data.sql
    ├── 03_triggers.sql
    ├── 04_procedures.sql
    ├── 05_views.sql
    └── 06_queries.sql
```

<img src="./assets/divider.svg" width="100%" height="4"/>

## 🎤 Interview Talking Points

<details>
<summary><strong>"Walk me through your project."</strong></summary>

A warehouse inventory system where stock is never updated directly by the application. Every movement (receipt, sale, transfer) gets logged as an immutable transaction row, and a trigger recalculates the live balance from that log. A second trigger watches for low-stock conditions and automatically opens or resolves reorder alerts. On top of that there are five stored procedures for the actual day-to-day operations, three views for reporting, and ten analytical queries including a window function.

</details>

<details>
<summary><strong>"Why log transactions instead of just updating a quantity column?"</strong></summary>

Two reasons: auditability (you can always answer "what happened to this stock and when") and correctness (the trigger does the arithmetic exactly once, in one place, so the app layer can never apply a delta twice or get a race condition wrong). It's the same pattern used in real accounting and ERP systems — never overwrite a balance, always derive it from a ledger.

</details>

<details>
<summary><strong>"What's the difference between your trigger-based sync and just writing an UPDATE in the app code?"</strong></summary>

If ten different parts of the app (web form, mobile app, batch import) all need to update stock, you'd have to remember to apply the same logic in all ten places. With a trigger, the rule lives once, in the database, and is enforced no matter what inserted the transaction row — even a manual `INSERT` from DBeaver gets the same validation.

</details>

<details>
<summary><strong>"How did you handle the case of insufficient stock during a transfer?"</strong></summary>

`sp_transfer_stock` checks available quantity before inserting anything, and the whole operation runs inside `START TRANSACTION ... COMMIT`. If the check fails, it raises a custom error with `SIGNAL SQLSTATE '45000'` and nothing is written. Tested directly — attempting to over-issue stock throws the error and a re-query confirms zero rows were inserted.

</details>

<img src="./assets/divider.svg" width="100%" height="4"/>

## 🚧 Future Enhancements

- User authentication and role-based access (warehouse staff vs. purchasing manager) via MySQL users/grants
- A web dashboard for visualizing stock levels, alerts, and warehouse KPIs in real time
- Barcode/QR support for scanning products in and out of stock
- A REST API layer on top of the procedures, so external systems (e.g. an e-commerce storefront) can issue/receive stock programmatically
- A `stock_value_history` table for time-series valuation trends
- An event scheduler that automatically emails purchasing whenever `sp_reorder_report()` returns rows

<img src="./assets/divider.svg" width="100%" height="4"/>

<div align="center">
<sub>Built by <strong>Surya T</strong> · Elevate Labs Internship Project 2026</sub>
</div>
