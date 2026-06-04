# Final Project: Auto Repair Shop Database System (auto_repair_db)

This project implements a relational database management system using PostgreSQL to automate the core business operations of an auto repair shop. The system tracks and manages customers, vehicles, employees, job positions, service categories, repair orders, parts inventory, suppliers, and financial transactions.

## Project Characteristics
* RDBMS: PostgreSQL 13+
* Domain: Auto Repair Shop Management
* Database Name: auto_repair_db
* Schema Name: auto_repair
* Context Year: 2026

---

## 1. Database Architecture and Table Schema

The database is structured to comply with 3rd Normal Form (3NF) principles. Data integrity is enforced using primary keys, foreign keys with specific deletion rules (cascade and restrict), unique constraints, and check constraints.

### Description of Tables:
1. **customers**: Stores customer profile information including full name, phone number, unique email address, and physical address.
2. **positions**: A lookup catalog for staff job roles along with their predefined base salaries.
3. **employees**: Tracks corporate staff details including hire dates, adjusted salaries, and gender roles linked to specific positions.
4. **vehicles**: Contains vehicle assets registered under a customer. Includes a rule restricting the production year to models from the year 2000 onward.
5. **service_categories**: Groupings for shop operations (e.g., Engine, Electrical, Diagnostics).
6. **services**: Predefined repair tasks specifying standard prices and estimated duration hours. Price cap constraint is set at 100,000 units.
7. **repair_orders**: Logs repair tickets assigning a customer's vehicle to an employee. Order statuses are restricted to: pending, in_progress, completed, and cancelled.
8. **repair_order_services**: A many-to-many bridge table connecting orders to services rendered. Features a generated column (total_cost) calculated automatically as (hours_worked * hourly_rate).
9. **suppliers**: Catalog of spare part providers. Default country value is configured as 'Kazakhstan'.
10. **spare_parts**: Inventory management table tracking part items, unit pricing, and real-time stock levels.
11. **order_parts**: Logs the precise quantity of spare parts allocated to and consumed by a specific repair order.
12. **payments**: Financial ledger mapping customer transaction methods (cash, card, transfer) and payment amounts against active orders.

---

## 2. Entity Relationship Diagram (ERD)

 [ customers ] 1 -------- * [ vehicles ] 1 -------- * [ repair_orders ] 1 -------- * [ payments ]
                                                               |
 [ positions ] 1 -------- * [ employees ] 1 ------------------/
                                                               |
 [ service_categories ] 1 -- * [ services ] 1 -------- * [ repair_order_services ]
                                                               |
 [ suppliers ] 1 -------- * [ spare_parts ] 1 -------- * [ order_parts ]

---

## 3. Deployment Instructions

### Step 1: Initialize Database
Run the following command inside your PostgreSQL terminal (psql) or executing console (pgAdmin / DBeaver):

CREATE DATABASE auto_repair_db;

### Step 2: Execute the Script
Connect to the newly created auto_repair_db database and execute the provided SQL script. The initialization script carries out these stages sequentially:
1. Generates the auto_repair schema and updates the session search_path.
2. Builds all structural tables along with their embedded CHECK, UNIQUE, DEFAULT, and GENERATED ALWAYS AS constraints.
3. Performs structural adjustments via ALTER TABLE operations (e.g., modifying phone field lengths, appending customer address attributes, setting default countries).
4. Issues a safe TRUNCATE ... RESTART IDENTITY CASCADE operation to allow clean script reruns.
5. Populates tables with transactional seed data relevant to the 2026 operational timeline.

---

## 4. Roles and Access Control Security

The initialization script sets up data security profiles using role-based access control (RBAC):
* auto_repair_readonly: Configured for analytical or managerial access with read-only permissions across data tables.
* auto_repair_writer: Configured for shop floor operators and service advisors.
* Business Policy Rule: Writers possess authorization to generate and submit repair records, but their direct UPDATE privileges on the repair_orders table are revoked. This prevents unauthorized modification of historical order states without administrative oversight.

---

## 5. Analytical Query Examples

Below are practical query examples to evaluate the system schema and run operational analytics:

### A. Total Financial Invoice per Repair Order (Labor + Spare Parts)

SELECT 
    ro.order_id,
    c.full_name AS customer_name,
    COALESCE(SUM(DISTINCT ros.total_cost), 0) AS labor_cost,
    COALESCE(SUM(op.quantity * sp.unit_price), 0) AS parts_cost,
    (COALESCE(SUM(DISTINCT ros.total_cost), 0) + COALESCE(SUM(op.quantity * sp.unit_price), 0)) AS total_invoice_amount
FROM auto_repair.repair_orders ro
JOIN auto_repair.vehicles v ON ro.vehicle_id = v.vehicle_id
JOIN auto_repair.customers c ON v.customer_id = c.customer_id
LEFT JOIN auto_repair.repair_order_services ros ON ro.order_id = ros.order_id
LEFT JOIN auto_repair.order_parts op ON ro.order_id = op.order_id
LEFT JOIN auto_repair.spare_parts sp ON op.part_id = sp.part_id
GROUP BY ro.order_id, c.full_name
ORDER BY ro.order_id;

### B. Inventory Shortage and Low Stock Warning Alert

SELECT 
    part_name, 
    stock_quantity, 
    unit_price 
FROM auto_repair.spare_parts
WHERE stock_quantity < 30
ORDER BY stock_quantity ASC;

---
## Project Specifications
* Domain Scope: Auto Repair Shop Management
* Implementation Version: 1.0.0
* Execution Context: April 2026