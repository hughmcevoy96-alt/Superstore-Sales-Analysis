USE Superstore_db;
GO


-- Creating an example analytics view to be used in a BI tool:


CREATE VIEW vw_Superstore_Analytics AS
SELECT
	p.Product_Name,
	o.Quantity,
	o.Sales AS Total_Sales,
	o.Profit AS Total_Profit,
	p.Category,
	p.Sub_Category,
	c.Segment,
	a.Country,
	a.City,
	a.Postal_Code,
	a.Region,
	a.State,
	d1.Date AS Order_Date,
	d2.Date AS Ship_Date,
	o.Ship_Mode,
	DATEDIFF(DAY, d1.Date, d2.Date) AS Days_to_Ship
FROM fOrders AS o
LEFT JOIN dProduct AS p
ON o.Product_Key = p.Product_Key
LEFT JOIN dCustomer AS c
ON o.Customer_Key = c.Customer_Key
LEFT JOIN dAddress AS a
ON o.Address_Key = a.Address_Key
LEFT JOIN dDate AS d1
ON o.Order_Date_Key = d1.Date_Key
LEFT JOIN dDate AS d2
ON o.Ship_Date_Key = d2.Date_Key;