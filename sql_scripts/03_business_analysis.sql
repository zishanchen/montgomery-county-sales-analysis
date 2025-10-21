-- Analysis

-- 1. Which suppliers provide our top 10 most sold items, and what is their month-over-month sales growth?

WITH MonthlySales AS (
SELECT
i.Supplier_Name,
i.Item_Description,
d.Full_Date,
SUM(fs.Retail_Sales) AS Current_Month_Sales
FROM Fact_Sales fs
JOIN Dim_Item i ON fs.ItemID = i.ItemID
JOIN Dim_Date d ON fs.DateID = d.DateID
GROUP BY i.Supplier_Name, i.Item_Description, d.Full_Date
),
SalesWithLag AS (
SELECT
Supplier_Name,
Item_Description,
Full_Date,
Current_Month_Sales,
LAG(Current_Month_Sales, 1, 0) OVER (PARTITION BY Supplier_Name, Item_Description ORDER BY Full_Date) AS Previous_Month_Sales
FROM MonthlySales
),
Top10Items AS (
SELECT
i.Item_Description
FROM Fact_Sales fs
JOIN Dim_Item i ON fs.ItemID = i.ItemID
GROUP BY i.Item_Description
ORDER BY SUM(fs.Retail_Sales) DESC
LIMIT 10
)
SELECT
swl.Supplier_Name,
swl.Item_Description,
swl.Full_Date,
swl.Current_Month_Sales,
swl.Previous_Month_Sales,
CASE
	WHEN swl.Previous_Month_Sales > 0 THEN
		ROUND(((swl.Current_Month_Sales - swl.Previous_Month_Sales) / swl.Previous_Month_Sales) * 100.0, 2)
	ELSE
		0
END AS MoM_Growth_Percentage
FROM SalesWithLag swl
JOIN Top10Items t10 ON swl.Item_Description = t10.Item_Description
WHERE swl.Full_Date >= DATE_SUB((SELECT MAX(Full_Date) FROM Dim_Date), INTERVAL 5 MONTH)
ORDER BY swl.Supplier_Name, swl.Item_Description, swl.Full_Date DESC;

-- 2. What is the average number of days between sales transactions for our 20 fastest-selling items (by total RETAIL SALES quantity)?

WITH Top20Items AS (
SELECT
ItemID
FROM Fact_Sales
GROUP BY ItemID
ORDER BY SUM(Retail_Sales) DESC
LIMIT 20
),
TransactionDates AS (
SELECT
fs.ItemID,
d.Full_Date
FROM Fact_Sales fs
JOIN Dim_Date d ON fs.DateID = d.DateID
JOIN Top20Items t20 ON fs.ItemID = t20.ItemID
WHERE fs.Retail_Sales > 0
GROUP BY fs.ItemID, d.Full_Date
),
DaysBetweenSales AS (
SELECT
ItemID,
Full_Date,
LEAD(Full_Date, 1) OVER (PARTITION BY ItemID ORDER BY Full_Date) AS Next_Sale_Date
FROM TransactionDates
)
SELECT
di.Item_Description,
di.Supplier_Name,
ROUND (AVG(DATEDIFF(dbs.Next_Sale_Date, dbs.Full_Date)), 2) AS Average_Days_Between_Sales
FROM DaysBetweenSales dbs
JOIN Dim_Item di ON dbs.ItemID = di.ItemID
WHERE dbs.Next_Sale_Date IS NOT NULL
GROUP BY di.Item_Description, di.Supplier_Name
ORDER BY Average_Days_Between_Sales ASC;

-- 3. How did the sales of 'WINE' and 'LIQUOR' rank against each other on a weekly basis throughout the last full year in the dataset?

WITH WeeklyCategorySales AS (
SELECT
DATE_FORMAT(d.Full_Date, '%x-%v') AS Sales_Week,
SUM(CASE WHEN i.Item_Type = 'WINE' THEN fs.Retail_Sales ELSE 0 END) AS Wine_Sales,
SUM(CASE WHEN i.Item_Type = 'LIQUOR' THEN fs.Retail_Sales ELSE 0 END) AS Liquor_Sales,
SUM(fs.Retail_Sales) AS Total_Weekly_Sales
FROM Fact_Sales fs
JOIN Dim_Item i ON fs.ItemID = i.ItemID
JOIN Dim_Date d ON fs.DateID = d.DateID
WHERE
	i.Item_Type IN ('WINE', 'LIQUOR')
	AND d.`Year` = (SELECT MAX(`Year`) FROM Dim_Date)
	GROUP BY Sales_Week
),
RankedWeeklySales AS (
    SELECT
        Sales_Week,
        Wine_Sales,
        Liquor_Sales,
        Total_Weekly_Sales,
        RANK() OVER (ORDER BY Total_Weekly_Sales DESC) as Sales_Rank
    FROM WeeklyCategorySales
)
SELECT
    Sales_Week,
    Wine_Sales,
    Liquor_Sales,
    Total_Weekly_Sales,
    Sales_Rank,
    CASE
        WHEN Sales_Rank <= 3 THEN 'Top 3 Week'
        ELSE 'Regular Week'
    END AS Performance_Flag
FROM RankedWeeklySales
ORDER BY Sales_Rank ASC;

/* 4. Within the 'WINE' category, which items are most frequently sold together 
(i.e., appear in sales records on the same YEAR and MONTH for the same SUPPLIER)? */

WITH WineSales AS (
SELECT DISTINCT
fs.DateID,
i.Supplier_Name,
fs.ItemID
FROM Fact_Sales fs
JOIN Dim_Item i ON fs.ItemID = i.ItemID
WHERE i.Item_Type = 'WINE'
AND fs.Retail_Sales > 0
)
SELECT
item1_details.Item_Description AS Item_1,
item2_details.Item_Description AS Item_2,
item1_details.Supplier_Name,
COUNT(*) AS Times_Sold_Together
FROM WineSales item1
JOIN WineSales item2 ON item1.DateID = item2.DateID
AND item1.Supplier_Name = item2.Supplier_Name
AND item1.ItemID < item2.ItemID
JOIN Dim_Item item1_details ON item1.ItemID = item1_details.ItemID
JOIN Dim_Item item2_details ON item2.ItemID = item2_details.ItemID
GROUP BY Item_1, Item_2, item1_details.Supplier_Name
ORDER BY Times_Sold_Together DESC
LIMIT 20;

/* 5. Which items have not appeared in RETAIL SALES in the last 12 months of available data but have been transferred to retail (RETAIL TRANSFERS > 0) during that same period, 
suggesting they are sitting unsold in stores? */

WITH Last12MonthsActivity AS (
SELECT
fs.ItemID,
SUM(fs.Retail_Sales) AS Total_Retail_Sales,
SUM(fs.Retail_Transfers) AS Total_Retail_Transfers
FROM Fact_Sales fs
JOIN Dim_Date d ON fs.DateID = d.DateID
WHERE d.Full_Date >= DATE_SUB((SELECT MAX(Full_Date) FROM Dim_Date), INTERVAL 11 MONTH)
GROUP BY fs.ItemID
)
SELECT
di.Item_Code,
di.Item_Description,
di.Supplier_Name,
di.Item_Type,
l12m.Total_Retail_Sales,
l12m.Total_Retail_Transfers
FROM Last12MonthsActivity l12m
JOIN Dim_Item di ON l12m.ItemID = di.ItemID
WHERE
l12m.Total_Retail_Sales = 0
AND l12m.Total_Retail_Transfers > 0
ORDER BY l12m.Total_Retail_Transfers DESC;
