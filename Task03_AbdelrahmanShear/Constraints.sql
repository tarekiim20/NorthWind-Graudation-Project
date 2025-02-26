use NorthWind_Master;
GO

-- Order Details
ALTER TABLE [Order Details]
ADD CONSTRAINT chk_UnitPrice CHECK (UnitPrice >= 0);

ALTER TABLE [Order Details]
ADD CONSTRAINT chk_Quantity CHECK (Quantity > 0);

ALTER TABLE [Order Details]
ADD CONSTRAINT chk_Discount CHECK (Discount >= 0 and Discount <= 1);

-- Product
ALTER TABLE Products
ADD CONSTRAINT chk_UnitPrice_Product CHECK (UnitPrice >= 0);

ALTER TABLE Products
ADD CONSTRAINT chk_UnitsInStock CHECK (UnitsInStock >= 0);

ALTER TABLE Products
ADD CONSTRAINT chk_UnitsOnOrder CHECK (UnitsOnOrder >= 0);

ALTER TABLE Products
ADD CONSTRAINT chk_ReorderLevel CHECK (ReorderLevel >= 0);

ALTER TABLE Products
ADD CONSTRAINT chk_Discontinued CHECK (Discontinued IN (0,1));


-- Orders
ALTER TABLE Orders
ADD CONSTRAINT chk_Fright CHECK ( Freight >= 0);

ALTER TABLE Orders
ADD CONSTRAINT df_OrderDate DEFAULT GETDATE() FOR OrderDate;


-- Customers
ALTER TABLE Customers
ADD CONSTRAINT uniq_CompanyName UNIQUE (CompanyName);

-- Suppliers
ALTER TABLE Suppliers
ADD CONSTRAINT uniq_ComapnyName UNIQUE (CompanyName);


-- Employees
ALTER TABLE Employees
ADD CONSTRAINT chk_HireDate CHECK (HireDate <= GETDATE());

ALTER TABLE Employees
ADD CONSTRAINT chk_BirthDate CHECK (BirthDate <= GETDATE() AND BirthDate < HireDate);



-- Categories
ALTER TABLE Categories
ADD CONSTRAINT uniq_CategoryName UNIQUE (CategoryName);

-- Show all the constraints 
SELECT 
    tc.TABLE_NAME,
    tc.CONSTRAINT_TYPE,
    tc.CONSTRAINT_NAME,
    kcu.COLUMN_NAME
FROM 
    INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN 
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu 
    ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE 
    tc.TABLE_SCHEMA = 'dbo'
ORDER BY 
    tc.TABLE_NAME, tc.CONSTRAINT_TYPE;