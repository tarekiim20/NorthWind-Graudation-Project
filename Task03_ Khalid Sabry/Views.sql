
-----------------------------  EMP Performance -------------------
CREATE VIEW EmployeeSalesSummary AS
    SELECT 
        e.EmployeeID,
       CONCAT( e.FirstName,  ' ' , e.LastName) AS EmployeeName,
        SUM(od.Quantity * od.UnitPrice) AS TotalSales
    FROM   Orders o    
    JOIN  OrderDetails od
        ON o.OrderID = od.OrderID
    JOIN  Employees e
        ON o.EmployeeID = e.EmployeeID
    GROUP BY  e.EmployeeID, e.FirstName, e.LastName
       
    
	--###########################################################################################

	-------------------------------2- ( CURRENT ACTIVE PRODUCT BY THEIR SUPPLIERS )  --------------------------------------------
CREATE VIEW ActiveProductBySuppliers AS
	SELECT 
        s.SupplierID,
        s.CompanyName,
        COUNT(p.ProductID) AS ProductCount
    FROM  Products p
    JOIN  Suppliers s 
	ON p.SupplierID = s.SupplierID
	where p.Discontinued=0
    GROUP BY s.SupplierID, s.CompanyName

--########################################################################################

-------------------------  3- ( TOTAL REVENUE PER YEAR )

CREATE VIEW TotalRevenuePerYear AS

SELECT 
    YEAR(o.OrderDate) AS Year,
    COUNT(DISTINCT o.OrderID) AS TotalOrders, 
    SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalRevenue  
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY YEAR(o.OrderDate)



--####################################################################################################

--------------------------- 4- ( Total Product Supplied ) ----------------------------------------
CREATE VIEW TotalProductSupplied AS
 SELECT s.SupplierID, s.CompanyName, COUNT(DISTINCT p.ProductID) AS TotalProductsSupplied
    FROM Suppliers s
    JOIN Products p 
	ON s.SupplierID = p.SupplierID
    JOIN Orders o
	ON p.ProductID IN (SELECT ProductID FROM OrderDetails)
    GROUP BY s.SupplierID, s.CompanyName


	--##################################################################################

	------------------------  5- ( IN ACTIVE PRODUCTS SALES AND ORDER QUANTITY)  -------------------------------
CREATE VIEW InActiveProductPerformance AS
WITH TotalSales AS (
    SELECT 
        SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalSalesAllProducts
    FROM Orders o       
    JOIN OrderDetails od
		ON o.OrderID = od.OrderID         
    JOIN  Products p 
		ON p.ProductID = od.ProductID
       
)
SELECT 
    od.ProductID,
    p.SupplierID,
    p.ProductName,
    SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalSales,
    COUNT(od.ProductID) AS OrderCount,
	ROUND((SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) * 100.0) / t.TotalSalesAllProducts, 2) AS SalesPercentage

FROM  Orders o  
JOIN  OrderDetails od
    ON o.OrderID = od.OrderID
JOIN  Products p
    ON p.ProductID = od.ProductID
CROSS JOIN  TotalSales t
    
WHERE  p.Discontinued = 1
GROUP BY  od.ProductID, p.SupplierID, p.ProductName, t.TotalSalesAllProducts





	--########################################################
	
	
   
	

	