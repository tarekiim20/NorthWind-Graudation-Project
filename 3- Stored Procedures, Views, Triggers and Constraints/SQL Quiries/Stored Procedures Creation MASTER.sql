
ALTER PROCEDURE OrderContents
    @orderid INT
AS
BEGIN
   SELECT
      P.productid,
	  P.productname,
	  OD.Quantity,
	  OD.UnitPrice,
	  ROUND(OD.Quantity*OD.UnitPrice, 2) AS 'Total Sales'
   FROM 
      Products P
   JOIN 
      [Order Details] OD
   ON P.productid = OD.ProductID
   WHERE OD.OrderID = @orderid
END;

Execute OrderContents @orderid = 10248

SELECT * FROM Orders WHERE OrderID = 10248;S
SELECT * FROM [Order Details] WHERE OrderID = 10248;






CREATE PROCEDURE OrderPrepTime
    @orderid INT
AS
BEGIN
   SELECT 
     O.OrderID,
	 DATEDIFF(DAY, O.OrderDate, O.ShippedDate) AS 'Time Taken (Days)'
   FROM 
     Orders O
   WHERE
     O.OrderID = @orderid
END;

EXECUTE OrderPrepTime @orderid = 10248





CREATE PROCEDURE OutOfStockProducts
    @productid INT
AS
BEGIN
    SELECT productname,
    (CASE WHEN unitsinstock = 0 THEN 'Out Of Stock' ELSE 'In Stock' END) StockStatue
	FROM Products
	where productid = @productid
END;

EXECUTE OutOfStockProducts @productid = 10



CREATE PROCEDURE SupplierProductList
    @supplierid NVARCHAR
AS
BEGIN
   SELECT P.productname, P.unitsinstock, C.categoryname
   FROM Products P, Categories C, Suppliers S
   WHERE P.categoryid = C.categoryid
   AND S.supplierid = P.supplierid
   AND S.supplierid = @supplierid
END;

Execute SupplierProductList @supplierid = '10'



/*
CREATE PROCEDURE GetOrdersByCustomer
    @CustomerID nchar(5)
AS
BEGIN
    SELECT O.OrderID, O.OrderDate, O.RequiredDate, O.ShippedDate
    FROM Orders O
    WHERE O.CustomerID = @CustomerID;
END;

EXECUTE GetOrdersByCustomer @CustomerID = 'ANATR'
*/




CREATE PROCEDURE GetTopNExpensiveProducts
    @TopN int
AS
BEGIN
    SELECT TOP (@TopN)ProductName, UnitPrice
    FROM Products
    ORDER BY UnitPrice DESC;
END;

EXECUTE GetTopNExpensiveProducts @TopN = 5