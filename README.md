# SQL & Business Analysis: Montgomery County Sales

## 1. Project Overview
This project is a comprehensive demonstration of advanced SQL and data analysis skills applied to a real-world retail dataset. The primary goal is to answer key business questions related to supplier performance, inventory management, and sales trends. The project showcases the end-to-end process of data modeling, ETL (Extract, Transform, Load), and advanced querying to derive actionable insights.

## 2. Dataset
*   **Source:** [Montgomery County Warehouse and Retail Sales on Kaggle](https://www.kaggle.com/datasets/samanfatima7/warehouse-and-retail-sales-montgomery-county)
*   **Description:** The dataset contains monthly liquor sales and transfers from Montgomery County, Maryland. The raw CSV file (`Warehouse_and_Retail_Sales.csv`) is included in the `/data` folder of this repository for full reproducibility.

## 3. Methodology & Technical Implementation

### a. Data Modeling: Star Schema
To optimize for analytical queries and scalability, the original flat-file data was transformed into a **Star Schema**. This industry-standard model consists of a central fact table (`Fact_Sales`) and two descriptive dimension tables (`Dim_Item`, `Dim_Date`). This approach reduces data redundancy, improves query performance, and creates an intuitive structure for business intelligence.

### b. ETL Process
The ETL (Extract, Transform, Load) pipeline was executed entirely in SQL to ensure transparency and reproducibility:
1.  **Extract:** Raw data was loaded from the provided CSV into a staging table (`stg_sales`) using MySQL Workbench's import wizard.
2.  **Transform:** The data was cleaned and standardized using SQL functions like `TRIM()` and `UPPER()`. `NULL` values in numeric columns were handled with `COALESCE()`. The data was also enriched with a new `Sales_Category` column using a `CASE` statement to enable higher-level analysis.
3.  **Load:** The cleaned, transformed data was loaded from the staging table into the final Star Schema tables.

### c. Tools Used
*   **Database:** MySQL Server 8.0
*   **IDE:** MySQL Workbench 8.0 CE
*   **SQL:** Advanced functions including CTEs (Common Table Expressions), Window Functions (`LAG`, `LEAD`, `RANK`), Date/Time Functions, Conditional Aggregation, and Self-Joins.

## 4. Business Questions & Analytical Insights

This analysis answered five key business questions, with the following insights:

### Q1: Supplier Performance & Profitability
*   **Question:** Which suppliers provide our top 10 most sold items, and what is their month-over-month sales growth?
*   **Insight:**
The month-over-month analysis for July 2020 highlights a dynamic market with clear winners and losers among top-selling products. The standout performer was the 'ICE' product, which saw an extraordinary MoM growth of 388%. 'Tito's Handmade Vodka' also demonstrated strong momentum with a 74% increase in sales. Conversely, several major beer brands faced headwinds, with 'Heineken' and 'Yuengling Lager' experiencing sales declines of -20% and -32% respectively. A key finding is the divergence within Miller Brewing Company's products: while their loose bottle sales fell by 33%, their 30-pack can sales grew by 73%, signaling a strong consumer shift towards bulk packaging.

### Q2: Sales Velocity & Inventory Pacing
*   **Question:** What is the average number of days between sales transactions for our 20 fastest-selling items?
*   **Insight:**
The sales velocity analysis successfully categorized our top-selling items into distinct reordering tiers based on their average sales frequency. The data reveals two primary groups: a faster-moving tier of products like 'Corona Extra Loose' and 'Heineken', which record a sale approximately every 91 days (quarterly), and a second tier including high-performers like 'Tito's Handmade Vodka' and 'Bud Light 30pk Can', which sell on average every 182 days (semi-annually).
It is critical to note that these figures are a direct reflection of the dataset's monthly granularity. The query correctly identifies the frequency of sales months, providing a strategic, high-level view of sales pacing. This insight is immediately actionable for inventory management: the "91-day" products require more frequent stock level reviews than the "182-day" products to optimize cash flow and prevent both overstocking and stockouts.

### Q3: Category Performance Ranking
*   **Question:** How did the sales of 'WINE' and 'LIQUOR' rank against each other on a weekly basis throughout the last full year?
*   **Insight:** The weekly sales analysis for the year 2020 reveals a strong seasonal trend, with sales performance heavily concentrated around major public holidays. The top-performing week of the year was 2020-27, which corresponds to the July 4th holiday period, generating over $122k in combined sales. The second-highest sales week was 2020-01, driven by New Year's celebrations, with over $109k in sales. 
In terms of category performance, Liquor consistently outpaced Wine sales during these peak periods, confirming its role as the primary revenue driver. This analysis underscores the critical importance of holiday-focused inventory planning and marketing, as the top two weeks represent a significant portion of sales volume. The data provides a clear, actionable roadmap for allocating resources to capitalize on these predictable, high-impact sales windows.`

### Q4: Product Association Analysis
*   **Question:** Within the 'WINE' category, which items are most frequently sold together?
*   **Insight:**
The product association analysis revealed a dominant and highly actionable pattern within the wine category. The product 'BAREFOOT REFRESH CRISP WHITE - CAN- 250ML' from E & J GALLO WINERY emerged as a central 'hub' product. It was consistently sold together with a wide variety of other wines—including different brands and types like Barefoot, Alamos, and Allegrini—in all 12 months of the year.
This powerful insight suggests that the canned, single-serving format of the 'Barefoot Refresh' acts as a popular 'basket-builder' or add-on item. Customers purchasing standard 750ml or 1.5L bottles are frequently adding this convenient product to their purchase. This presents a clear strategic opportunity for targeted marketing, such as bundling promotions or point-of-sale displays, to further drive incremental sales and increase the average transaction value for the entire E & J Gallo wine portfolio.

### Q5: Dead Stock Identification
*   **Question:** Which items have not been sold in the last 12 months but have been transferred to retail?
*   **Insight:** 
The dead stock analysis provided critical, actionable intelligence by identifying a substantial 982 distinct items that generated zero retail sales over the last 12 months, despite being actively transferred to stores. This finding points to a significant operational inefficiency in the supply chain, likely stemming from forecasting inaccuracies or a misalignment between purchasing decisions and actual consumer demand.

## 5. Repository Structure
The repository is organized for clarity and ease of use:
```
/
├── data/
│   └── Warehouse_and_Retail_Sales.csv
├── sql_scripts/
│   ├── 01_schema_and_tables.sql
│   ├── 02_etl_and_cleaning.sql
│   └── 03_business_analysis.sql
└── README.md
```

## 6. How to Use
1.  Clone or download this repository.
2.  Set up a MySQL Server and connect to it with MySQL Workbench.
3.  Run the script in `/sql_scripts/01_schema_and_tables.sql` to create the database schema.
4.  In MySQL Workbench, right-click the `stg_sales` table and select the "Table Data Import Wizard". Use the `Warehouse_and_Retail_Sales.csv` file located in the `/data` folder as the source.
5.  Execute `/sql_scripts/02_etl_and_cleaning.sql` to perform the ETL process.
6.  Run the queries in `/sql_scripts/03_business_analysis.sql` to replicate the analysis.
