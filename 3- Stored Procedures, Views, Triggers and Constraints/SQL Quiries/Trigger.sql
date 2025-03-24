USE NorthWind_Master;
GO
-- 1. Reduce the Number of Products UnitsOnStock Per Order
CREATE TRIGGER trg_UpdateStockOnOrderInsert
ON [Order Details]
AFTER INSERT
AS

BEGIN
    UPDATE p
    SET p.UnitsInStock = p.UnitsInStock - i.Quantity
    FROM Products p
    INNER JOIN inserted i ON p.ProductID = i.ProductID
    WHERE p.UnitsInStock >= i.Quantity;

    IF @@ROWCOUNT < (SELECT COUNT(*) FROM inserted)
    BEGIN
		-- We can create a table for the errors and put the insufficient orders here.
        RAISERROR ('Insufficient stock for one or more products.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO


-- 2. Restock when order details are deleted
CREATE TRIGGER trg_RestockOnOrderDelete
ON [Order Details]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE p
    SET p.UnitsInStock = p.UnitsInStock + d.Quantity
    FROM Products p
    INNER JOIN deleted d ON p.ProductID = d.ProductID;
END;


-- 3. Increase UnitsOnOrder when order details are inserted
CREATE TRIGGER trg_IncreaseUnitsOnOrderOnInsert
ON [Order Details]
AFTER INSERT
AS
BEGIN
    UPDATE p
    SET p.UnitsOnOrder = p.UnitsOnOrder + i.Quantity
    FROM Products p
    INNER JOIN inserted i ON p.ProductID = i.ProductID;
END;
GO


-- 4. Warning when UnitsInStock Is low
CREATE TRIGGER trg_WarnLowStock
ON Products
AFTER UPDATE
AS
BEGIN
    -- Insert a warning for products where UnitsInStock drops below 10
    INSERT INTO LowStockWarnings (ProductID, ProductName, UnitsInStock)
    SELECT 
        i.ProductID,
        i.ProductName,
        i.UnitsInStock
    FROM inserted i
    INNER JOIN deleted d ON i.ProductID = d.ProductID
    WHERE i.UnitsInStock < 10 
      AND d.UnitsInStock >= 10; -- Only warn if it just crossed below 10)
	 IF (SELECT UnitsInStock from inserted) < 10
	 BEGIN
	 SELECT 'LOW STOCK';
	 END
END;
GO

UPDATE Products
SET UnitsInStock = 3
WHERE ProductID = 6


CREATE TABLE LowStockWarnings (
WarningID INT IDENTITY(1,1) PRIMARY KEY,
ProductID INT NOT NULL,
ProductName NVARCHAR(40) NOT NULL,
UnitsInStock INT NOT NULL,
WarningDate DATETIME DEFAULT GETDATE(),
CONSTRAINT FK_LowStockWarnings_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID))
GO


-- Threshold for employees (when reaching $100,000 Sales) 