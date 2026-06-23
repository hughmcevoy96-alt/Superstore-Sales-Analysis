USE Superstore_db;
GO


-- Create staging table to store the raw data:


CREATE TABLE raw_data (
	Row_ID INT,
	Order_ID VARCHAR(255),
	Order_Date DATE,
	Ship_Date DATE,
	Ship_Mode VARCHAR(255),
	Customer_ID VARCHAR(255),
	Customer_Name VARCHAR(255),
	Segment VARCHAR(255),
	Country VARCHAR(255),
	City VARCHAR(255),
	State VARCHAR(255),
	Postal_Code INT,
	Region VARCHAR(255),
	Product_ID VARCHAR(255),
	Category VARCHAR(255),
	Sub_Category VARCHAR(255),
	Product_Name VARCHAR(255),
	Sales DECIMAL(20,5),
	Quantity INT,
	Discount DECIMAL(20,5),
	Profit DECIMAL(20,5)
);


-- Create Dimension Tables:


CREATE TABLE dDate (
	Date_Key INT PRIMARY KEY,
	Date DATE,
	Month_Name VARCHAR(20),
	Month_Number INT,
	Quarter_Number INT,
	Year_Number INT
);


CREATE TABLE dProduct (
	Product_Key INT IDENTITY(1,1) PRIMARY KEY,
	Product_ID VARCHAR(255),
	Product_Name VARCHAR(255),
	Category VARCHAR(255),
	Sub_Category VARCHAR(255)
);


CREATE TABLE dCustomer (
	Customer_Key INT IDENTITY(1,1) PRIMARY KEY,
	Customer_ID VARCHAR(255),
	First_Name VARCHAR(255),
	Last_Name VARCHAR(255),
	Segment VARCHAR(255)
);


CREATE TABLE dAddress (
	Address_Key INT IDENTITY(1,1) PRIMARY KEY,
	Country VARCHAR(255),
	City VARCHAR(255),
	Postal_Code INT,
	Region VARCHAR(255),
	State_Province VARCHAR(255)
);


-- Create Fact Table:


CREATE TABLE fOrders (
	Row_Key INT IDENTITY(1,1) PRIMARY KEY,
	Order_ID VARCHAR(255),
	Product_Key INT,
	Customer_Key INT,
	Address_Key INT,
	Order_Date_Key INT,
	Ship_Date_Key INT,
	Ship_Mode VARCHAR(255),
	Quantity INT,
	Sales DECIMAL(20,2),
	Discount DECIMAL(20,5),
	Profit DECIMAL(20,2),

	CONSTRAINT fk_Product_Key FOREIGN KEY (Product_Key) REFERENCES dProduct(Product_Key),
	CONSTRAINT fk_Customer_Key FOREIGN KEY (Customer_Key) REFERENCES dCustomer(Customer_Key),
	CONSTRAINT fk_Address_Key FOREIGN KEY (Address_Key) REFERENCES dAddress(Address_Key),
	CONSTRAINT fk_Order_Date_Key FOREIGN KEY (Order_Date_Key) REFERENCES dDate(Date_Key),
	CONSTRAINT fk_Ship_Date_Key FOREIGN KEY (Ship_Date_Key) REFERENCES dDate(Date_Key)
);