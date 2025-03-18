------------------------ 1- (CUSTOMER ORDER HISTORY OVER YEARS) -------------------
create  procedure CustHistory (@Customerid nvarchar(50))
As
BEGIN
	select C.Customerid, C.CompanyName,O.OrderDate, P.ProductName,od.Quantity ,Sum(Od.UnitPrice * Od.Quantity * (1-Od.Discount)) as TotalSpent
	from Customers C
	inner Join Orders O
	ON C.CustomerId=O.CustomerID
	Inner join OrderDetails Od
	ON O.OrderID = Od.OrderID
	Inner Join Products P
	On P.ProductID = Od.ProductID
	Where C.CustomerID = @Customerid
	Group BY C.Customerid, C.CompanyName, od.Quantity, O.OrderDate, P.ProductName
	Order By O.OrderDate
End

----EXCUTION

EXEC CustHistory 'HILAA'

--####################################################################################################################

------------------------------  2-( CUSTOMER PERFORMANCE WITH MOST SPEND PRODUCT & MOST ORDERED PRODUCT BY CUSTOMER )  -------------
 
CREATE PROCEDURE CustPerformance (@topN int = 10)
AS BEGIN
    WITH CustomerSpending AS (
    SELECT 
        o.CustomerID, 
        c.CompanyName,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSpent
    FROM Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Customers c ON o.CustomerID = c.CustomerID
    GROUP BY o.CustomerID, c.CompanyName
),
MostSpentProduct AS (
    SELECT 
        o.CustomerID, 
        p.ProductName,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS ProductTotalSpent,
        ROW_NUMBER() OVER (PARTITION BY o.CustomerID ORDER BY SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) DESC) AS RankNum
    FROM Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    GROUP BY o.CustomerID, p.ProductName
),
MostOrderedProduct AS (
    SELECT 
        o.CustomerID, 
        p.ProductName,
        COUNT(od.ProductID) AS OrderCount,
        ROW_NUMBER() OVER (PARTITION BY o.CustomerID ORDER BY COUNT(od.ProductID) DESC) AS RankNum
    FROM Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    GROUP BY o.CustomerID, p.ProductName
)
SELECT TOP @topN,
    cs.CustomerID,
    cs.CompanyName,
    cs.TotalSpent,
	msp.ProductName as MostSpendProduct,
	msp.ProductTotalSpent,
	mop.ProductName as MostOrderedProduct
FROM CustomerSpending cs
LEFT JOIN MostSpentProduct msp 
    ON cs.CustomerID = msp.CustomerID AND msp.RankNum = 1
LEFT JOIN MostOrderedProduct mop 
    ON cs.CustomerID = mop.CustomerID AND mop.RankNum = 1
ORDER BY cs.TotalSpent DESC;
end;

----EXCUTION

EXEC CustPerformance
--#################################################################################################

------------------------------3-( CHECK STOCK BEFOR ORDERING )  -------------------------

--------------------/** WE CAN WRITE AS A TRIGGER **/-------------------------

Create Procedure CheckStock (@ProductId int, @ReqQuantity int)
AS BEGIN
DECLARE @AvailableStock int

select @AvailableStock = UnitsinStock 
from products
where ProductId= @ProductId

if @AvailableStock > @ReqQuantity
	select 'Quantity Is Available' As StockStatus
else
	select ' Quantity Not Avalable ' As StockStatus,  @AvailableStock As AvailableQuantityNow
End

--################################################################################################

--------------------------  4-( Automate reorder low stock products )  -----------------------

-------------   1- ( Creation Of PurchasingOrder Table )   ----------------------
CREATE TABLE PurchaseOrders (
    PurchaseOrderID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT,
    SupplierID INT,
    ReorderQuantity INT,
    OrderDate DATETIME,
    Status NVARCHAR(50) DEFAULT 'Pending' 
)

--####################################################################
----------------------------------------    2- SP       ---------------------
CREATE PROCEDURE AutoReorderAndInsertPurchaseOrder
    @ProductID INT,
    @OrderQuantity INT  
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UnitsInStock SMALLINT,
            @ReorderLevel SMALLINT,
            @SupplierID INT,
            @ReorderQty INT,
			@Discontinued smallint
   
    SELECT 
        @UnitsInStock = UnitsInStock, 
        @ReorderLevel = ReorderLevel, 
        @SupplierID = SupplierID,
		@Discontinued = Discontinued
    FROM 
        Products
    WHERE 
        ProductID = @ProductID;

    -- Handle cases where the product doesn't exist
    IF @UnitsInStock IS NULL OR @ReorderLevel IS NULL OR @SupplierID IS NULL
    BEGIN
        PRINT 'Invalid ProductID.';
        RETURN;
    END;

    -- Check if reorder is needed
    IF @UnitsInStock < @ReorderLevel AND @Discontinued = 0
    BEGIN
        -- Calculate reorder quantity
        SET @ReorderQty = @ReorderLevel + @OrderQuantity

        -- Insert purchase order into a hypothetical PurchaseOrders table
        INSERT INTO PurchaseOrders (ProductID, SupplierID, ReorderQuantity, OrderDate)
        VALUES (@ProductID, @SupplierID, @ReorderQty, GETDATE());

        -- Display reorder details
        SELECT 
            'Reorder Needed!' AS Message,
            'Product ID: ' + CAST(@ProductID AS NVARCHAR(10)) AS ProductID,
            'Supplier ID: ' + CAST(@SupplierID AS NVARCHAR(10)) AS SupplierID,
            'Reorder Quantity: ' + CAST(@ReorderQty AS NVARCHAR(10)) AS ReorderQuantity,
            'Purchase Order Need Your APPROVE !.' AS Status;
    END
    ELSE
    BEGIN
        -- Display message if stock is sufficient
        SELECT 'Stock is sufficient, no reorder needed.' AS Message;
    END;
END;

--------EXCUTION
 EXEC AutoReorderAndInsertPurchaseOrder 11,15

 ---######################################################################################

 --------------  5- ( UPDATING PURCHSING ORDER STATUS( APPROVE, SHIPPED, RECIVED AND CANCEL )   ------------------------

CREATE PROCEDURE UpdatePurchaseOrderStatus
    @ProductID INT,
    @NewStatus NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Update the status of the purchase order
    UPDATE PurchaseOrders
    SET Status = @NewStatus
    WHERE productID = @ProductID;

    -- Display confirmation
    SELECT 
        'STATUS UPDATED! ' AS Message,
        'Product ID: ' + CAST(@ProductID AS NVARCHAR(10)) AS PurchaseOrderID,
        'Order IS : ' + @NewStatus AS NewStatus;
END;

-------EXCUTION

EXEC UpdatePurchaseOrderStatus 11, 'Approved'

----##########################################################################

-----------------------     6- (UPDATING PRODUCT PRICE )     ------------------------------------ 

CREATE PROCEDURE NewProductPrice 
		@ProductID int,
		@NewUnitPrice money
	AS BEGIN

		UPDATE Products
		SET UnitPrice = @NewUnitPrice
		WHERE ProductID = @ProductID
	END


---###########################################################################

--------------------     7- ( EMPLOYEE PERFORMANCE OVER YEARS AND MONTHS )    ---------------------- 

 CREATE PROCEDURE TopEmployeeBySalesAndOrders
    @Year INT, 
    @Month INT  
AS
BEGIN
    SET NOCOUNT ON;

    WITH EmployeeSales AS (
        SELECT 
            e.EmployeeID,
            CONCAT(e.FirstName, ' ', e.LastName) AS EmpName,
            YEAR(o.OrderDate) AS OrderYear,
            MONTH(o.OrderDate) AS OrderMonth,
            SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales,
            COUNT(DISTINCT o.OrderID) AS TotalOrdersByEMP -- Count distinct orders
        FROM  Employees e          
        JOIN  Orders o 
           ON e.EmployeeID = o.EmployeeID
        JOIN  OrderDetails od
            ON o.OrderID = od.OrderID
        WHERE  YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 1         
        GROUP BY  e.EmployeeID,CONCAT(e.FirstName, ' ', e.LastName),YEAR(o.OrderDate), MONTH(o.OrderDate)        
    ),
    RankedEmployeeSales AS (
        SELECT 
            EmpName,
            OrderYear,
            OrderMonth,
            TotalSales,
            TotalOrdersByEMP,
            ROW_NUMBER() OVER (PARTITION BY OrderYear, OrderMonth ORDER BY TotalSales DESC, TotalOrdersByEMP DESC ) AS SalesRank
        FROM EmployeeSales           
    )
    SELECT 
        EmpName,
        OrderYear,
        OrderMonth,
        TotalSales,
        TotalOrdersByEMP
    FROM RankedEmployeeSales      
    WHERE SalesRank = 1
END;


---##########################################################################################

--------------------------- 8- ( LATE SHIPMENTS ) -------------------------------

CREATE PROCEDURE LateShipments
AS BEGIN
    SET NOCOUNT ON;
    SELECT 
        o.OrderID,
        o.CustomerID,
        o.OrderDate,
        o.RequiredDate,
        o.ShippedDate,
        DATEDIFF(day, o.RequiredDate, o.ShippedDate) AS DaysLate
    FROM Orders o        
    WHERE  o.ShippedDate > o.RequiredDate
    ORDER BY  DaysLate DESC
END;

--- ECUTION

EXEC LATESHIPMENTS

--#######################################################################################

----------------------------------   9- (BEST SELLING PRODUCT BY TERRITORY )  ------------------

CREATE PROCEDURE TopProductByShipCountry
AS
BEGIN
    WITH ProductSales AS (
        SELECT 
            o.ShipCountry,
            p.ProductName,
            SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalRevenue,
            RANK() OVER (PARTITION BY o.ShipCountry ORDER BY SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) DESC) AS RankNum
        FROM Orders o            
        JOIN  OrderDetails od
            ON o.OrderID = od.OrderID
        JOIN  Products p
            ON od.ProductID = p.ProductID
        GROUP BY  o.ShipCountry, p.ProductName         
    )
    SELECT 
        ShipCountry,
        ProductName AS BestSellingProduct,
        TotalRevenue
    FROM  ProductSales
       
    WHERE   RankNum = 1
        -- Get the highest-selling product per country
    ORDER BY TotalRevenue DESC        
END;


--##############################################################################################

---------------------------------   10- (NUMBERS OFORDERS BY CUSTOMERS & TERRITORY FOR A PERIOD OF TIME  )   -------------------------------------------

CREATE PROCEDURE TopCustomerByShipCountry
    @StartDate DATETIME, 
    @EndDate DATETIME    
AS
BEGIN
    WITH CustomerOrders AS (
        SELECT 
            o.ShipCountry,
            c.CustomerID,
            c.CompanyName,
            COUNT(o.OrderID) AS OrderCount,
            RANK() OVER (PARTITION BY o.ShipCountry ORDER BY COUNT(o.OrderID) DESC) AS RankNum
        FROM  Orders o    
        JOIN  Customers c
            ON o.CustomerID = c.CustomerID
        WHERE  o.OrderDate BETWEEN @StartDate AND @EndDate
        GROUP BY o.ShipCountry, c.CustomerID, c.CompanyName
            
    )
    SELECT 
        ShipCountry,
        CustomerID,
        CompanyName AS MostActiveCustomer,
        OrderCount
    FROM  CustomerOrders     
    WHERE  RankNum = 1
    ORDER BY  ShipCountry
END;


--#####################################################################
------------------------------------  11- ( most active period  for every territory )   --------------
CREATE PROCEDURE TopRevenueByShipCountry
AS
BEGIN
  WITH MonthlySales AS (
    SELECT 
        YEAR(o.OrderDate) AS Year,
        MONTH(o.OrderDate) AS Month,
        o.ShipCountry,
        SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalRevenue,
        RANK() OVER (PARTITION BY YEAR(o.OrderDate) ORDER BY SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) DESC) AS RankNum
    FROM  Orders o    
    JOIN OrderDetails od 
        ON o.OrderID = od.OrderID
    GROUP BY  YEAR(o.OrderDate), MONTH(o.OrderDate), o.ShipCountry    
)
SELECT 
    Year,
    Month,
    ShipCountry,
    TotalRevenue
FROM  MonthlySales  
WHERE RankNum = 1
ORDER BY  Year
END;



----################################################################################


----------------    11- ( INSERT NEW ORDER )      --------------------------

CREATE PROCEDURE InsertNewOrder
    @CustomerID nchar(5),
    @EmployeeID int,
    @OrderDate datetime,
    @RequiredDate datetime,
	@ShipVia INT,
    @Freight money,
	@ShipName nvarchar(40),
	@ShipAddress nvarchar(60),
	@ShipCity nvarchar(15),
	@ShipRegion nvarchar(15),
	@ShipCountry nvarchar(10),
    @ProductID int,
    @Quantity smallint,
    @UnitPrice money,
	@Discount real
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        --  Insert into Orders table
        INSERT INTO Orders (CustomerID, EmployeeID, OrderDate, RequiredDate, Freight,ShipVia,ShipName,ShipAddress,ShipCity,ShipRegion,ShipCountry)
        VALUES (@CustomerID, @EmployeeID, @OrderDate, @RequiredDate, @Freight,@ShipVia,@ShipName,@ShipAddress,@ShipCity,@ShipRegion,@ShipCountry);

       
        DECLARE @OrderID int;
        SET @OrderID = SCOPE_IDENTITY();

        --  Insert into Order Details table
        INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice,Discount)
        VALUES (@OrderID, @ProductID, @Quantity, @UnitPrice,@Discount);

        
        UPDATE Products
        SET UnitsInStock = UnitsInStock - @Quantity
        WHERE ProductID = @ProductID;

        -- Commit the transaction
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback the transaction in case of error
        ROLLBACK TRANSACTION;
       
        SELECT ' CAN NOT INSERT THE ORDER CHECK AND TRY AGAIN !'
    END CATCH;
END;

--##################################################################################

----------------------------------------   12- (REVENUE BY CATEGORY)   ---------------------------

CREATE PROCEDURE CategoriesRevenue
AS BEGIN
    SET NOCOUNT ON;

    WITH CategoryRevenue AS (
        SELECT 
            c.CategoryID,
            c.CategoryName,
            SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalRevenue
        FROM  Categories c
           
        JOIN Products p
             ON c.CategoryID = p.CategoryID
        JOIN OrderDetails od
             ON p.ProductID = od.ProductID
        GROUP BY c.CategoryID, c.CategoryName
            
    ),
    TotalRevenue AS (
        SELECT 
            SUM(TotalRevenue) AS TotalRevenueAllCategories
        FROM CategoryRevenue
          )
    SELECT 
        cr.CategoryID,
        cr.CategoryName,
        cr.TotalRevenue,
        ROUND((cr.TotalRevenue * 100.0) / tr.TotalRevenueAllCategories, 2) AS RevenuePercentage
    FROM  CategoryRevenue cr
    CROSS JOIN  TotalRevenue tr
    ORDER BY  cr.TotalRevenue DESC
END;




















