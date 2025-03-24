
CREATE TRIGGER CheckStockOnOrder
ON [Order Details]
AFTER INSERT, UPDATE
AS
BEGIN
   IF EXISTS( 
      SELECT 1
	  FROM inserted i, Products p
	  WHERE i.ProductID = P.productid
	  AND P.unitsinstock < I.Quantity
   )
   BEGIN
      RAISERROR('Insuffecient Stock For This Product', 16,1)
	  ROLLBACK TRANSACTION;
   END
END;


UPDATE [Order Details]
SET Quantity = 90
WHERE OrderID = 10248




ALTER TRIGGER OrderDateValidation
ON Orders
AFTER INSERT, UPDATE
AS
BEGIN
   IF EXISTS(
      SELECT 1
	  FROM inserted i
	  WHERE OrderDate > ShippedDate
	  OR OrderDate > RequiredDate
   )
   BEGIN
     RAISERROR('Make Sure that OrderDate is Older than ShipDate and RequiredDate',16,1);
	 ROLLBACK TRANSACTION
   END
END;


UPDATE Orders
SET ShippedDate = '1996-07-01 00:00:00.000'
WHERE OrderID = 10248



CREATE TRIGGER EmployeeOverload
ON Orders
AFTER INSERT
AS
BEGIN
   IF EXISTS(
      SELECT 1
	  FROM inserted I
	  WHERE(
	    SELECT COUNT(*)
		FROM Employees E
		JOIN Orders O
		ON E.employeeid = O.EmployeeID
	  )> 10
   )
   BEGIN
     RAISERROR('Employee has reached his orders limit for today',16,1);
	 ROLLBACK TRANSACTION;
   END
END;

SELECT EmployeeID, COUNT(OrderID)'ORDER COUNT'
FROM Orders
WHERE OrderDate = '1996-07-08 00:00:00.000'
GROUP BY EmployeeID


CREATE TABLE OrderAuditLog (
    AuditID INT IDENTITY(1,1) PRIMARY KEY, 
    OrderID INT,                          
    Action NVARCHAR(10),                  
    ActionDate DATETIME,               
    UserName NVARCHAR(128)                
);


CREATE TRIGGER trg_Orders_Audit
ON Orders
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    INSERT INTO OrderAuditLog (OrderID, Action, ActionDate, UserName)
    SELECT 
        ISNULL(i.OrderID, d.OrderID), 
        CASE 
            WHEN i.OrderID IS NOT NULL AND d.OrderID IS NOT NULL THEN 'UPDATE'
            WHEN i.OrderID IS NOT NULL THEN 'INSERT'
            WHEN d.OrderID IS NOT NULL THEN 'DELETE'
        END,
        GETDATE(),
        SYSTEM_USER
    FROM inserted i
    FULL OUTER JOIN deleted d ON i.OrderID = d.OrderID;
END;

UPDATE Orders
SET ShipCountry = 'Germany'
WHERE OrderID = 10248




CREATE TRIGGER ClearOrderDetail
ON [Order Details]
AFTER DELETE
AS
BEGIN
   DELETE FROM [Order Details]
   WHERE OrderID IN(SELECT OrderID FROM deleted)
END




SELECT CustomerID
FROM Orders
WHERE CustomerID NOT IN(SELECT CustomerID FROM Customers)