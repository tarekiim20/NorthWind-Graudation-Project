ALTER VIEW CustomerOrder AS
SELECT 
   C.customerid,
   C.companyname,
   COUNT(O.OrderID) AS 'Total Orders',
   SUM(OD.UnitPrice) AS 'Total Spent',
   MIN(O.OrderDate) AS'Last Order Date'
FROM 
   Customers C
JOIN 
   Orders O ON C.customerid = O.CustomerID
JOIN
    [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY C.customerid, C.companyname





SELECT * FROM CustomerOrder


CREATE VIEW SalesPerformance AS
SELECT 
   P.productid,
   P.productname,
   C.categoryname,
   SUM(OD.Quantity) AS 'Total Units Sold', 
   SUM(OD.UnitPrice * OD.Quantity) AS 'Total Revenue'
FROM Products P, [Order Details] OD, Categories C
WHERE P.productid = OD.ProductID
AND C.categoryid = P.categoryid
GROUP BY P.productid, P.productname,C.categoryname

SELECT * FROM SalesPerformance



CREATE VIEW ProductInventoryStatus AS
SELECT 
    P.productid,
    P.productname,
    P.quantityperunit,
    P.unitsinstock,
    P.unitsonorder,
    P.reorderlevel,
    CASE 
        WHEN P.unitsinstock = 0 THEN 'Out of Stock'
        WHEN P.unitsinstock < P.reorderlevel THEN 'Low on Stock'
        ELSE 'In Stock'
    END AS 'Product Status'
FROM Products P;

SELECT * FROM ProductInventoryStatus



Create VIEW CustomerRetention AS
SELECT 
     C.customerid,
	 C.companyname,
	 MIN(OrderDate) AS 'First Order Date',
	 MAX(OrderDate) AS 'Last Order Date',
	 COUNT(O.OrderID) AS 'Total Orders',
	 SUM(OD.UnitPrice) AS 'Total Spent'
FROM Customers C, Orders O, [Order Details] OD
WHERE C.customerid = O.CustomerID
AND O.OrderID = OD.OrderID
GROUP BY C.customerid, C.companyname

SELECT * FROM CustomerRetention


/*
ALTER VIEW ShipperReliability AS
SELECT
     S.shipperid,
	 S.companyname, 
	 COUNT(CASE WHEN O.RequiredDate = O.DeliveredDate THEN 1 END) AS 'On Time DELIVERY',
	 COUNT(CASE WHEN O.RequiredDate > O.DeliveredDate THEN 1 END) AS 'Early DELIVERY',
	 COUNT(CASE WHEN O.RequiredDate < O.DeliveredDate THEN 1 END) AS 'Late DELIVERY',
	 ROUND((CAST(SUM(CASE WHEN O.DeliveredDate <= O.RequiredDate THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100,1) AS DeliveryReliabilityPercentage
   
FROM Shippers S, Orders O
WHERE S.shipperid = O.ShipVia
GROUP BY S.shipperid, S.companyname

SELECT * FROM ShipperReliability
*/


ALTER VIEW ProductAboveAVGPrice
AS
SELECT DISTINCT
    P.ProductName

FROM 
    [Order Details] O
JOIN 
    Products P ON O.ProductID = P.ProductID
WHERE 
    O.UnitPrice > (SELECT AVG(OD.UnitPrice) FROM [Order Details] OD);

SELECT  * FROM ProductAboveAVGPrice



CREATE VIEW DiscontinuedProductList
AS
SELECT productname
FROM Products
WHERE discontinued = 1

SELECT * FROM DiscontinuedProductList

CREATE VIEW SalesPerYear
AS
SELECT YEAR(O.OrderDate) AS OrderYear, 
    ROUND(SUM(OD.Quantity * OD.UnitPrice * (1 - OD.Discount)),2) AS TotalSales
FROM Orders O
JOIN [Order Details] OD
ON O.OrderID = OD.OrderID
GROUP BY YEAR(O.OrderDate)

SELECT * FROM SalesPerYear