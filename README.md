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

# 📊 Phase 5 — Analytics Layer & Business Analysis

With the warehouse layer completed, the next stage focused on analyzing sales performance and identifying the key drivers behind Maven Electronics' revenue decline.

The analysis was performed using the warehouse tables in PostgreSQL, and the validated findings were then organized into reusable analytical views within the `analytics` schema.

---

## 🔍 5.1 Overall Sales Performance

Established baseline sales KPIs across the complete sales dataset:

- **Total Revenue:** $55.76M
- **Total Units Sold:** 197,757
- **Total Orders:** 26,326
- **Total Customers:** 11,887
- **Products Sold:** 2,492
- **Average Order Value:** $2,117.89

These metrics provided the baseline for subsequent performance analysis.

---

## 📈 5.2 Yearly Sales Trend

Analyzed revenue, units sold, orders, customers, Average Order Value (AOV), and orders per customer across years.

The analysis identified **2019 as the peak sales year**, followed by a significant decline in 2020.

### 2019 → 2020 Change

| Metric | 2019 | 2020 | Change |
|---|---:|---:|---:|
| Revenue | $18.26M | $9.29M | **-49.1%** |
| Orders | 9,083 | 4,635 | **-49.0%** |
| Units Sold | 68,440 | 34,463 | **-49.6%** |
| Active Customers | 6,497 | 3,868 | **-40.5%** |
| Average Order Value | $2,010.83 | $2,005.31 | **-0.3%** |
| Orders per Customer | 1.40 | 1.20 | **-14.3%** |

The results indicate that the revenue decline was primarily **volume-driven rather than price- or basket-value-driven**.

---

## 🛒 5.3 Sales Channel Analysis

Compared Online and Physical sales performance across years.

The 2019 → 2020 decline affected both channels:

- **Online revenue declined by approximately 47.0%**
- **Physical revenue declined by approximately 49.7%**

This indicates that the decline was **broad-based rather than isolated to a single sales channel**.

Physical stores contributed the larger absolute revenue decline due to their larger overall revenue base.

---

## 🌍 5.4 Country Analysis

Analyzed physical-store revenue performance across eight countries while treating `Online` separately as a sales channel.

Key finding:

- The **United States** generated the largest absolute revenue decline from 2019 to 2020.
- U.S. revenue declined from approximately **$7.85M to $4.15M**, a reduction of approximately **$3.69M**.
- All physical markets experienced revenue declines during 2020.

This indicated that the decline was geographically broad rather than concentrated in a single market.

---

## 📦 5.5 Product Category Analysis

Analyzed revenue, units sold, orders, and customers across eight product categories.

Key findings:

- **Computers** generated the largest absolute revenue decline, falling from approximately **$6.96M to $3.67M**.
- **Home Appliances** experienced one of the largest percentage declines, at approximately **59%**.
- **Audio** also experienced a significant decline of approximately **57%**.
- Every product category experienced a decline in revenue and unit volume during 2020.

Computers also recorded the largest absolute reduction in units sold, declining by approximately **8,262 units**.

---

## 👥 5.6 Customer Activity Analysis

Analyzed active customers, orders, units sold, and purchase frequency by year.

The analysis showed:

- Active customers declined from **6,497 in 2019 to 3,868 in 2020**.
- Orders per customer declined from **1.40 to 1.20**.
- This indicates that the reduction in orders was associated with both:
  - A smaller active customer base
  - Lower purchase frequency among active customers

---

# 🏗️ 5.7 Analytics Views

The validated analysis was organized into reusable PostgreSQL views within the `analytics` schema.

| Analytical View | Purpose |
|---|---|
| `analytics.sales_yearly` | Yearly revenue and sales performance |
| `analytics.sales_channel` | Online vs Physical channel performance |
| `analytics.sales_category` | Product category performance |
| `analytics.sales_country` | Physical market/country performance |
| `analytics.customer_activity` | Customer activity and purchase frequency |

These views provide a structured analytical layer for SQL-based investigation and documentation while preserving the detailed warehouse tables for downstream BI analysis.

---

# 🎯 5.8 Key Business Finding

The analysis indicates that Maven Electronics' major revenue decline in 2020 was primarily **volume-driven**.

Revenue declined by approximately **49.1%**, while:

- Orders declined by approximately **49.0%**
- Units sold declined by approximately **49.6%**
- Active customers declined by approximately **40.5%**
- Orders per customer declined by approximately **14.3%**
- Average Order Value declined by only **0.3%**

The decline was broad-based across **sales channels, physical markets, and product categories**, suggesting that the primary issue was a significant reduction in sales activity rather than a major deterioration in order value.

---

## ✅ Phase 5 Status

**Completed**

The PostgreSQL analytics layer and initial business analysis are complete. The validated findings will be carried forward into the Business Intelligence/dashboard stage.

---

# 🗺️ Project Roadmap

| Phase | Status |
|---|---|
| Phase 1 — Data Loading & Setup | ✅ Completed |
| Phase 2 — Data Profiling & Quality Assessment | ✅ Completed |
| Phase 3 — Data Cleaning & Transformation | ✅ Completed |
| Phase 4 — Star Schema & Data Warehouse | ✅ Completed |
| Phase 5 — Data Enrichment & Analysis | ✅ Completed |
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
