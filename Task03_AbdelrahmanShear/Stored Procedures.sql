USE NorthWind_Master;
GO

-- Fundamental Procedures

-- Adding a new product
CREATE PROCEDURE sp_AddProduct
    @ProductName NVARCHAR(40),
    @SupplierID INT,
    @CategoryID INT,
    @UnitPrice DECIMAL(18,2),
    @UnitsInStock INT = 0,
    @UnitsOnOrder INT = 0,
    @ReorderLevel INT = 0,
    @Discontinued BIT = 0,
    @ProductID INT OUTPUT
AS
BEGIN
    INSERT INTO Product (
        ProductName, SupplierID, CategoryID, UnitPrice, 
        UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued
    )
    VALUES (
        @ProductName, @SupplierID, @CategoryID, @UnitPrice, 
        @UnitsInStock, @UnitsOnOrder, @ReorderLevel, @Discontinued
    );
    SET @ProductID = SCOPE_IDENTITY();
END;
GO

CREATE PROCEDURE sp_AddCustomer
    @CustomerID NCHAR(5),
    @CompanyName NVARCHAR(40),
    @ContactName NVARCHAR(30) = NULL,
    @ContactTitle NVARCHAR(30) = NULL,
    @Address NVARCHAR(60) = NULL,
    @City NVARCHAR(15) = NULL,
    @Region NVARCHAR(15) = NULL,
    @PostalCode NVARCHAR(10) = NULL,
    @Country NVARCHAR(15) = NULL,
    @Phone NVARCHAR(24) = NULL,
    @Fax NVARCHAR(24) = NULL
AS
BEGIN
    INSERT INTO Customers (
        CustomerID, CompanyName, ContactName, ContactTitle, 
        City, PostalCode, Country, Phone, Fax
    )
    VALUES (
        @CustomerID, @CompanyName, @ContactName, @ContactTitle, 
        @City, @PostalCode, @Country, @Phone, @Fax
    );
END;
GO

CREATE PROCEDURE sp_AddOrder
    @CustomerID NCHAR(5),
    @EmployeeID INT,
    @OrderDate DATETIME = NULL,
    @ShipVia INT = 1,
    @Freight DECIMAL(10,2) = 0,
    @OrderID INT OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO Orders (
            CustomerID, EmployeeID, OrderDate, ShipVia, Freight
        )
        VALUES (
            @CustomerID, @EmployeeID, COALESCE(@OrderDate, GETDATE()), @ShipVia, @Freight
        );
        SET @OrderID = SCOPE_IDENTITY();
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
-- Add Some Product
CREATE PROCEDURE sp_AddOrderDetail
    @OrderID INT,
    @ProductID INT,
    @UnitPrice real,
    @Quantity INT,
    @Discount REAL = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO OrderDetails (
            OrderID, ProductID, UnitPrice, Quantity, Discount
        )
        VALUES (
            @OrderID, @ProductID, @UnitPrice, @Quantity, @Discount
        );
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
-- Update Products in Stock Procedure
CREATE PROCEDURE sp_UpdateProductStock
    @ProductID INT,
    @UnitsToAdd INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Product
    SET UnitsInStock = UnitsInStock + @UnitsToAdd
    WHERE ProductID = @ProductID;
END;
GO

-- Delete an Order from the details or the orders.
 

-- Creative/Advanced Procedures


-- A Reorder Report ( Giving a threshold then we get all the products that is less than this threshold)
CREATE PROCEDURE sp_GenerateReorderReport
    @Threshold INT = 10
AS
BEGIN
    SELECT 
        p.ProductID,
        p.ProductName,
        p.UnitsInStock,
        p.ReorderLevel,
        p.UnitsOnOrder,
        SUM(od.Quantity) AS TotalOrderedLast30Days,
        CASE 
            WHEN p.UnitsInStock < @Threshold OR p.UnitsInStock <= p.ReorderLevel THEN 'Reorder Now'
            ELSE 'Monitor'
        END AS ReorderStatus
    FROM Products p
    LEFT JOIN [Order Details] od ON p.ProductID = od.ProductID
    LEFT JOIN Orders o ON od.OrderID = o.OrderID 
        AND o.OrderDate >= DATEADD(day, -30, GETDATE())
    GROUP BY p.ProductID, p.ProductName, p.UnitsInStock, p.ReorderLevel, p.UnitsOnOrder
    ORDER BY p.UnitsInStock ASC;
END;
GO

sp_GenerateReorderReport 10
GO
-- Updating shipping date of multiple orders.
CREATE PROCEDURE sp_BulkShipOrders --('10246, 10247, 10248')
    @OrderIDs NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE Orders
        SET ShippedDate = GETDATE()
        WHERE OrderID IN (
            SELECT CAST(value AS INT)
            FROM STRING_SPLIT(@OrderIDs, ',')
        )
        AND ShippedDate IS NULL;
        IF @@ROWCOUNT = 0
            THROW 50001, 'No unshipped orders found in the list.', 1;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


-- Applying Lucky Discount to the top customer
CREATE PROCEDURE sp_ApplyTopCustomerDiscount
    @Discount REAL = 0.1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TopCustomerID NCHAR(50);
    SELECT TOP 1 @TopCustomerID = CustomerID
    FROM vw_CustomerOrderSummary
    ORDER BY TotalSpent DESC;
    UPDATE OrderDetails
    SET Discount = @Discount
    FROM OrderDetails od
    INNER JOIN Orders o ON od.OrderID = o.OrderID
    WHERE o.CustomerID = @TopCustomerID
      AND o.ShipDate IS NULL
      AND od.Discount < @Discount;
END;
GO

sp_ApplyTopCustomerDiscount 0.1

GO
-- Which Customers got a certain SalesGoal ?
CREATE PROCEDURE sp_CheckEmployeeSalesGoals
    @SalesGoal DECIMAL(20,2) = 100000.00,
    @Year INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        v.EmployeeID,
        v.EmployeeName,
        v.TotalSales,
        @SalesGoal AS SalesGoal,
        CASE 
            WHEN v.TotalSales >= @SalesGoal THEN 'Goal Met'
            ELSE 'Goal Not Met'
        END AS GoalStatus,
        CAST((v.TotalSales / @SalesGoal * 100) AS DECIMAL(5,2)) AS PercentToGoal
    FROM vw_EmployeeSalesPerformance v
    WHERE v.SalesYear = COALESCE(@Year, YEAR(GETDATE()));
END;
GO

sp_CheckEmployeeSalesGoals 10000, 1998


-- Archive the Orders for some Years.
CREATE TABLE OrderArchive (
    OrderID INT PRIMARY KEY,
    CustomerID NCHAR(5),
    OrderDate DATETIME,
    ShippedDate DATETIME,
    Freight DECIMAL(18,2)
);
GO

CREATE PROCEDURE sp_ArchiveOldOrders
    @YearsBack INT = 5
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO OrderArchive (OrderID, CustomerID, OrderDate, ShippedDate, Freight)
        SELECT OrderID, CustomerID, OrderDate, ShipDate, Freight
        FROM Orders
        WHERE OrderDate < DATEADD(year, -@YearsBack, GETDATE());
        DELETE FROM OrderDetails 
        WHERE OrderID IN (
            SELECT OrderID 
            FROM Orders 
            WHERE OrderDate < DATEADD(year, -@YearsBack, min(orderDate))
        );
        DELETE FROM Orders 
        WHERE OrderDate < DATEADD(year, -@YearsBack, GETDATE());
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO