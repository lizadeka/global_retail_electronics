# Maven Electronics — Global Retail Analytics

## 📌 Project Overview

**Maven Electronics** is a global retailer selling computers, cell phones, and TVs through both online and physical stores.

The business has experienced a **downward trend in revenue since 2020**, and management needs a consolidated analytical solution to explore sales performance, customer behavior, product performance, store performance, and currency-related trends.

This project uses **PostgreSQL for data profiling, cleaning, transformation, and data warehouse development**, followed by **Power BI** for interactive reporting and business analysis.

### Project Workflow

```text
Raw CSV Data
      ↓
PostgreSQL Staging
      ↓
Data Profiling & Quality Assessment
      ↓
Data Cleaning & Transformation
      ↓
Star Schema Data Warehouse
      ↓
Data Enrichment & Analysis
      ↓
Power BI Interactive Report
```

---

## 🎯 Project Objectives

- Profile and prepare the raw datasets
- Identify and document data-quality issues
- Clean and transform the data using PostgreSQL
- Build a relational **star-schema data warehouse**
- Establish appropriate dimensions, facts, keys, and relationships
- Enrich the data for business analysis
- Build an interactive Power BI report
- Generate insights into revenue and overall business performance

---

## 🛠️ Tools & Technologies

- **PostgreSQL** — Data profiling, SQL validation, cleaning, transformation, and warehouse development
- **SQL** — Data quality checks, validation, transformation, and analysis
- **Power BI** — Interactive dashboard and business reporting
- **CSV** — Source data
- **GitHub** — Project documentation and version control

---

# 📂 Dataset Overview

The project contains five raw CSV datasets:

| Dataset | Records | Purpose |
|---|---:|---|
| Sales | 62,884 | Transaction-level sales information |
| Customers | 15,266 | Customer demographic and geographic information |
| Products | 2,517 | Product, brand, category, pricing, and feature information |
| Stores | 67 | Physical and online store information |
| Exchange Rates | 11,215 | Daily currency exchange-rate information |
| **Total** | **91,949** | |

The raw datasets were imported into PostgreSQL staging tables before any transformation was performed.

---

# 🗄️ Database Architecture

The project follows a layered PostgreSQL architecture.

```text
CSV Files
   │
   ▼
┌─────────────────────────┐
│     Staging Layer       │
│                         │
│  sales_raw              │
│  customers_raw          │
│  products_raw           │
│  stores_raw             │
│  exchange_rates_raw     │
└────────────┬────────────┘
             │
             │ Data Profiling
             │ Data Quality Checks
             │
             ▼
┌─────────────────────────┐
│     Warehouse Layer     │
│                         │
│  Dimension Tables       │
│  Fact Tables            │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│        Power BI         │
│   Interactive Report    │
└─────────────────────────┘
```

The staging layer is treated as the **raw/unchanged source layer**. Transformations will be performed when building the warehouse layer.

---

# 🔹 Phase 1 — Data Loading & Environment Setup

## PostgreSQL Environment

The raw CSV datasets were loaded into PostgreSQL staging tables:

```text
staging.sales_raw
staging.customers_raw
staging.products_raw
staging.stores_raw
staging.exchange_rates_raw
```

The purpose of the staging layer is to preserve the imported source data before applying transformations.

### Phase 1 Status

- [x] PostgreSQL environment established
- [x] Staging layer created
- [x] Raw CSV datasets imported
- [x] Record counts verified

---

# 🔍 Phase 2 — Data Profiling & Quality Assessment

Before creating warehouse tables, each dataset was systematically profiled to understand its structure, quality, and business meaning.

### Profiling Activities

- Record-count validation
- Missing-value analysis
- Duplicate detection
- Primary/business-key validation
- Data-type inspection
- Date-range validation
- Date-format validation
- Numeric range checks
- Categorical-value validation
- Foreign-key integrity checks
- Business-rule validation
- Table-grain identification
- Identification of valid business exceptions
- Documentation of transformation requirements

A structured **Data Quality Report** was maintained throughout the profiling process.

---

# 📊 Data Quality Findings

## 1. Sales — `staging.sales_raw`

### Key Findings

- **62,884** records successfully imported
- No duplicate records identified
- Business-key and foreign-key validations passed
- Currency values include USD, EUR, GBP, CAD, and AUD
- Quantity and transaction-level validations passed
- A significant number of `delivery_date` values are `NULL`
- NULL delivery dates were **retained rather than imputed**
- Date and numeric fields will be converted to appropriate warehouse data types during Phase 3

### Decision

No records will be deleted based solely on missing delivery dates.

---

## 2. Customers — `staging.customers_raw`

### Key Findings

- **15,266** records
- No missing values identified
- No duplicate records identified
- Customer keys are unique
- Gender values were validated
- Customer locations were validated across countries and continents
- State/country relationships were checked
- Birthday values were validated
- No future birthday values identified

### Geographic Validation

Country-level counts were checked across:

- United States
- United Kingdom
- Canada
- Australia
- Germany
- France
- Netherlands
- Italy

Regional distribution was also validated across:

- North America
- Europe
- Australia

### Important Finding

Some postal codes contain alphabetic characters.

These were investigated and found primarily in:

- United Kingdom
- Canada
- Netherlands

These are valid postal-code formats.

### Decision

Postal codes will remain **TEXT/string values**, rather than being incorrectly converted to numeric fields.

---

## 3. Products — `staging.products_raw`

### Key Findings

- **2,517** records
- No missing values
- No duplicate records
- Product keys are unique
- 11 brands identified
- 16 color values identified
- 8 categories identified
- 32 subcategories identified
- Product hierarchy relationships were validated
- No products were identified where price was lower than cost
- Monetary values are currently stored as text

### Brand Distribution

The largest brands identified during profiling included:

| Brand | Records |
|---|---:|
| Contoso | 710 |
| Fabrikam | 267 |
| Litware | 264 |
| Proseware | 244 |
| Southridge Video | 192 |
| Adventure Works | 192 |
| Wide World Importers | 173 |
| The Phone Company | 152 |
| Tailspin Toys | 144 |
| A. Datum | 132 |
| Northwind Traders | 47 |

### Color Distribution

The product dataset contains 16 distinct color values, including:

- Black
- White
- Silver
- Grey
- Blue
- Red
- Pink
- Brown
- Green
- Orange
- Gold
- Yellow
- Azure
- Silver Grey
- Purple
- Transparent

### Transformation Requirement

Raw monetary values contain formats such as:

```text
$1,060.22
$2,899.99
$999.90
```

The following columns require transformation:

```text
unit_cost_usd
unit_price_usd
```

Required steps:

1. Trim whitespace
2. Remove `$`
3. Remove commas
4. Convert to numeric

### Decision

The raw monetary values are valid and will be transformed rather than deleted.

---

## 4. Stores — `staging.stores_raw`

### Key Findings

- **67** records
- **66 physical stores**
- **1 Online channel**
- No duplicate store keys
- No duplicate rows
- No missing country or state values
- No invalid store-size values
- Physical store sizes range from **245 m² to 2,105 m²**
- Earliest opening date: **2005-03-04**
- Latest opening date: **2019-03-05**
- No future opening dates
- No invalid opening-date formats

### Geographic Validation

Store locations were validated across the available countries and states/regions.

The Online channel was treated separately from physical stores.

### Important Business Exception

The Online channel is represented by:

```text
store_key = 0
country = Online
state = Online
square_meters = NULL
```

This NULL value is considered **valid**, because an online channel does not have a physical store footprint.

It will therefore **not** be replaced with zero or an average store size.

### Transformation Requirements

```text
square_meters → NUMERIC
open_date      → DATE
```

---

## 5. Exchange Rates — `staging.exchange_rates_raw`

### Key Findings

- **11,215** records
- No missing values
- No duplicate rows
- 5 currencies:
  - EUR
  - AUD
  - CAD
  - USD
  - GBP
- Each currency contains exactly **2,243 records**
- Date range: **2015-01-01 to 2021-02-20**
- Exchange rates range from **0.6285 to 1.7253**
- No zero or negative exchange rates
- No invalid date formats
- No duplicate date + currency combinations

### Confirmed Table Grain

> **One exchange-rate record per currency per date**

Therefore:

```text
exchange_date + currency_code
```

forms a valid composite business key.

### Transformation Requirements

```text
exchange_date → DATE
exchange_rate → NUMERIC/DECIMAL
currency_code → TEXT
```

---

# 🧹 Consolidated Transformation Plan

The Phase 2 profiling established the following transformation requirements for Phase 3:

| Table | Column | Current Type | Target Type | Transformation |
|---|---|---|---|---|
| Customers | birthday | TEXT | DATE | Parse date |
| Products | unit_cost_usd | TEXT | NUMERIC | Remove `$`, commas, whitespace |
| Products | unit_price_usd | TEXT | NUMERIC | Remove `$`, commas, whitespace |
| Stores | square_meters | TEXT | NUMERIC | Numeric conversion |
| Stores | open_date | TEXT | DATE | Parse date |
| Exchange Rates | exchange_date | TEXT | DATE | Parse date |
| Exchange Rates | exchange_rate | TEXT | NUMERIC | Numeric conversion |
| Sales | Date fields | Raw type | DATE | Convert |
| Sales | Numeric fields | Raw type | NUMERIC | Convert where required |

---

# 🧠 Data Quality Principles Applied

An important part of this project is distinguishing between **actual data-quality problems** and **valid business conditions**.

### Missing Delivery Dates

```text
delivery_date = NULL
```

→ Retained because the transaction may not yet have been delivered.

### Online Store

```text
store_key = 0
country = Online
state = Online
square_meters = NULL
```

→ Retained because the Online channel does not represent a physical store.

### Alphanumeric Postal Codes

Postal codes from countries such as the UK, Canada, and Netherlands can legitimately contain letters.

→ Retained as **TEXT** because postal codes are identifiers, not numerical measurements.

### Text-Formatted Monetary Values

Values such as:

```text
$1,060.22
$2,899.99
```

→ Retained in the raw staging layer and scheduled for controlled numeric conversion during Phase 3.

### Data Type Mismatches

Several columns were identified as `TEXT` even though their business meaning requires:

- `DATE`
- `NUMERIC`
- `DECIMAL`

→ These will be converted during the cleaning/transformation phase rather than modifying the raw staging data.

This approach avoids unnecessary data manipulation and preserves the original business meaning of the source data.

---

# 🔑 Data Grain & Key Validation

A major part of Phase 2 was determining the **grain and key structure** of each dataset before designing the warehouse.

| Dataset | Grain / Key |
|---|---|
| Sales | One record per sales transaction/line |
| Customers | One record per customer |
| Products | One record per product |
| Stores | One record per store/channel |
| Exchange Rates | One record per currency per date |

### Key Validation Performed

- Customer key uniqueness
- Product key uniqueness
- Store key uniqueness
- Sales transaction-level validation
- Exchange-rate composite key validation
- Foreign-key consistency between related datasets

This validation provides the foundation for the warehouse model planned for Phase 3 and Phase 4.

---

# ⭐ Planned Star Schema

The final warehouse will use a **star-schema design**, with Sales serving as the central fact table and descriptive entities represented as dimensions.

```text
                    ┌──────────────────┐
                    │   dim_customer   │
                    └────────┬─────────┘
                             │
                             │
┌──────────────┐      ┌──────▼───────┐      ┌──────────────┐
│   dim_date   │──────│  fact_sales  │──────│  dim_product │
└──────────────┘      └──────┬───────┘      └──────────────┘
                             │
                    ┌────────┴─────────┐
                    │                  │
             ┌──────▼──────┐   ┌──────▼──────────────┐
             │  dim_store  │   │ dim_exchange_rate   │
             └─────────────┘   └─────────────────────┘
```

The final schema will be confirmed and implemented during the warehouse-building phase.

---

# 📁 Planned Repository Structure

```text
maven-electronics-global-retail/
│
├── README.md
│
├── data/
│   └── source/
│       ├── sales.csv
│       ├── customers.csv
│       ├── products.csv
│       ├── stores.csv
│       └── exchange_rates.csv
│
├── sql/
│   ├── 01_database_setup.sql
│   ├── 02_staging_tables.sql
│   ├── 03_data_profiling.sql
│   ├── 04_data_cleaning.sql
│   ├── 05_warehouse.sql
│   └── 06_analytics.sql
│
├── documentation/
│   └── data_quality_report.md
│
└── powerbi/
    └── maven_electronics_report.pbix
```

---

# 📌 Current Project Status

## Phase 1 + Phase 2 Completed ✅

The raw datasets have been successfully loaded into PostgreSQL and comprehensively profiled.

The profiling process identified:

- Data-quality findings
- Business exceptions
- Table grain
- Business keys
- Data-type issues
- Date and numeric validation requirements
- Transformation requirements
- Warehouse design considerations

These findings have been documented as the foundation for the next stage of the project.

### Next Step

**Phase 3 — Data Cleaning & Transformation**

The next phase will transform the validated staging data into properly typed, warehouse-ready tables while preserving the raw staging layer.

---

## 👩‍💻 Project Focus

This project demonstrates an end-to-end analytics workflow:

**SQL → Data Quality → Data Transformation → Data Warehouse → Star Schema → Power BI → Business Insights**
