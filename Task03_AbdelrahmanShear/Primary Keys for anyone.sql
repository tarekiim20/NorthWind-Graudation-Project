use NorthWind

ALTER TABLE NorthWind.dbo.Categories
ALTER COLUMN categoryid INT NOT NULL;
GO
ALTER TABLE NorthWind.dbo.Categories
ADD CONSTRAINT Categories_PK PRIMARY KEY  (categoryid);

ALTER TABLE NorthWind.dbo.Customers
ALTER COLUMN customerid VARCHAR(50) NOT NULL;
GO
ALTER TABLE NorthWind.dbo.Customers
ADD CONSTRAINT Customer_PK PRIMARY KEY  (customerid);


ALTER TABLE NorthWind.dbo.Employees
ALTER COLUMN employeeid INT NOT NULL;
GO
ALTER TABLE NorthWind.dbo.Employees
ADD CONSTRAINT Employees_PK PRIMARY KEY  (employeeid);



ALTER TABLE NorthWind.dbo.EmployeeTerritories
ALTER COLUMN employeeid INT NOT NULL;
GO
ALTER TABLE NorthWind.dbo.EmployeeTerritories
ALTER COLUMN territoryid INT NOT NULL;
GO
ALTER TABLE NorthWind.dbo.EmployeeTerritories
ADD CONSTRAINT EmployeeTerritories_PK PRIMARY KEY  (employeeid, territoryid);



ALTER TABLE NorthWind.dbo.Orders
ALTER COLUMN OrderID INT NOT NULL;
GO
ALTER TABLE NorthWind.dbo.Orders
ADD CONSTRAINT Orders_PK PRIMARY KEY  (OrderID);


ALTER TABLE NorthWind.dbo.Products
ALTER COLUMN productid INT NOT NULL;
GO
ALTER TABLE NorthWind.dbo.Products
ADD CONSTRAINT Products_PK PRIMARY KEY  (productid);


ALTER TABLE NorthWind.dbo.Regions
ALTER COLUMN regionid INT NOT NULL;
GO
ALTER TABLE NorthWind.dbo.Regions
ADD CONSTRAINT Regions_PK PRIMARY KEY  (regionid);


ALTER TABLE NorthWind.dbo.Shippers
ALTER COLUMN shipperid INT NOT NULL;
GO
ALTER TABLE NorthWind.dbo.Shippers
ADD CONSTRAINT Shippers_PK PRIMARY KEY  (shipperid);


ALTER TABLE NorthWind.dbo.Suppliers
ALTER COLUMN supplierid INT NOT NULL;
GO
ALTER TABLE NorthWind.dbo.Suppliers
ADD CONSTRAINT Suppliers_PK PRIMARY KEY  (supplierid);


ALTER TABLE NorthWind.dbo.Territories
ALTER COLUMN territoryid INT NOT NULL;
GO
ALTER TABLE NorthWind.dbo.Territories
ADD CONSTRAINT Territories_PK PRIMARY KEY  (territoryid);


ALTER TABLE NorthWind.dbo.OrderDetails
ALTER COLUMN OrderID INT NOT NULL;
GO
ALTER TABLE NorthWind.dbo.OrderDetails
ALTER COLUMN ProductID INT NOT NULL;
GO
ALTER TABLE NorthWind.dbo.OrderDetails
ADD CONSTRAINT OrderDetails_PK PRIMARY KEY  (OrderID, ProductID);


ALTER TABLE Orders
ALTER COLUMN EmployeeID INT 

ALTER TABLE Orders
ALTER COLUMN ShipVia INT 

ALTER TABLE Orders
ALTER COLUMN OrderDate Date 

ALTER TABLE Orders
ALTER COLUMN ShipDate Date 

ALTER TABLE Orders
ALTER COLUMN RequiredDate Date

ALTER TABLE Orders
ALTER COLUMN DeliveredDate Date


ALTER TABLE Orders
ALTER COLUMN Freight Float