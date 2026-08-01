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

# 🧹 Phase 2 → Phase 3 Transformation Plan

| Dataset | Transformation |
|---|---|
| Customers | Convert birthday to `DATE` |
| Products | Convert price/cost fields from `TEXT` to `NUMERIC` |
| Stores | Convert square meters to `NUMERIC` and opening date to `DATE` |
| Exchange Rates | Convert exchange date and rate to appropriate types |
| Sales | Convert relevant date and numeric fields |

The raw staging tables will remain unchanged while transformations are performed in the warehouse layer.

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

# 🗺️ Project Roadmap

| Phase | Status |
|---|---|
| Phase 1 — Data Loading & Setup | ✅ Completed |
| Phase 2 — Data Profiling & Quality Assessment | ✅ Completed |
| Phase 3 — Data Cleaning & Transformation | 🔄 Next |
| Phase 4 — Data Warehouse & Star Schema | ⏳ Planned |
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

## 📌 Current Status

**Phase 1 and Phase 2 completed.**

The raw datasets have been loaded, profiled, validated, and documented. Data-quality issues, valid business exceptions, table grain, keys, and transformation requirements have been identified.

### Next: Phase 3 — Data Cleaning & Transformation

The next stage will transform the validated staging data into **warehouse-ready tables** while preserving the original raw data.

---

## 👩‍💻 Project Focus

This project demonstrates an end-to-end analytics workflow:

**SQL → Data Quality → Data Transformation → Data Warehouse → Star Schema → Power BI → Business Insights**
