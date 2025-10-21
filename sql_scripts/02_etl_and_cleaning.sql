-- ETL Process

INSERT INTO Dim_Date (DateID, Full_Date, `Year`, `Month`, `Quarter`)
SELECT DISTINCT
(`YEAR` * 100) + `MONTH` AS DateID,
STR_TO_DATE(CONCAT(`YEAR`, '-', `MONTH`, '-01'), '%Y-%m-%d') AS Full_Date,
`YEAR`,
`MONTH`,
QUARTER(STR_TO_DATE(CONCAT(`YEAR`, '-', `MONTH`, '-01'), '%Y-%m-%d')) AS `Quarter`
FROM stg_sales
ORDER BY DateID;

INSERT INTO Dim_Item (Item_Code, Item_Description, Item_Type, Supplier_Name, Sales_Category)
SELECT DISTINCT
TRIM(`ITEM CODE`) AS Item_Code,
TRIM(`ITEM DESCRIPTION`) AS Item_Type,
UPPER(TRIM(`ITEM TYPE`)) AS Item_Type,
TRIM(`SUPPLIER`) AS Supplier_Name,
CASE
	WHEN UPPER(TRIM(`ITEM TYPE`)) = 'WINE' THEN 'Wine Products'
    WHEN UPPER(TRIM(`ITEM TYPE`)) = 'LIQUOR' THEN 'Liquor Products'
    ELSE 'Other Beverages'
END AS Sales_Category
FROM stg_sales;

INSERT INTO Fact_Sales (DateID, ItemID, Retail_Sales, Retail_Transfers, Warehouse_Sales)
SELECT
d.DateID,
i.ItemID,
COALESCE(CAST(s.`RETAIL SALES` AS SIGNED), 0),
COALESCE(CAST(s.`RETAIL TRANSFERS` AS SIGNED), 0),
COALESCE(CAST(s.`WAREHOUSE SALES` AS SIGNED), 0)
FROM stg_sales s
JOIN Dim_Date d ON (s.`YEAR` * 100 + s.`MONTH`) = d.DateID
JOIN Dim_Item i ON TRIM(s.`ITEM CODE`) = i.Item_Code AND TRIM(s.`SUPPLIER`) = i.Supplier_Name;
