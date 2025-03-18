
-------------------------------- 1- ( ValidatePurchaseOrderStatus )  --------------------------------------

CREATE TRIGGER trg_ValidatePurchaseOrderStatus
ON PurchaseOrders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the Status column was updated
    IF UPDATE(Status)
    BEGIN
        -- Declare variables to hold old and new status values
        DECLARE @ProductID INT;
        DECLARE @OldStatus NVARCHAR(50);
        DECLARE @NewStatus NVARCHAR(50);

        -- Fetch the updated row(s) using the INSERTED and DELETED tables
        SELECT 
            @ProductID = i.ProductID,
            @OldStatus = d.Status, -- Old status (before update)
            @NewStatus = i.Status  -- New status (after update)
        FROM 
            INSERTED i
        INNER JOIN 
            DELETED d ON i.ProductID = d.ProductID;

        -- Validate status transitions
        IF @OldStatus = 'Pending' AND @NewStatus NOT IN ('Approved', 'Cancelled')
        BEGIN
            RAISERROR('Invalid status transition from Pending. CHECK YOUR STATUS !', 16, 1);
            ROLLBACK TRANSACTION; -- Undo the update
            RETURN;
        END;

        IF @OldStatus = 'Approved' AND @NewStatus NOT IN ('Shipped', 'Cancelled')
        BEGIN
            RAISERROR('Invalid status transition from Approved. CHECK YOUR STATUS !', 16, 1);
            ROLLBACK TRANSACTION; -- Undo the update
            RETURN;
        END;

        IF @OldStatus = 'Shipped' AND @NewStatus NOT IN ('Received')
        BEGIN
            RAISERROR('Invalid status transition from Shipped. CHECK YOUR STATUS !', 16, 1);
            ROLLBACK TRANSACTION; -- Undo the update
            RETURN;
        END;

        -- If the status transition is valid, allow the update
        PRINT 'Status updated successfully ' 
    END;
END;

--##############################################################################################

--################################################################################

---------------------------------- 2- ( UPDATE THE SHIP DATE ( ORDER STATUS )  ---------------------------------

CREATE TRIGGER trg_ValidateOrderDateBeforeShipDate
ON Orders
AFTER UPDATE
AS BEGIN
    SET NOCOUNT ON;

    -- Check if ShippedDate is being updated
    IF UPDATE(ShippedDate)
    BEGIN
      
        IF EXISTS (
            SELECT 1
            FROM inserted i
            WHERE i.OrderDate IS NULL
        )
		UPDATE p
    SET p.UnitsInStock = p.UnitsInStock + d.Quantity
    FROM Products p
    JOIN deleted d ON p.ProductID = d.ProductID;
        BEGIN
            
            RAISERROR('Cannot update ShippedDate CAUSE THERE IS NO ORDER YET !!.', 16, 1);
            ROLLBACK TRANSACTION; 
        END;
    END;
END;

--########################################################################

-----------------------------------------3- ( RESTOCK QUENTITY AFTER DELETING AN ORDER )  --------------------------------

CREATE TRIGGER trg_RestoreStockOnOrderDelete
ON Orders
AFTER DELETE
AS BEGIN
    SET NOCOUNT ON;
    UPDATE p
    SET p.UnitsInStock = p.UnitsInStock + od.Quantity
    FROM Products p
    JOIN OrderDetails od
		ON p.ProductID = od.ProductID
    JOIN deleted d 
		ON od.OrderID = d.OrderID;
END;