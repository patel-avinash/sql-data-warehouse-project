# PostgreSQL Data Warehouse & Analytics Project

A portfolio project demonstrating how to build a modern **Data Warehouse using PostgreSQL**, following the **Medallion Architecture (Bronze → Silver → Gold)**.

The project integrates data from **CRM and ERP source systems**, cleans and standardizes the data, enriches customer and product information, and creates business-ready dimensional models for analytical queries.

---

## 🏗️ Data Architecture

The project follows a three-layer Medallion Architecture:

```text
                    ┌─────────────────────┐
                    │     Source Data     │
                    │     CRM + ERP       │
                    │     CSV / Raw Data  │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │   BRONZE LAYER      │
                    │   Raw / Staging     │
                    │   Data as received  │
                    └──────────┬──────────┘
                               │
                         Data Cleaning
                         & Transformation
                               │
                               ▼
                    ┌─────────────────────┐
                    │   SILVER LAYER      │
                    │ Cleaned & Standard- │
                    │  ized Data          │
                    └──────────┬──────────┘
                               │
                       Data Integration
                       & Business Logic
                               │
                               ▼
                    ┌─────────────────────┐
                    │    GOLD LAYER       │
                    │ Business-Ready      │
                    │ Dimensions + Fact   │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │ Analytics / BI      │
                    │ SQL Queries &       │
                    │ Reporting           │
                    └─────────────────────┘
```

### Layers

**Bronze Layer**
- Stores raw source data with minimal transformation.
- Data is loaded from CRM and ERP source files.
- Preserves the original structure of the source data.

**Silver Layer**
- Performs data cleaning and standardization.
- Removes duplicate customer records.
- Handles invalid and missing values.
- Standardizes gender, marital status, country, and product-line values.
- Converts numeric date representations into PostgreSQL `DATE` values.
- Validates sales, quantity, and price relationships.
- Adds `dwh_create_date` timestamps for warehouse loading.

**Gold Layer**
- Provides business-ready analytical views.
- Creates customer and product dimensions.
- Generates surrogate keys using `ROW_NUMBER()`.
- Creates a sales fact view.
- Connects fact records to customer and product dimensions.
- Follows a Star Schema design for analytical workloads.

---

## 📌 Project Objectives

The main objectives of this project are:

1. Build a PostgreSQL data warehouse using Medallion Architecture.
2. Integrate CRM and ERP source data.
3. Clean and standardize raw data.
4. Handle null, duplicate, invalid, and inconsistent values.
5. Transform source-system data into analytical structures.
6. Build reusable Gold dimension and fact views.
7. Implement data-quality validation checks.
8. Create a repository containing the complete SQL development process.

---

## 🔄 ETL / ELT Flow

```text
CRM Sources ─────┐
                 ├──► Bronze ───► Silver ───► Gold
ERP Sources ─────┘
```

### Bronze → Silver

The Silver layer performs transformations such as:

- Trimming unwanted spaces
- Removing or standardizing prefixes
- Removing special characters from customer identifiers
- Converting date values
- Handling invalid dates
- Replacing invalid numeric values
- Standardizing categorical values
- Removing duplicate customer records
- Validating sales calculations
- Integrating ERP customer information with CRM customer information

### Silver → Gold

The Gold layer:

- Creates dimension views
- Generates surrogate keys
- Enriches customer information with ERP data
- Enriches product information with category data
- Creates a fact sales view
- Connects fact data to dimension surrogate keys

---

## ⭐ Gold Data Model

The Gold layer follows a **Star Schema**.

```text
                     ┌──────────────────────┐
                     │   dim_customers      │
                     │──────────────────────│
                     │ customer_key         │
                     │ customer_id          │
                     │ customer_number      │
                     │ first_name           │
                     │ last_name            │
                     │ country              │
                     │ marital_status       │
                     │ gender               │
                     │ birthdate            │
                     │ create_date          │
                     └──────────┬───────────┘
                                │
                                │ customer_key
                                │
                                ▼
                     ┌──────────────────────┐
                     │     fact_sales       │
                     │──────────────────────│
                     │ order_number         │
                     │ product_key          │
                     │ customer_key         │
                     │ customer_id          │
                     │ order_date           │
                     │ shipping_date        │
                     │ due_date             │
                     │ sales_amount         │
                     │ quantity              │
                     │ price                 │
                     └──────────┬───────────┘
                                │
                                │ product_key
                                │
                                ▼
                     ┌──────────────────────┐
                     │    dim_products      │
                     │──────────────────────│
                     │ product_key          │
                     │ product_id           │
                     │ product_number       │
                     │ product_name         │
                     │ category_id          │
                     │ category             │
                     │ subcategory          │
                     │ maintenance          │
                     │ cost                 │
                     │ product_line         │
                     │ start_date           │
                     │ end_date             │
                     └──────────────────────┘
```

### Gold Views

| View | Type | Purpose |
|---|---|---|
| `gold.dim_customers` | Dimension | Customer master data enriched with ERP information |
| `gold.dim_products` | Dimension | Current product information and category attributes |
| `gold.fact_sales` | Fact | Transaction-level sales data connected to dimensions |

---

## 🔑 Surrogate Keys

The Gold dimension views generate surrogate keys using PostgreSQL window functions:

```sql
ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key
```

and:

```sql
ROW_NUMBER() OVER (ORDER BY prd_id) AS product_key
```

These keys are used by the fact table/view to reference the dimensions.

This separates analytical relationships from the original source-system identifiers and provides a consistent dimensional-model design.

---

## 🧹 Data Quality Checks

The project includes SQL quality checks for the Silver and Gold layers.

### Silver Layer Checks

Examples include:

- NULL or duplicate customer IDs
- Unwanted spaces
- Invalid product costs
- Product date-range validation
- Invalid sales dates
- Order/shipping/due-date consistency
- Sales = quantity × price validation
- Invalid birthdates
- Gender standardization
- Country standardization
- Category and maintenance-value consistency

### Gold Layer Checks

The Gold layer validates:

- Uniqueness of customer surrogate keys
- Uniqueness of product surrogate keys
- Referential integrity between fact and dimension views
- Missing product dimension keys
- Missing customer dimension keys

---

## 🗂️ Repository Structure

```text
postgresql-data-warehouse/
│
├── datasets/
│   └──                         # Source CRM and ERP datasets
│
├── docs/
│   ├── data_architecture.png
│   ├── data_flow.png
│   ├── data_models.png
│   └── data_catalog_postgresql.md
│
├── scripts/
│   ├── bronze/
│   │   ├── ddl_bronze.sql
│   │   └── load_bronze.sql
│   │
│   ├── silver/
│   │   ├── ddl_silver.sql
│   │   ├── load_silver.sql
│   │   └── quality_checks.sql
│   │
│   └── gold/
│       ├── gold_layer.sql
│       └── quality_checks.sql
│
├── README.md
└── .gitignore
```

> Adjust filenames and folders to match the final structure of your repository.

---

## 🛠️ Technologies Used

- **PostgreSQL** – Data warehouse database
- **pgAdmin** – PostgreSQL database management and SQL development
- **SQL** – Data extraction, transformation, validation, and modeling
- **Git & GitHub** – Version control and project documentation
- **Draw.io** – Architecture and data-model diagrams

---

## 🧠 SQL Concepts Used

This project applies several important SQL and data-engineering concepts:

- `CREATE SCHEMA`
- `CREATE TABLE`
- `CREATE VIEW`
- `INSERT INTO ... SELECT`
- `TRUNCATE`
- `CASE`
- `COALESCE`
- `NULLIF`
- `TRIM`
- `UPPER`
- `REPLACE`
- `SUBSTRING`
- `TO_DATE`
- `ROW_NUMBER()`
- `LEAD()`
- Window Functions
- `LEFT JOIN`
- `GROUP BY`
- `HAVING`
- Data validation
- Data standardization
- Star Schema
- Surrogate Keys
- Fact and Dimension modeling

---

## ▶️ How to Run the Project

### 1. Install PostgreSQL

Install PostgreSQL and pgAdmin on your system.

### 2. Create a Database

Create a PostgreSQL database for the project.

Example:

```sql
CREATE DATABASE datawarehouse;
```

Connect to the database using pgAdmin.

### 3. Create the Bronze Layer

Run the Bronze DDL scripts and load the source data.

```text
scripts/bronze/
```

The Bronze layer should be populated before moving to Silver.

### 4. Create and Load the Silver Layer

Run:

```text
scripts/silver/ddl_silver.sql
scripts/silver/load_silver.sql
```

The Silver scripts clean and transform the Bronze data.

### 5. Run Silver Quality Checks

Run:

```text
scripts/silver/quality_checks.sql
```

The expectation is that validation queries return no unexpected records.

### 6. Create the Gold Layer

Run:

```text
scripts/gold/gold_layer.sql
```

This creates:

```text
gold.dim_customers
gold.dim_products
gold.fact_sales
```

### 7. Validate the Gold Layer

Run:

```text
scripts/gold/quality_checks.sql
```

Check surrogate-key uniqueness and fact-to-dimension relationships.

---

## 📊 Example Analytical Queries

After the Gold layer has been created, analytical queries can be written against the business-ready views.

Example:

```sql
SELECT
    p.category,
    SUM(f.sales_amount) AS total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_sales DESC;
```

Customer-level analysis:

```sql
SELECT
    c.country,
    COUNT(DISTINCT c.customer_key) AS total_customers
FROM gold.dim_customers c
GROUP BY c.country
ORDER BY total_customers DESC;
```

---

## 📚 Documentation

Additional documentation is available in the `docs/` directory:

- **Data Architecture** – Overall Bronze → Silver → Gold architecture
- **Data Flow** – Movement of data between layers
- **Data Model** – Gold-layer Star Schema
- **Data Catalog** – Column definitions and business descriptions

---

## 🎯 Learning Outcomes

Through this project, I practiced:

- Designing a data warehouse architecture
- Working with PostgreSQL
- Building Bronze, Silver, and Gold layers
- Writing SQL-based ETL/ELT transformations
- Performing data cleansing and standardization
- Handling data-quality problems
- Integrating multiple source systems
- Designing fact and dimension models
- Using surrogate keys
- Creating analytical views
- Writing data-quality checks
- Managing a data-engineering project with Git and GitHub

---

## 👨‍💻 Author

**Avinash J. Patel**

Computer Engineering Student | Aspiring Data Engineer

This project was created as a hands-on learning and portfolio project to demonstrate practical skills in **SQL, PostgreSQL, Data Warehousing, ETL/ELT, Data Modeling, and Data Quality**.

---

## 📄 License

This project is intended for educational and portfolio purposes.
