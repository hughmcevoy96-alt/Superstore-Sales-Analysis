USE Superstore_db;
GO

-- Insert raw data into the staging raw_data table:


BULK INSERT raw_data
FROM 'C:\Users\hughm\OneDrive\Documents\Portfolio Projects\Superstore\Superstore.txt'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '0x0a',
	TABLOCK
);


-- Populate dimension tables using the staging table:


--Product table


INSERT INTO dProduct (
	Product_ID,
	Product_Name,
	Category,
	Sub_Category
)
SELECT DISTINCT
	Product_ID,
	MIN(Product_Name), -- raw data was slightly inconsistent with different product names, only need one.
	MIN(Category),
	MIN(Sub_Category)
FROM raw_data
GROUP BY Product_ID;

UPDATE dProduct
SET Product_Name = SUBSTRING(Product_Name, 2, LEN(Product_Name) - 2)
WHERE Product_Name LIKE '"%' AND Product_Name LIKE '%"';

-- Customer table


INSERT INTO dCustomer (
	Customer_ID,
	First_Name,
	Last_Name,
	Segment
)
SELECT DISTINCT
	Customer_ID,
	SUBSTRING(Customer_Name, 1, CHARINDEX(' ', Customer_Name + ' ') - 1), -- + ' ' prevents CHARINDEX returning 0, in the case that a name has no space.
	SUBSTRING(Customer_Name, LEN(Customer_Name) - CHARINDEX(' ', REVERSE(Customer_Name)) + 2, LEN(Customer_Name)),
	Segment
FROM raw_data;


-- Address table:


INSERT INTO dAddress (
	Country,
	City,
	Postal_Code,
	Region
)
SELECT DISTINCT
	Country,
	City,
	Postal_Code,
	Region
FROM raw_data;


-- Date table, requires the use of a recursive CTE:


DECLARE @StartDate DATE = '2014-01-01';
DECLARE @EndDate DATE = '2019-01-01';

WITH DateSeries AS (
	SELECT @StartDate AS Date -- Anchor member
	UNION ALL
	SELECT DATEADD(DAY, 1, Date) -- Recursive member
	FROM DateSeries
	WHERE Date < @EndDate
)
INSERT INTO dDate
SELECT
	CAST(FORMAT(CONVERT(DATE, Date), 'yyyyMMdd') AS INT) AS Date_Key,
	Date,
	DATENAME(MONTH, Date),
	MONTH(Date),
	DATEPART(QUARTER, Date),
	YEAR(Date)
FROM DateSeries
OPTION (MAXRECURSION 0); -- Allow infinite recursion


-- Populate fact table:


INSERT INTO fOrders (
	Order_ID,
	Product_Key,
	Customer_Key,
	Address_Key,
	Order_Date_Key,
	Ship_Date_Key,
	Ship_Mode,
	Quantity,
	Sales,
	Discount,
	Profit
)
SELECT
	r.Order_ID,
	p.Product_Key,
	c.Customer_Key,
	a.Address_Key,
	d1.Date_Key,
	d2.Date_Key,
	r.Ship_Mode,
	r.Quantity,
	r.Sales,
	r.Discount,
	r.Profit
FROM raw_data AS r
JOIN dDate AS d1
ON r.Order_Date = d1.Date
JOIN dDate AS d2
ON r.Ship_Date = d2.Date
JOIN dProduct AS p
ON r.Product_ID = p.Product_ID
JOIN dCustomer AS c
ON r.Customer_ID = c.Customer_ID
JOIN dAddress AS a
ON r.Country = a.Country AND r.City = a.City AND r.Postal_Code = a.Postal_Code AND r.Region = a.Region;