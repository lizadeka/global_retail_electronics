# Maven Electronics — Global Retail Sales & Performance Analysis

## Project Overview

Maven Electronics is a fictitious global electronics retailer selling computers, mobile phones, TVs, cameras, appliances, and other consumer electronics through both online and in-store channels.

This project analyzes the company's sales performance using transaction, product, customer, store, and exchange-rate data. The analysis was developed around a business scenario in which Maven Electronics experienced a significant decline in revenue after its 2019 peak, creating a need for management to understand what changed and where attention should be focused.

The project follows a business-focused analytics workflow:

**Prepare → Profile → Build Data Model → Enrich & Explore → Build Interactive Report → Generate Business Insights**

The final Power BI report provides management with an interactive view of overall sales performance, revenue and profit trends, customer and product performance, sales channels, seasonal patterns, and delivery operations.

## Business Problem

Maven Electronics experienced a significant decline in revenue after 2019. Management needed a data-driven way to understand the company's performance, identify the factors associated with the decline, and explore opportunities for improvement.

The analysis therefore focuses on questions such as:

- Where is the company's revenue coming from?
- What changed after the 2019 revenue peak?
- How did profit change alongside revenue?
- Which countries, brands, and product categories contribute most to performance?
- Where are customers located?
- How does performance differ between online and in-store sales?
- Are there seasonal patterns in revenue, order volume, and average order value?
- How is delivery performance changing over time?
- What should management prioritize based on the analysis?

## Project Objectives

The main objectives of this project were to:

1. Prepare and profile the raw datasets for analysis.
2. Identify and resolve data-quality and data-type issues.
3. Build a relational data model suitable for Power BI analysis.
4. Create calculated measures and enrich the data for business analysis.
5. Analyze revenue, profit, customers, products, brands, sales channels, seasonality, and delivery performance.
6. Build an interactive multi-page Power BI report.
7. Translate analytical findings into actionable business insights and management priorities.

## Data Source & Dataset

This project uses the **Maven Electronics Global Retail dataset** from Maven Analytics. The dataset contains fictional sales data for a global electronics retailer and includes information about transactions, products, customers, stores, and exchange rates.

### Dataset Components

| Dataset | Description |
|---|---|
| **Sales** | Transaction-level sales information, including orders, products, customers, stores, dates, quantities, delivery information, and sales channels. |
| **Customers** | Customer-level information used to analyze customer distribution and purchasing behavior. |
| **Products** | Product information including product categories, brands, unit costs, and unit prices. |
| **Stores** | Store information used to analyze physical store operations and sales performance. |
| **Exchange Rates** | Daily exchange-rate information used to support analysis across different currencies. |

### Data Volume

The raw datasets were loaded into PostgreSQL and profiled before transformation.

| Dataset | Records |
|---|---:|
| Sales | 62,884 |
| Customers | 15,266 |
| Products | 2,517 |
| Stores | 67 |
| Exchange Rates | 11,215 |

### Data Source Note

The dataset is based on a **fictitious business scenario** created for analytics practice. The project was initially guided by the Maven Analytics project brief, but the final analysis was structured as an independent portfolio project around the underlying business problem of declining revenue.

## Tools & Technologies

| Tool / Technology | Purpose |
|---|---|
| **PostgreSQL** | Data storage, profiling, cleaning, transformation, and preparation of the datasets. |
| **pgAdmin 4** | PostgreSQL database management and SQL development environment. |
| **Power BI** | Data modeling, DAX measures, interactive dashboard development, and business analysis. |
| **Power Query** | Data transformation and preparation before analysis. |
| **DAX** | Creation of calculated measures and business metrics for the Power BI report. |
| **GitHub** | Project documentation, version control, and portfolio presentation. |

### Core Skills Applied

- SQL and PostgreSQL
- Data Cleaning & Data Profiling
- Relational Data Modeling
- Data Transformation
- Power Query
- DAX
- Business Analysis
- Data Visualization
- Dashboard Development
- KPI Development

## Data Preparation & Profiling

The raw CSV files were first loaded into PostgreSQL staging tables and profiled before being used for analysis. The objective was to identify data-quality issues, understand the structure and grain of each dataset, and prepare the data for reliable downstream modeling.

### Data Profiling

The datasets were profiled for:

- Row counts and column counts
- Missing and null values
- Duplicate records
- Data types
- Date ranges
- Key uniqueness
- Referential integrity
- Table grain
- Business-rule consistency
- Invalid or unexpected values

### Data Quality & Transformation Challenges

Several data-quality and import issues were identified during the preparation process.

#### Date Formatting

Some date values were stored in formats that caused PostgreSQL import and date-conversion issues, including values such as:

`1/13/2016`

Date fields were standardized and converted to appropriate `DATE` values for reliable time-based analysis.

#### Text-Based Numeric Fields

Some monetary fields were stored as text rather than numeric values. For example, product price values contained currency symbols and extra spaces:

`$1,060.22 `

These fields were cleaned and converted into appropriate numeric data types so that revenue, cost, pricing, and profitability calculations could be performed correctly.

#### Encoding Issues

Character-encoding inconsistencies were encountered during CSV imports. Where required, the source encoding was adjusted during the PostgreSQL import process to successfully load the data while preserving the underlying records.

#### Missing Values

Missing and null values were profiled across the datasets. Valid business exceptions were preserved where appropriate rather than automatically replacing or deleting missing values.

#### Data-Type Standardization

Fields such as dates, prices, costs, quantities, store attributes, and exchange rates were reviewed and converted to appropriate data types to support accurate calculations and analysis.

### Preparation Approach

The preparation workflow followed:

**Raw CSV Files → PostgreSQL Staging → Data Profiling → Cleaning & Transformation → Warehouse-Ready Data → Power BI**

The raw staging layer was retained separately from the transformed data so that the original imported data remained available for validation and comparison.

## Data Model & Database Architecture

After profiling and cleaning the raw datasets, the data was organized into a relational structure in PostgreSQL to support consistent analysis and downstream Power BI reporting.

### Database Architecture

The project followed a layered approach:

**Raw CSV Files → Staging Layer → Warehouse Layer → Power BI**

The staging layer preserved the imported source data, while the warehouse layer provided a cleaner structure for analytical use.

### Staging Layer

The staging layer was used to store the raw datasets after import.

It contained the source-level tables for:

- Sales
- Customers
- Products
- Stores
- Exchange Rates

The staging layer was kept separate from the transformed warehouse layer to preserve the original imported data and support validation.

### Warehouse Layer

The warehouse layer was structured using fact and dimension tables.

#### Fact Table

**`fact_sales`**

Contains transaction-level sales records and measures such as:

- Order information
- Product and customer references
- Store references
- Order and delivery dates
- Quantity sold
- Sales channel
- Revenue-related fields

#### Dimension Tables

**`dim_customer`**
- Customer attributes
- Customer identifiers

**`dim_product`**
- Product
- Brand
- Product category
- Unit cost
- Unit price

**`dim_store`**
- Store attributes
- Store location and related information

**`dim_exchange_rate`**
- Currency
- Exchange-rate information
- Date-based exchange rates

**`dim_date`**
- Date
- Year
- Month
- Month number
- Other calendar attributes used for time-based analysis

### Data Modeling Approach

The warehouse structure follows a **star-schema approach**, with `fact_sales` acting as the central fact table and the dimension tables providing descriptive attributes for analysis.

This structure enabled Power BI to analyze sales across multiple business dimensions, including:

- Time
- Customers
- Products
- Brands
- Product categories
- Stores
- Countries
- Sales channels
- Currency

### Power BI Model

The warehouse tables were connected in Power BI using relationships between the fact table and the relevant dimension tables.

A dedicated **Date table** was used for time-based analysis and filtering, allowing the report to analyze:

- Yearly revenue trends
- Monthly revenue
- Monthly order volume
- Monthly AOV
- Delivery-time trends

The model was designed to support interactive filtering and consistent DAX calculations across the report.

---

## Data Enrichment & Analysis

After building the warehouse structure, the data was enriched with calculated measures and analytical fields in Power BI. These measures were designed around the business questions and used consistently across the interactive report.

### Core Business Measures

The following measures were created to support the analysis:

| Measure | Purpose |
|---|---|
| **Total Revenue** | Measures overall sales revenue. |
| **Total Orders** | Measures the number of orders/transactions. |
| **Total Customers** | Measures the number of customers represented in the sales data. |
| **Average Order Value (AOV)** | Measures the average revenue generated per order. |
| **Total Profit** | Measures profit using sales quantity, unit selling price, and unit cost. |
| **Revenue Decline %** | Measures the percentage change in revenue between 2019 and 2020. |
| **Average Delivery Days** | Measures the average number of days between order and delivery. |

### Profit Analysis

Profit was calculated using the relationship between product pricing, product cost, and sales quantity:

**Profit = (Unit Price − Unit Cost) × Quantity Sold**

This allowed the report to compare revenue performance with profitability and identify whether changes in revenue were accompanied by changes in profit.

### Revenue Decline Analysis

A dedicated revenue-decline measure was created to compare performance between the 2019 peak and 2020.

The analysis showed:

- **2019 Revenue → 2020 Revenue:** 49.11% decline
- **2019 Profit:** approximately **$10.7M**
- **2020 Profit:** approximately **$5.4M**

This comparison became a central part of the business analysis because the project scenario focuses on Maven Electronics' declining revenue after its 2019 peak.

### Customer & Product Analysis

The data model was used to analyze:

- Customers by country
- Revenue by brand
- Units sold by product category
- Product category performance
- Customer and product contribution to overall sales

These analyses helped identify the markets, brands, and product categories that matter most to the business.

### Sales Channel Analysis

Sales performance was compared across:

- **In-store**
- **Online**

The analysis also compared average order value across the two channels to determine whether the difference in channel revenue was primarily associated with order value or sales volume.

### Time & Seasonality Analysis

The Date dimension enabled monthly and yearly analysis of:

- Revenue trends
- Order volume
- Average order value
- Delivery time

Peak periods identified in the analysis included:

- **Peak Revenue:** February — approximately **$7.8M**
- **Peak Order Volume:** December — approximately **3.5K orders**
- **Peak AOV:** April — approximately **$2,291.83**

### Delivery Performance

Average delivery time was calculated using order and delivery dates.

The overall average delivery time was:

**4.53 days**

A monthly trend was also created to monitor changes in delivery performance over time.

### Analytical Focus

The measures and calculated fields were created to answer business questions rather than simply provide descriptive statistics. The analysis focused on understanding:

**Revenue → Profit → Customers → Products → Channels → Seasonality → Operations → Management Priorities**

---

## Power BI Dashboard & Report Structure

The final Power BI report was designed as a five-page interactive business analysis report. Each page focuses on a specific business question and builds toward an overall management view.

### Page 1 — Sales Performance

**Business Question:**  
*Where is the business generating revenue?*

#### KPIs

- Total Revenue
- Total Orders
- Total Customers
- Average Order Value

#### Visuals

- Revenue by Product Category
- Revenue by Country
- Revenue by Sales Channel
- Revenue Trend by Year

#### Filter

- Year

This page provides an overview of the company's sales performance and highlights the main revenue sources across products, markets, sales channels, and time.

---

### Page 2 — Revenue & Profit Performance

**Business Question:**  
*What changed after the 2019 peak?*

#### KPIs

- Total Revenue
- Total Orders
- Total Profit
- Revenue Decline %

#### Visuals

- Yearly Revenue & Profit Trend
- Revenue & Profit: 2019 vs. 2020
- Yearly Orders & Customers Trend
- Average Order Value Trend

#### Filter

- Year

This page focuses on the company's revenue decline and compares revenue with profitability to understand the scale and persistence of the downturn.

---

### Page 3 — Customer & Product Insights

**Business Question:**  
*Who are our customers, and what drives sales?*

#### KPIs

- Total Customers
- Top Brand
- Top Product Category
- Average Order Value

#### Visuals

- Customers by Country
- Top 10 Brands by Revenue
- Units Sold by Product Category
- Average Order Value by Sales Channel

#### Filter

- Year

This page examines customer distribution, brand contribution, product demand, and differences in order value across sales channels.

---

### Page 4 — Trends & Operations

**Business Question:**  
*When does the business perform, and how is the operation performing?*

#### KPIs

- Average Delivery Days — **4.53 days**
- Peak Revenue Month — **February**
- Peak Order Month — **December**
- Peak AOV Month — **April**

#### Visuals

- Monthly Revenue Trend
- Monthly Order Volume Trend
- Average Delivery Time Trend
- Monthly Average Order Value

#### Filter

- Year

This page focuses on monthly patterns, seasonality, customer spending behavior, and delivery performance.

---

### Page 5 — Executive Insights

**Business Question:**  
*What should management take away from the analysis?*

#### Headline Cards

- Revenue Decline — **-49.11%**
- Profit Decline — **approximately -49.5%**
- In-Store Revenue — **~$44M**
- Average Delivery Time — **4.53 days**

#### Insight Sections

**Revenue & Profit Decline**
- Revenue fell sharply after the 2019 peak.
- Profit declined from approximately $10.7M in 2019 to $5.4M in 2020.

**Sales Channel**
- In-store revenue is approximately $44M compared with $11M online.
- AOV is relatively similar across channels.

**Customers & Products**
- Key countries, brands, and product categories contribute significantly to overall performance.

**Seasonality & Operations**
- February has the highest revenue.
- December has the highest order volume.
- April has the highest AOV.
- Average delivery time is 4.53 days.

#### Management Priorities

1. Investigate the drivers of the revenue decline.
2. Identify opportunities to strengthen online sales.
3. Focus on high-performing products, brands, and markets.
4. Plan around seasonal demand patterns.
5. Monitor delivery performance over time.

---

### Report Design Approach

The report was structured to move from **descriptive analysis to diagnostic insights and management recommendations**:

**Sales Overview → Revenue & Profit Decline → Customer & Product Drivers → Seasonality & Operations → Executive Insights**

This structure allows users to move from understanding overall performance to investigating potential drivers and finally reviewing the key business implications.

---

## Key Business Insights

The analysis identified several important findings across revenue, profitability, customers, products, sales channels, seasonality, and operations.

### 1. Significant Revenue Decline After 2019

Revenue declined by **49.11% from 2019 to 2020**, making the 2019–2020 period the most significant point of decline in the analysis.

Profit also fell from approximately **$10.7M in 2019 to $5.4M in 2020**, representing an approximately **49.5% decline**.

The decline continued into 2021, indicating that the downturn was not simply a short-term fluctuation.

**Business implication:**  
Management should investigate the specific products, brands, markets, and sales channels that contributed most to the decline.

---

### 2. In-Store Sales Dominate Revenue

In-store revenue is approximately **$44M**, compared with approximately **$11M from online sales**.

However, average order value is relatively similar across the two channels:

- **In-store AOV:** approximately $2.1K
- **Online AOV:** approximately $2.0K

This indicates that the large difference in total channel revenue is more closely associated with **order volume than average order value**.

**Business implication:**  
Increasing online order volume represents a potential area for growth while maintaining the existing in-store customer base.

---

### 3. Customer and Product Performance Is Concentrated

The analysis of customers by country, brands by revenue, and product categories by units sold shows that business performance is not evenly distributed across all markets and products.

A smaller group of leading brands, categories, and markets contributes significantly to overall business activity.

**Business implication:**  
Management should protect high-performing products and markets while investigating weaker contributors for potential improvement.

---

### 4. Revenue, Order Volume, and AOV Peak in Different Months

The monthly analysis identified different peak periods:

- **Peak Revenue:** February — approximately **$7.8M**
- **Peak Order Volume:** December — approximately **3.5K orders**
- **Peak AOV:** April — approximately **$2,291.83**

Because these metrics peak in different months, monthly revenue performance is influenced by more than one factor.

**Business implication:**  
Inventory, promotions, staffing, and capacity planning should consider revenue, order volume, and customer spending patterns separately.

---

### 5. Delivery Performance Provides an Operational Benchmark

The overall average delivery time is approximately **4.53 days**.

The monthly delivery-time trend provides additional visibility into whether operational performance changes during different periods.

**Business implication:**  
The 4.53-day average can serve as a baseline for monitoring delivery performance and identifying periods where operational efficiency may deteriorate.

---

### Overall Business Takeaway

The analysis indicates that Maven Electronics' primary challenge is the substantial decline in revenue and profit after the 2019 peak. At the same time, the business remains strongly dependent on in-store sales, while customer, brand, product, and seasonal patterns provide opportunities for more targeted decision-making.

The findings suggest that management should prioritize **understanding the drivers of the revenue decline, strengthening online sales, protecting high-performing products and markets, planning around seasonal demand, and monitoring operational performance**.

---

## Management Recommendations

Based on the analysis, the following areas should be considered as management priorities.

### 1. Investigate the Drivers of the Revenue Decline

The 49.11% revenue decline between 2019 and 2020 is the most significant finding in the analysis.

Management should conduct a deeper review of:

- Product categories with the largest revenue declines
- Brands contributing most to the decline
- Countries or markets with weakening performance
- Changes in order volume
- Sales-channel performance

This would help identify whether the decline was driven primarily by specific products, markets, customer behavior, or sales channels.

### 2. Develop the Online Sales Channel

In-store revenue is approximately **$44M**, compared with approximately **$11M online**, while AOV is relatively similar between the two channels.

This suggests that the online channel may have an opportunity to increase revenue primarily through higher order volume.

Potential areas to investigate include:

- Digital marketing and customer acquisition
- Online product availability
- Promotions and offers
- Website or checkout experience
- Repeat-purchase strategies
- Online-exclusive campaigns

### 3. Prioritize High-Performing Products and Brands

The analysis identifies differences in revenue contribution across brands and product categories.

Management should:

- Protect inventory availability for high-performing products
- Monitor declining brands and categories
- Evaluate product-level revenue and profit together
- Investigate whether high-volume products generate sufficient profit
- Use product performance to support merchandising decisions

### 4. Focus on High-Value Markets

Customer and revenue analysis shows that performance varies across countries.

Management could prioritize markets based on:

- Revenue contribution
- Customer concentration
- Order volume
- Average order value
- Product demand
- Revenue and profit trends

This can help identify markets with strong existing performance as well as markets with potential for growth.

### 5. Plan Around Seasonal Demand

Revenue, order volume, and AOV peak in different months:

- February — highest revenue
- December — highest order volume
- April — highest AOV

Management should therefore avoid relying on a single seasonal indicator when planning inventory, staffing, promotions, and operational capacity.

### 6. Monitor Delivery Performance

The current average delivery time is approximately **4.53 days**.

Management should monitor delivery performance over time and investigate periods where delivery times increase, particularly during periods of high order activity.

Potential operational actions include:

- Monitoring delivery performance by month
- Identifying periods of capacity pressure
- Reviewing fulfillment processes
- Investigating delays by location or store
- Setting delivery-time targets for ongoing monitoring

### Recommended Next Step

The next stage of analysis should be a more detailed **driver analysis of the 2019–2020 revenue decline**. This could examine revenue change by product category, brand, country, sales channel, and customer segment to identify the specific contributors to the downturn.

> **Note:** These recommendations are data-informed areas for further investigation rather than confirmed causal explanations. The dashboard identifies patterns and relationships, but additional analysis would be required to establish the underlying causes of the revenue decline.
>
---

## Project Workflow / Methodology

The project followed a structured analytics workflow designed to move from raw source data to a business-ready interactive report.

### Phase 1 — Data Preparation

The raw CSV files were imported into PostgreSQL staging tables.

Key activities included:

- Loading the source datasets
- Reviewing table structures
- Checking row counts and column definitions
- Identifying import and encoding issues
- Preserving the raw staging layer for validation

**Output:** Raw datasets available in PostgreSQL staging.

---

### Phase 2 — Data Profiling & Cleaning

The imported data was profiled to identify data-quality issues and inconsistencies.

Key activities included:

- Checking missing and null values
- Identifying duplicates
- Validating data types
- Reviewing date ranges
- Checking key uniqueness
- Reviewing table grain
- Identifying invalid or unexpected values
- Standardizing dates
- Cleaning text-based numeric fields
- Converting fields to appropriate data types

**Output:** Cleaned and validated data suitable for modeling.

---

### Phase 3 — Data Modeling

A relational warehouse structure was developed using fact and dimension tables.

Key activities included:

- Creating `fact_sales`
- Creating customer, product, store, exchange-rate, and date dimensions
- Establishing primary and foreign-key relationships
- Separating transactional data from descriptive attributes
- Creating a star-schema structure for analytical reporting

**Output:** Warehouse-ready analytical data model.

---

### Phase 4 — Data Enrichment & Exploration

The warehouse data was connected to Power BI and enriched with calculated measures.

Key activities included:

- Creating revenue measures
- Creating order and customer measures
- Calculating Average Order Value
- Calculating Total Profit
- Calculating Revenue Decline %
- Calculating Average Delivery Days
- Building time-based calculations
- Exploring customer, product, brand, market, and sales-channel performance

**Output:** Business-ready analytical measures and datasets.

---

### Phase 5 — Interactive Report Development

An interactive five-page Power BI report was developed around the business problem.

The report covers:

1. **Sales Performance**
2. **Revenue & Profit Performance**
3. **Customer & Product Insights**
4. **Trends & Operations**
5. **Executive Insights**

Interactive filtering was implemented using the Date dimension, including Year-based filtering and time-based analysis.

**Output:** Interactive Power BI business intelligence report.

---

### Phase 6 — Validation & Business Interpretation

The final report was reviewed to ensure that the metrics, visuals, filters, and business questions were aligned.

Validation included:

- Checking KPI calculations
- Verifying DAX measures
- Confirming month sorting
- Checking visual interactions
- Reviewing number formatting
- Validating chart fields and axes
- Checking for unnecessary duplication
- Mapping report pages to business questions
- Reviewing insights against the underlying data

The final findings were then translated into management-focused insights and recommendations.

**Output:** Validated Power BI report with business insights and management priorities.

---

## Conclusion

This project transformed raw global retail data into a structured, interactive business intelligence report using PostgreSQL and Power BI.

The analysis identified a significant decline in Maven Electronics' revenue and profit after the 2019 peak, while also highlighting differences across sales channels, customers, products, brands, markets, seasonal periods, and delivery performance.

The final report moves beyond descriptive reporting by connecting analytical findings to management priorities, including investigating the revenue decline, strengthening online sales, focusing on high-performing products and markets, planning around seasonal demand, and monitoring delivery performance.

Overall, the project demonstrates an end-to-end analytics workflow covering **data preparation, profiling, relational data modeling, data enrichment, DAX-based analysis, interactive visualization, business interpretation, and management recommendations**.

## Future Improvements

The current analysis provides a strong foundation, but several areas could be explored further:

- Perform a detailed driver analysis of the 2019–2020 revenue decline.
- Analyze revenue and profit changes by individual product and brand.
- Investigate customer retention and repeat-purchase behavior.
- Analyze customer segments based on purchasing patterns and value.
- Compare delivery performance across countries, stores, and sales channels.
- Investigate whether seasonal patterns repeat consistently across multiple years.
- Develop forecasting models for future revenue and order volume.
- Add profitability analysis by product, category, country, and sales channel.
- Introduce additional operational KPIs such as delivery SLA compliance and delayed-order rate.

