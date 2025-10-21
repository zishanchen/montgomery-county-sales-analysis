CREATE TABLE `stg_sales` (
 `YEAR` INT,
 `MONTH` INT,
 `SUPPLIER` VARCHAR(255),
 `ITEM CODE` VARCHAR(50),
 `ITEM DESCRIPTION` VARCHAR(255),
 `ITEM TYPE` VARCHAR(50),
 `RETAIL SALES` DECIMAL(10, 2),
 `RETAIL TRANSFERS` DECIMAL(10, 2),
 `WAREHOUSE SALES` DECIMAL(10,2)
 );
 
 SELECT *
 FROM stg_sales
 LIMIT 10;
 
 -- Dimension Table for Data
CREATE TABLE `Dim_Date` (
`DateID` INT PRIMARY KEY,
`Full_Date` DATE NOT NULL,
`Year` INT NOT NULL,
`Month` INT NOT NULL,
`Quarter` INT NOT NULL
);

-- Dimension Table for Items and Suppliers
CREATE TABLE `Dim_Item` (
`ItemID` INT AUTO_INCREMENT PRIMARY KEY,
`Item_Code` VARCHAR(50) NOT NULL,
`Item_Description` VARCHAR(255),
`Item_Type` VARCHAR(50),
`Supplier_Name` VARCHAR(255),
`Sales_Category` VARCHAR(50)
);

-- Fact Table for Sales Metrics
CREATE TABLE `Fact_Sales` (
`SalesID` INT AUTO_INCREMENT PRIMARY KEY,
`DateID` INT,
`ItemID` INT,
`Retail_Sales` INT,
`Retail_Transfers` INT,
`Warehouse_Sales` INT,
FOREIGN KEY (`DateID`) REFERENCES `Dim_Date` (`DateID`),
FOREIGN KEY (`ItemID`) REFERENCES `Dim_Item` (`ItemID`)
);