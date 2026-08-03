# Maven Electronics — Global Retail Analytics

## 📌 Overview

**Maven Electronics** is a global retailer selling computers, cell phones, and TVs through online and physical stores. The business has experienced a **decline in revenue since 2020** and needs a data-driven solution to understand sales, customers, products, stores, and currency trends.

This project uses **PostgreSQL for data profiling, cleaning, transformation, and data warehouse development**, followed by **Power BI for interactive business reporting**.

### Workflow

```text
Raw CSVs → PostgreSQL Staging → Data Profiling
→ Data Cleaning → Star Schema → Power BI → Insights
```

---

## 🛠️ Tools & Technologies

- **PostgreSQL**
- **SQL**
- **Power BI**
- **GitHub**

---

## 📂 Dataset

The project contains five datasets:

| Dataset | Records | Description |
|---|---:|---|
| Sales | 62,884 | Transaction-level sales data |
| Customers | 15,266 | Customer and geographic information |
| Products | 2,517 | Product, category, brand, and pricing data |
| Stores | 67 | Physical and online store information |
| Exchange Rates | 11,215 | Daily currency exchange rates |

**Total records:** 91,949

---

# 🔹 Phase 1 — Data Loading & Setup

- Created PostgreSQL staging environment
- Loaded all five raw CSV datasets
- Created staging tables
- Verified record counts and successful imports

### Staging Tables

```text
sales_raw
customers_raw
products_raw
stores_raw
exchange_rates_raw
```

---

# 🔍 Phase 2 — Data Profiling & Quality Assessment

Each dataset was systematically profiled before transformation.

### Checks Performed

- Record counts
- Missing values
- Duplicate records
- Data types
- Date ranges
- Numeric ranges
- Category/value validation
- Key uniqueness
- Foreign-key consistency
- Business-rule validation
- Table grain identification

### Key Findings

**Sales**
- 62,884 records
- No duplicate records identified
- NULL delivery dates were identified and retained as valid business conditions

**Customers**
- 15,266 records
- Customer keys are unique
- Alphanumeric postal codes were identified and retained as valid text values

**Products**
- 2,517 records
- Product keys are unique
- 11 brands, 8 categories, 32 subcategories, and 16 colors identified
- `unit_cost_usd` and `unit_price_usd` are stored as text and require numeric conversion

**Stores**
- 67 records
- 66 physical stores + 1 Online channel
- Physical store sizes range from 245 m² to 2,105 m²
- Online store has `NULL` square meters, treated as a valid business condition

**Exchange Rates**
- 11,215 records
- 5 currencies
- 2,243 records per currency
- Date range: 2015-01-01 to 2021-02-20
- Confirmed grain: **one record per currency per date**

---

# 🔄 Phase 3 — Data Transformation

The cleaned staging data was transformed into warehouse-ready tables while keeping the original staging layer unchanged.

## 🛠️ Transformations Performed

### Customers
- Converted `birthday` from `TEXT` to `DATE`.
- Preserved the original customer records in the staging layer.

### Products
- Converted `unit_price_usd` and `unit_cost_usd` from `TEXT` to `NUMERIC(12,2)`.
- Removed currency symbols (`$`), spaces, and thousands separators (`,`) before conversion.
- Validated **2,517 product records**.
- Confirmed no missing or non-positive prices/costs.

### Stores
- Converted `square_meters` from `TEXT` to `NUMERIC`.
- Converted `open_date` from `TEXT` to `DATE`.
- Preserved valid zero values and NULLs where applicable.

### Exchange Rates
- Converted `exchange_date` from `TEXT` to `DATE`.
- Converted `exchange_rate` from `TEXT` to `NUMERIC`.
- Validated **11,215 exchange-rate records**.

### Sales
- Converted relevant date and numeric fields into appropriate warehouse-ready types.
- Converted `order_date` and `delivery_date` to `DATE`.
- Converted numeric fields such as `line_item` and `quantity` to appropriate numeric types.
- Preserved valid NULL delivery dates rather than introducing artificial values.
- Added `date_key` later in the warehouse layer to connect Sales with `dim_date`.

## 🏗️ Warehouse Layer

The transformed data was loaded into the following warehouse tables:

| Table | Records |
|---|---:|
| `dim_customer` | 15,266 |
| `dim_product` | 2,517 |
| `dim_store` | 67 |
| `dim_exchange_rate` | 11,215 |
| `fact_sales` | 62,884 |

## 🔍 Data Integrity

The transformed warehouse data was validated for:

- Appropriate data types
- Missing values
- Invalid numeric values
- Date ranges
- Key consistency
- Record counts

The original raw staging tables were retained unchanged to preserve the raw source data and support traceability.

### Validation

All warehouse tables returned the expected record counts.

Relationship validation also confirmed:

```text
Missing Customers       → 0
Missing Products        → 0
Missing Stores          → 0
Missing Exchange Rates  → 0
```

---

# ⭐ Phase 4 — Star Schema & Data Warehouse

The cleaned warehouse tables were structured into a **star schema** to support analytical reporting and Power BI.

## 📅 Date Dimension

Created a dedicated `warehouse.dim_date` table to provide a consistent calendar structure for time-based analysis.

The table was generated from the minimum and maximum Sales dates:

- **Start date:** 2016-01-01
- **End date:** 2021-02-20
- **Total dates:** 1,878

### Date Attributes

The Date Dimension contains:

| Column | Purpose |
|---|---|
| `date_key` | Unique warehouse key in `YYYYMMDD` format |
| `full_date` | Actual calendar date |
| `year` | Year-level analysis |
| `quarter` | Quarterly analysis |
| `month` | Numeric month for sorting and analysis |
| `month_name` | Month name for reporting |
| `week_of_year` | Weekly analysis |
| `day_of_month` | Day-level analysis |
| `day_name` | Day-of-week analysis |
| `is_weekend` | Identifies Saturday and Sunday |

### Why `dim_date` was created

Instead of calculating year, quarter, month, week, and weekday information directly from every Sales record, these calendar attributes are stored once in a reusable Date Dimension.

The `date_key` connects the Date Dimension to the Sales fact table:

```text
dim_date
   │
   │ date_key
   ▼
fact_sales
```

## 🔑 Primary Keys

Primary keys were added to all dimension tables:

| Dimension | Primary Key |
|---|---|
| `dim_customer` | `customer_key` |
| `dim_product` | `product_key` |
| `dim_store` | `store_key` |
| `dim_date` | `date_key` |
| `dim_exchange_rate` | `exchange_date + currency_code` |

## 🔗 Fact Table Relationships

Foreign keys were added to `fact_sales` to establish relationships with the dimension tables:

| Fact Column | Dimension |
|---|---|
| `customer_key` | `dim_customer.customer_key` |
| `product_key` | `dim_product.product_key` |
| `store_key` | `dim_store.store_key` |
| `date_key` | `dim_date.date_key` |
| `order_date + currency_code` | `dim_exchange_rate.exchange_date + currency_code` |

## ⭐ Final Star Schema

```text
                    dim_customer
                         │
                         │
                    ┌────▼────┐
dim_date ───────────► fact_sales ◄────────── dim_product
                    └────┬────┘
                         │
                  ┌──────┴──────┐
                  │             │
             dim_store   dim_exchange_rate


```
---

# 🗺️ Project Roadmap

| Phase | Status |
|---|---|
| Phase 1 — Data Loading & Setup | ✅ Completed |
| Phase 2 — Data Profiling & Quality Assessment | ✅ Completed |
| Phase 3 — Data Cleaning & Transformation | ✅ Completed |
| Phase 4 — Star Schema & Data Warehouse | ✅ Completed |
| Phase 5 — Data Enrichment & Analysis | ⏳ Planned |
| Phase 6 — Power BI Dashboard | ⏳ Planned |

---

## 📁 Repository Structure

```text
maven-electronics-global-retail/
│
├── README.md
├── data/
│   └── source/
├── sql/
│   ├── database_setup.sql
│   ├── staging_tables.sql
│   ├── data_profiling.sql
│   ├── data_cleaning.sql
│   ├── warehouse.sql
│   └── analytics.sql
├── documentation/
│   └── data_quality_report.md
└── powerbi/
    └── maven_electronics_report.pbix
```

---

## 👩‍💻 Project Focus

This project demonstrates an end-to-end analytics workflow:

**SQL → Data Quality → Data Transformation → Data Warehouse → Star Schema → Power BI → Business Insights**
