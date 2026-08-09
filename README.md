# Maven Electronics — Global Retail Analytics

### Overview

Maven Electronics is a global electronics retailer selling computers, cell phones, TVs, and cameras through online and physical stores. As a Data Analyst, I analyzed the company's sales and operational data to investigate the decline in revenue following its 2019 peak.

Using the provided datasets, I built a structured data model and interactive Power BI dashboard to analyze revenue, profit, customers, products, sales channels, seasonal trends, and delivery performance. The goal was to identify key business trends, understand the factors associated with the revenue decline, and provide actionable recommendations for management.

This project uses **PostgreSQL for data profiling, cleaning, transformation, and data warehouse development**, followed by **Power BI for interactive business reporting**.

### Workflow

```text
Raw CSVs → PostgreSQL Staging → Data Profiling
→ Data Cleaning → Star Schema → Power BI → Insights
```

---

### Tools & Technologies

- **PostgreSQL**
- **SQL**
- **Power BI**
- **GitHub**

---

### Dataset

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

## Data Loading & Setup

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

## Data Profiling & Quality Assessment

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

## Data Transformation

The cleaned staging data was transformed into warehouse-ready tables while keeping the original staging layer unchanged.

### 🛠️ Transformations Performed

#### Customers
- Converted `birthday` from `TEXT` to `DATE`.
- Preserved the original customer records in the staging layer.

#### Products
- Converted `unit_price_usd` and `unit_cost_usd` from `TEXT` to `NUMERIC(12,2)`.
- Removed currency symbols (`$`), spaces, and thousands separators (`,`) before conversion.
- Validated **2,517 product records**.
- Confirmed no missing or non-positive prices/costs.

#### Stores
- Converted `square_meters` from `TEXT` to `NUMERIC`.
- Converted `open_date` from `TEXT` to `DATE`.
- Preserved valid zero values and NULLs where applicable.

#### Exchange Rates
- Converted `exchange_date` from `TEXT` to `DATE`.
- Converted `exchange_rate` from `TEXT` to `NUMERIC`.
- Validated **11,215 exchange-rate records**.

#### Sales
- Converted relevant date and numeric fields into appropriate warehouse-ready types.
- Converted `order_date` and `delivery_date` to `DATE`.
- Converted numeric fields such as `line_item` and `quantity` to appropriate numeric types.
- Preserved valid NULL delivery dates rather than introducing artificial values.
- Added `date_key` later in the warehouse layer to connect Sales with `dim_date`.

### Warehouse Layer

The transformed data was loaded into the following warehouse tables:

| Table | Records |
|---|---:|
| `dim_customer` | 15,266 |
| `dim_product` | 2,517 |
| `dim_store` | 67 |
| `dim_exchange_rate` | 11,215 |
| `fact_sales` | 62,884 |

### Data Integrity

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

## Star Schema & Data Warehouse

The cleaned warehouse tables were structured into a **star schema** to support analytical reporting and Power BI.

### Date Dimension

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

### `dim_date` was created :

Instead of calculating year, quarter, month, week, and weekday information directly from every Sales record, these calendar attributes are stored once in a reusable Date Dimension.

The `date_key` connects the Date Dimension to the Sales fact table:

```text
dim_date
   │
   │ date_key
   ▼
fact_sales
```

### Primary Keys

Primary keys were added to all dimension tables:

| Dimension | Primary Key |
|---|---|
| `dim_customer` | `customer_key` |
| `dim_product` | `product_key` |
| `dim_store` | `store_key` |
| `dim_date` | `date_key` |
| `dim_exchange_rate` | `exchange_date + currency_code` |

### Fact Table Relationships

Foreign keys were added to `fact_sales` to establish relationships with the dimension tables:

| Fact Column | Dimension |
|---|---|
| `customer_key` | `dim_customer.customer_key` |
| `product_key` | `dim_product.product_key` |
| `store_key` | `dim_store.store_key` |
| `date_key` | `dim_date.date_key` |
| `order_date + currency_code` | `dim_exchange_rate.exchange_date + currency_code` |

### Final Star Schema

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

## Analytics Layer & Business Analysis

With the warehouse layer completed, the next stage focused on analyzing sales performance and identifying the key drivers behind Maven Electronics' revenue decline.

The analysis was performed using the warehouse tables in PostgreSQL, and the validated findings were then organized into reusable analytical views within the `analytics` schema.


### 5.1 Overall Sales Performance

Established baseline sales KPIs across the complete sales dataset:

- **Total Revenue:** $55.76M
- **Total Units Sold:** 197,757
- **Total Orders:** 26,326
- **Total Customers:** 11,887
- **Products Sold:** 2,492
- **Average Order Value:** $2,117.89

These metrics provided the baseline for subsequent performance analysis.


### 5.2 Yearly Sales Trend

Analyzed revenue, units sold, orders, customers, Average Order Value (AOV), and orders per customer across years.

The analysis identified **2019 as the peak sales year**, followed by a significant decline in 2020.

#### 2019 → 2020 Change

| Metric | 2019 | 2020 | Change |
|---|---:|---:|---:|
| Revenue | $18.26M | $9.29M | **-49.1%** |
| Orders | 9,083 | 4,635 | **-49.0%** |
| Units Sold | 68,440 | 34,463 | **-49.6%** |
| Active Customers | 6,497 | 3,868 | **-40.5%** |
| Average Order Value | $2,010.83 | $2,005.31 | **-0.3%** |
| Orders per Customer | 1.40 | 1.20 | **-14.3%** |

The results indicate that the revenue decline was primarily **volume-driven rather than price- or basket-value-driven**.


### 5.3 Sales Channel Analysis

Compared Online and Physical sales performance across years.

The 2019 → 2020 decline affected both channels:

- **Online revenue declined by approximately 47.0%**
- **Physical revenue declined by approximately 49.7%**

This indicates that the decline was **broad-based rather than isolated to a single sales channel**.

Physical stores contributed the larger absolute revenue decline due to their larger overall revenue base.


### 5.4 Country Analysis

Analyzed physical-store revenue performance across eight countries while treating `Online` separately as a sales channel.

Key finding:

- The **United States** generated the largest absolute revenue decline from 2019 to 2020.
- U.S. revenue declined from approximately **$7.85M to $4.15M**, a reduction of approximately **$3.69M**.
- All physical markets experienced revenue declines during 2020.

This indicated that the decline was geographically broad rather than concentrated in a single market.


### 5.5 Product Category Analysis

Analyzed revenue, units sold, orders, and customers across eight product categories.

Key findings:

- **Computers** generated the largest absolute revenue decline, falling from approximately **$6.96M to $3.67M**.
- **Home Appliances** experienced one of the largest percentage declines, at approximately **59%**.
- **Audio** also experienced a significant decline of approximately **57%**.
- Every product category experienced a decline in revenue and unit volume during 2020.

Computers also recorded the largest absolute reduction in units sold, declining by approximately **8,262 units**.

### 5.6 Customer Activity Analysis

Analyzed active customers, orders, units sold, and purchase frequency by year.

The analysis showed:

- Active customers declined from **6,497 in 2019 to 3,868 in 2020**.
- Orders per customer declined from **1.40 to 1.20**.
- This indicates that the reduction in orders was associated with both:
  - A smaller active customer base
  - Lower purchase frequency among active customers

### Analytics Views

The validated analysis was organized into reusable PostgreSQL views within the `analytics` schema.

| Analytical View | Purpose |
|---|---|
| `analytics.sales_yearly` | Yearly revenue and sales performance |
| `analytics.sales_channel` | Online vs Physical channel performance |
| `analytics.sales_category` | Product category performance |
| `analytics.sales_country` | Physical market/country performance |
| `analytics.customer_activity` | Customer activity and purchase frequency |

These views provide a structured analytical layer for SQL-based investigation and documentation while preserving the detailed warehouse tables for downstream BI analysis.

### 5.8 Key Business Finding

The analysis indicates that Maven Electronics' major revenue decline in 2020 was primarily **volume-driven**.

Revenue declined by approximately **49.1%**, while:

- Orders declined by approximately **49.0%**
- Units sold declined by approximately **49.6%**
- Active customers declined by approximately **40.5%**
- Orders per customer declined by approximately **14.3%**
- Average Order Value declined by only **0.3%**

The decline was broad-based across **sales channels, physical markets, and product categories**, suggesting that the primary issue was a significant reduction in sales activity rather than a major deterioration in order value.

---

## Power BI Dashboard

### Page 1 — Sales Performance
**Business Question:** Where is the business generating revenue?

Provides an executive overview of sales performance across products, markets, sales channels, and time.

- **KPIs:** Total Revenue, Total Orders, Total Customers, Average Order Value
- **Visuals:** Revenue by Product Category, Revenue by Continent, Revenue by Sales Channel, Revenue Trend by Year
- **Filters:** Year, Country



### Page 2 — Business Performance
**Business Question:** How are revenue, profitability, orders, and customer volume changing over time?

Analyzes business performance from **2016–2021** using interactive metric selectors.

- **Dynamic Financial Trend:** Revenue, Profit, Profit Margin
- **Dynamic Business Volume Trend:** Orders, Customers
- **Additional Analysis:** Yearly Revenue & Profit Performance
- Dynamic visuals allow multiple metrics to be explored without duplicating charts.



### Page 3 — Customer & Product Insights
**Business Question:** Who are the customers, and which products, categories, and brands drive performance?

Combines customer, product, and profitability analysis.

- **KPIs:** Total Customers, Top Brand, Top Category, Average Order Value
- **Visuals:** Customers by Country, Average Revenue per Customer by Country, AOV by Sales Channel
- **Dynamic Matrix:** Brand → Category → Product
- **Metrics:** Revenue, Profit, Profit Margin %, Orders, Average Order Value

The matrix allows users to drill from brand-level performance into categories and individual products.



### Page 4 — Monthly Performance & Trends
**Business Question:** How does business performance change throughout the year?

Examines monthly sales patterns, customer spending, order activity, and delivery performance across **2016–2021**.

- **KPIs:** Peak Revenue Month, Peak Order Volume Month, Peak AOV Month, Average Delivery Time
- **Visuals:** Monthly Revenue Trend, Monthly Order Volume Trend, Monthly AOV Trend, Delivery Time Trend
- **Filters:** Year + Quarter, Country

This page highlights seasonal patterns, peak-performing periods, and operational trends.

---

## Key Business Insights

- **Revenue declined sharply after 2019**, falling by **49.1% in 2020**. The decline was primarily volume-driven, with **orders falling 49.0%** and **units sold falling 49.6%**, while **Average Order Value (AOV) decreased by only 0.3%**.

- **Customer activity weakened significantly**, with active customers declining from **6,497 in 2019 to 3,868 in 2020 (-40.5%)**. Orders per customer also fell from **1.40 to 1.20**, indicating lower purchase frequency.

- **The 2020 decline was broad-based**, affecting all countries, product categories, and both online and physical sales channels rather than being isolated to one area of the business.

- **The United States had the largest absolute revenue impact**, losing approximately **$3.69M** between 2019 and 2020, while Germany experienced one of the largest percentage declines at approximately **59%**.

- **Computers remained the strongest product category**, generating **$19.3M** in revenue, while Home Appliances generated **$10.8M**. Computers also contributed the largest absolute revenue loss during the 2020 decline.

- **In-store sales dominated the business**, generating approximately **$44M** compared with **$11M from online sales**, highlighting an opportunity to strengthen the online channel.

- **Customer value varied across markets**. The United States had the largest customer base at approximately **5K customers**, while average revenue per customer was **$5.2K in the US, $4.7K in Germany, and $4.6K in Italy**.

- **Seasonal patterns were visible across the business**. February recorded the highest monthly revenue at **$6.3M**, December had the highest order volume at **3.5K**, and April recorded the highest AOV at **$2,291.83**.

- **Delivery performance improved over time**, with average delivery time falling from **7.3 days in 2016 to 3.8 days in 2021**, indicating that the revenue decline was not accompanied by worsening delivery efficiency.

### Key Takeaway

The analysis suggests that Maven Electronics' main challenge was a **sharp decline in customer and order volume rather than a significant drop in order value**. The business should therefore focus on customer retention, reactivation, repeat purchases, and order growth while protecting strong product and market segments and reducing dependence on the in-store channel.

---
## Repository Structure

```text
global_retail_electronics/
│
├── README.md
├── images
├── sql/
│   ├── analysis1.sql
├── demo video/
    └── Global electronics demo

```

---

## 👩‍💻 Project Focus

This project demonstrates an end-to-end analytics workflow:

**SQL → Data Quality → Data Transformation → Data Warehouse → Star Schema → Power BI → Business Insights**

---

## 🙏 Acknowledgements

This project was completed from **Maven Analytics Global Electronics Retailer**, providing hands-on experience in SQL-based data analysis and business problem-solving.

---

## About Me  
👋 Hi, I'm Liza Deka, a data enthusiast.  
   I enjoy building projects, analyzing real-world data, and sharing insights through GitHub and LinkedIn. 
   
  📬 Let’s Connect: <a href="https://www.linkedin.com/in/liza-deka-869473369/">LinkedIn</a>


⭐ If you found this project helpful or interesting, feel free to star the repository!
