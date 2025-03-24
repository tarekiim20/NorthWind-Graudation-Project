USE NorthWind_Master;
GO

-- 1. Current Products
CREATE VIEW vw_CurrentProducts
AS
SELECT 
    p.ProductID,
    p.ProductName,
    p.UnitPrice,
    p.UnitsInStock,
    p.UnitsOnOrder,
    c.CategoryName,
    s.CompanyName AS SupplierName
FROM
	Products p
INNER JOIN
	Categories c
ON 
	p.CategoryID = c.CategoryID
INNER JOIN
	Suppliers s 
ON 
	p.SupplierID = s.SupplierID
WHERE p.Discontinued = 0;
GO

-- 2. Most Ordered Products
CREATE VIEW vw_MostOrderedProducts
AS
SELECT 
    p.ProductID,
    p.ProductName,
    SUM(od.Quantity) AS TotalQuantityOrdered,
    COUNT(DISTINCT o.OrderID) AS NumberOfOrders,
    p.UnitPrice,
    c.CategoryName
FROM 
	Products p
INNER JOIN
	[Order Details] od 
ON 
	p.ProductID = od.ProductID
INNER JOIN
	Orders o 
ON
	od.OrderID = o.OrderID
INNER JOIN
	Categories c 
ON 
	p.CategoryID = c.CategoryID
GROUP BY
	p.ProductID, p.ProductName, p.UnitPrice, c.CategoryName;
GO

-- 3. Inventory Status
CREATE VIEW vw_InventoryStatus
AS
SELECT 
    p.ProductID,
    p.ProductName,
    p.UnitsInStock,
    p.UnitsOnOrder,
    p.ReorderLevel,
    CASE 
        WHEN p.UnitsInStock < 10 THEN 'Critical'
        WHEN p.UnitsInStock <= p.ReorderLevel THEN 'Low'
        ELSE 'Sufficient'
    END AS StockStatus,
    p.Discontinued
FROM
	Products p;
GO

-- 4. Customer Order Summary
CREATE VIEW vw_CustomerOrderSummary
AS
SELECT 
    c.CustomerID,
    c.CompanyName,
    COUNT(o.OrderID) AS TotalOrders,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSpent,
    MAX(o.OrderDate) AS LastOrderDate
FROM
	Customers c
LEFT JOIN
	Orders o 
ON
	c.CustomerID = o.CustomerID
LEFT JOIN
	[Order Details] od 
ON
	o.OrderID = od.OrderID
GROUP BY
	c.CustomerID, c.CompanyName;
GO

-- 5. Employee Sales Performance
CREATE VIEW vw_EmployeeSalesPerformance
AS
SELECT 
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    COUNT(o.OrderID) AS TotalOrders,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales,
    YEAR(o.OrderDate) AS SalesYear
FROM
	Employees e
INNER JOIN
	Orders o 
ON
	e.EmployeeID = o.EmployeeID
INNER JOIN
	[Order Details] od 
ON
	o.OrderID = od.OrderID
GROUP BY e.EmployeeID, e.FirstName, e.LastName, YEAR(o.OrderDate);
GO

-- 6. Order Details with Totals
CREATE VIEW vw_OrderDetailsWithTotals
AS
SELECT 
    o.OrderID,
    o.OrderDate,
    o.CustomerID,
    c.CompanyName AS CustomerName,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    p.ProductID,
    p.ProductName,
    od.UnitPrice,
    od.Quantity,
    od.Discount,
    (od.UnitPrice * od.Quantity * (1 - od.Discount)) AS LineTotal
FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
INNER JOIN Employees e ON o.EmployeeID = e.EmployeeID
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID;
GO

-- 7. Supplier Inventory Contribution
CREATE VIEW vw_SupplierInventoryContribution
AS
SELECT 
    s.SupplierID,
    s.CompanyName AS SupplierName,
    COUNT(p.ProductID) AS TotalProducts,
    SUM(p.UnitsInStock) AS TotalUnitsInStock,
    SUM(p.UnitsOnOrder) AS TotalUnitsOnOrder
FROM Suppliers s
LEFT JOIN Products p ON s.SupplierID = p.SupplierID
GROUP BY s.SupplierID, s.CompanyName;
GO

-- 8. Invoices
CREATE VIEW vw_AllInvoices
AS
SELECT 
    o.OrderID AS InvoiceID,
    o.OrderDate,
    o.ShippedDate,
    o.CustomerID,
    c.CompanyName AS CustomerName,
    c.ContactName,
    c.City AS CustomerCity,
    c.PostalCode AS CustomerPostalCode,
    c.Country AS CustomerCountry,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    s.CompanyName AS ShipperName,
    p.ProductID,
    p.ProductName,
    od.UnitPrice,
    od.Quantity,
    od.Discount,
    (od.UnitPrice * od.Quantity * (1 - od.Discount)) AS LineTotal,
    o.Freight AS ShippingCost,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) OVER (PARTITION BY o.OrderID) AS Subtotal,
    (SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) OVER (PARTITION BY o.OrderID) + o.Freight) AS InvoiceTotal
FROM 
	Orders o
INNER JOIN 
	Customers c 
ON
	o.CustomerID = c.CustomerID
INNER JOIN
	Employees e
ON
	o.EmployeeID = e.EmployeeID
INNER JOIN 
	Shippers s 
ON
	o.ShipVia = s.ShipperID
INNER JOIN
	[Order Details] od 
ON
	o.OrderID = od.OrderID
INNER JOIN 
	ProductS p 
ON 
	od.ProductID = p.ProductID;
GO