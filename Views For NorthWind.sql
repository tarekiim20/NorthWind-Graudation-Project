--Views--

--1.Undelivered Orders
Create View UnDeliveredOrders
as
select OrderID, CustomerID,CompanyName as ShipCompany, OrderDate, RequiredDate, ShipCountry
FROM Orders  O, Shippers S
WHERE DeliveredDate IS NULL    --or ShippedDate?
and S.ShipperID = O.ShipVia
ORDER BY RequiredDate ASC;
--____________________________________________________

--2.Avg Freight for Country
Create View CountryAvgFright
as
SELECT S.CompanyName AS ShipperName,  
       COUNT(O.OrderID) AS TotalOrders,  
       AVG(O.Freight) AS AvgFreightCost  
FROM Orders O ,Shippers S 
where O.ShipVia = S.ShipperID  
GROUP BY S.CompanyName  
--________________________________________________________

--3.Avg days for Delivered
Create view AVGDeliveredDays
as
select shipcountry, AVG(DATEDIFF(day, OrderDate, DeliveredDate)) as AVGDeliveredDays

from orders
where DeliveredDate is not null
group by ShipCountry
--______________________________________________________________

--4.Best-Selling Products
Alter VIEW BestSellingProducts AS
SELECT TOP 10 *
FROM (SELECT P.ProductName, SUM(OD.Quantity) AS SumOfQuantity
	  FROM Products P,OrderDetails OD
	  where P.ProductID = OD.ProductID
      GROUP BY P.ProductName
) AS Subquery
ORDER BY SumOfQuantity DESC;

Select * from  BestSellingProducts
--________________________________________________________
--5.TopRevenueProducts

CREATE VIEW TopRevenueProducts
AS
select top 10 *
from(
SELECT p.ProductID,p.ProductName,c.CategoryName,
SUM(od.Quantity) AS TotalQuantitySold,
SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalRevenue
FROM OrderDetails od, Products p ,Categories c
where od.ProductID = p.ProductID and p.CategoryID = c.CategoryID
GROUP BY p.ProductID, p.ProductName, c.CategoryName) as subquery
ORDER BY TotalRevenue desc

--______________________________________________________________________
--6. TopCityRevenue
Create View TopCityRevenue
as
WITH CityRevenue AS (
    SELECT 
        c.Country,
        c.City,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalRevenue,
        RANK() OVER (PARTITION BY c.Country ORDER BY SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) DESC) AS RevenueRank
    FROM Customers c
    JOIN Orders o ON c.CustomerID = o.CustomerID
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    GROUP BY c.Country, c.City
)
SELECT Country, City, TotalRevenue
FROM CityRevenue
WHERE RevenueRank = 1;