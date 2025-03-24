USE Northwind_Master;
GO

-- Orders
CREATE NONCLUSTERED INDEX idx_Orders_CustomerID ON Orders(CustomerID);
CREATE NONCLUSTERED INDEX idx_Orders_OrderDate ON Orders(OrderDate);

-- OrderDetails
CREATE NONCLUSTERED INDEX idx_OrderDetails_ProductID ON [Order Details](ProductID);

-- Products
CREATE NONCLUSTERED INDEX idx_Products_CategoryID ON Products(CategoryID);

-- Customers
CREATE NONCLUSTERED INDEX idx_Customers_Country ON Customers(Country);

