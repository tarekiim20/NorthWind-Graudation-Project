--Stored Procedures--
--1.Get Orders for a Customer

Create Proc CustomerOrders
@CustomerID varchar(50)
as
select OrderID, OrderDate, ShipCountry, ShipCity, Freight from Orders
where CustomerID = @CustomerID
ORDER BY OrderDate DESC

exec  CustomerOrders 'ALFKI'
--______________________________________________________________
--2.Undelivered Orders
Create Proc UnDeliveredOrders
as
select OrderID, CustomerID,CompanyName as ShipCompany, OrderDate, RequiredDate, ShipCountry
FROM Orders  O, Shippers S
WHERE DeliveredDate IS NULL    --or ShippedDate?
and S.ShipperID = O.ShipVia
ORDER BY RequiredDate ASC

Exec  UnDeliveredOrders
--______________________________________________________________
--3.LateOrders
Create proc LateOrders
as
 SELECT OrderID, CustomerID, DeliveredDate, RequiredDate, ShipCountry  
 FROM Orders  
 WHERE DeliveredDate > RequiredDate  
 ORDER BY DeliveredDate DESC  

 Exec LateOrders

 --_____________________________________________________________--
 
 --4.MostDiscountedProducts

Create Proc MostDiscountedProducts
as
select P.ProductID, P.ProductName,sum(Discount) AS Discount
from Products P, OrderDetails OD
where OD.ProductID = P.ProductID
group by P.ProductName,P.ProductID
order by Discount desc
 
 Exec MostDiscountedProducts

 --5 StockStatus for products
create Proc StockStatus
@ProductName Varchar(50)
as
SELECT P.ProductID,P.ProductName,  
    CASE  
        WHEN P.UnitsInStock < 10 THEN 'Low Stock'  
        WHEN P.UnitsInStock BETWEEN 10 AND 50 THEN 'Medium Stock'  
        ELSE 'High Stock'  
    END AS StockStatus  
FROM Products P  
Where ProductName = @ProductName
ORDER BY P.ProductID

Exec StockStatus 'Chai'

--_______________________________________________________________________________________
--6 StockThreshold 
Create Proc StockThreshold
@Threshold INT
as
SELECT ProductID, ProductName, UnitsInStock  
FROM Products  
WHERE UnitsInStock < @Threshold  
ORDER BY UnitsInStock ASC; 

Exec StockThreshold 10

--_________________________________________________________________________________________
--7. CustomerTotalSales
Alter proc CustomerTotalSales
as
select	C.CustomerID, C.CompanyName,
sum(OD.UnitPrice*OD.Quantity * (1-OD.Discount)) AS TotalSales,
COUNT(DISTINCT O.OrderID) AS TotalOrders 
from Customers C, Orders O, OrderDetails OD
WHERE C.CustomerID = O.CustomerID
AND OD.OrderID = O.OrderID
GROUP BY C.CustomerID, C.CompanyName  
ORDER BY TotalSales DESC;

Exec CustomerTotalSales 

--________________________________________________________________________________________
