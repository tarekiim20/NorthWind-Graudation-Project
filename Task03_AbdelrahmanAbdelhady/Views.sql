

create view Customer_Order_History as

select orders.CustomerID ,  sum(freight+total_cost) as TotalSales from Orders join 
( select OrderID , SUM(Quantity*UnitPrice*(1-Discount)) as total_cost from [Order Details]
group by OrderID ) as temp on Orders.OrderID = temp.OrderID
group by orders.CustomerID 



create view Employees_Performance as

select Employees.EmployeeID ,  FirstName + ' ' + LastName as Employee_Name 
,  sum(freight+total_cost) as TotalSales from Orders join 
( select OrderID , SUM(Quantity*UnitPrice*(1-Discount)) as total_cost from [Order Details]
group by OrderID ) as temp on Orders.OrderID = temp.OrderID
join Employees on Orders.EmployeeID = Employees.EmployeeID
group by Employees.EmployeeID , FirstName + ' ' + LastName
order by Employees.EmployeeID 







create view Supplier_Product_List AS
select  suppliers.SupplierID, CompanyName , ProductID, ProductName, UnitsInStock
from Suppliers JOIN   Products ON Suppliers.SupplierID = products.SupplierID
order by suppliers.supplierID ;



create view Top_Selling_Products as
select top(10) Products.ProductID , Products.ProductName ,
SUM(Quantity*[Order Details].UnitPrice*(1-Discount)) as totalsales , COUNT(OrderID) as Total_orders
from [Order Details] join Products on [Order Details].ProductID = Products.ProductID
group by Products.ProductID , Products.ProductName 
order by TotalSales desc

