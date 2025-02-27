Create Proc Insert_New_Customer ( @customer_ID nchar(5) ,  @Company_name nvarchar(40) , 
								  @contact_name nvarchar(30) , @contact_title nvarchar(30) ,
								  @address nvarchar(60) , @region nvarchar(15),
								  @city nvarchar(15) , @country nvarchar(15) , 
								  @postalcode nvarchar(10) , @phone nvarchar(24) , 
								  @fax nvarchar(24)  ) 
as
insert into Customers
Values(  @customer_ID,  @Company_name , @contact_name , @contact_title , @address , @city ,
		 @region , @postalcode , @country  , @phone  ,  @fax ) ;



Create proc Insert_New_Product ( @productname nvarchar(40) , @supplierid int , @categoryid int,
								 @qtyperunit nvarchar(20) , @unitprice money , @unitsinstock smallint ,
								 @unitsinorder smallint , @reorderlvl smallint , @discon bit)
as

insert into Products
values(@productname , @supplierid , @categoryid , @qtyperunit , @unitprice ,  
		@unitsinstock ,@unitsinorder ,@reorderlvl ,@discon )







Create Proc Insert_New_Order ( @customerID nvarchar(5) , @EmployeeID int , @ShipperID int ,
							   @ShipRegion varchar(15) , @ShipCountry varchar(15) ,@shipaddress nvarchar(60) ,
							   @ShipCity varchar(15) , @Freight money , @ShipPostalCode varchar(10) ) 
as
begin
declare @shipname nvarchar(40) 
select @shipname=CompanyName from Shippers where ShipperID = @ShipperID

insert into Orders 
values (  @customerID , @EmployeeID , GETDATE() , 
		  getdate()+FLOOR(rand() * 14 + 1) , null ,@ShipperID , @Freight , 
		  @shipname , @shipaddress , @ShipCity , @ShipRegion , @ShipPostalCode , @ShipCountry )
end	





create proc Update_ShipDate_Order ( @orderid int , @shipdate datetime )
as 
update Orders 
set ShippedDate = @shipdate
where OrderID = @orderid  ;







create proc Insert_Order_Detail ( @orderid int , @productid int  ,
								  @quantity smallint , @discount real )
as
begin
declare @unitprice money 
select @unitprice=UnitPrice from Products where ProductID = @productid

insert into [Order Details]
values ( @orderid , @productid , @unitprice , @quantity , @discount ) ;
end



Create Proc Get_Orders_by_Customer ( @CustomerID nvarchar(5) )
as
Select * from Orders
where CustomerID = @CustomerID ;




Create Proc Get_Order_Details_by_OrderID ( @OrderID int )
as
Select * from [Order Details]
where OrderID = @OrderID ;




Create Proc Calculate_Total_Sales_by_Employee ( @EmployeeID int )
as
select freight+total_cost as TotalSales from Orders join 
( select OrderID , SUM(Quantity*UnitPrice*(1-Discount)) as total_cost from [Order Details]
group by OrderID ) as temp on Orders.OrderID = temp.OrderID
where EmployeeID = @EmployeeID






Create Proc Get_Products_by_Category ( @categoryname nvarchar(15) )
as
Select * from Products
join Categories on Products.CategoryID = Categories.CategoryID
where Categories.CategoryName = @categoryname ;





Create Proc Get_Orders_Shipped_By_Specific_Shipper ( @CompanyName nvarchar(40) )
as
Select * from orders join Shippers on orders.ShipVia = Shippers.ShipperID
where CompanyName = @CompanyName ;





Create Proc Get_Customers_By_Country ( @country nvarchar(15) )
as
Select count(*) from Customers
where Country = @country ;





Create Proc Get_Products_Out_Of_Stock 
as
Select * from Products
where UnitsInStock = 0 ;





Create Proc Get_Orders_Placed_In_Specific_Date_Range ( @start_date datetime , @end_date datetime ) 
as
Select * from Orders
where OrderDate between @start_date and @end_date ;








create proc Delete_Order ( @orderid int )
as
begin
delete from [Order Details]
where OrderID = @orderid

delete from Orders 
where OrderID = @orderid ;
end




create proc Delete_Order_Detail ( @orderid int , @productid int)
as
delete from [Order Details]
where OrderID = @orderid and ProductID = @productid ;




create proc Get_Order_Sales_By_Month ( @year int , @month int ) 
as
select sum(freight+total_cost) as TotalSales from Orders join 
( select OrderID , SUM(Quantity*UnitPrice*(1-Discount)) as total_cost from [Order Details]
group by OrderID ) as temp on Orders.OrderID = temp.OrderID
where YEAR(Orders.OrderDate) = @year and MONTH(orders.OrderDate) = @month ;







create proc Get_Total_Revenue_By_Category 
as
select Categories.CategoryID ,  sum([Order Details].UnitPrice * Quantity * (1-Discount)) as TotalSales
from [Order Details] 
join Products on [Order Details].ProductID = Products.ProductID
join Categories on Products.CategoryID = Categories.CategoryID
group by Categories.CategoryID ;




create proc Get_Order_Status ( @orderID int ) 
as 
begin
 declare @order_date datetime
 select @order_date=OrderDate from Orders where OrderID = @orderID
 declare @ship_date datetime
 select @ship_date=ShippedDate from Orders where OrderID = @orderID


  if   @ship_date is null 
        select 'In Process'
    else if  @ship_date is not null 
        select 'Shipped'
    else
        select 'Unknown'
    
end





create procedure get_inactive_customers( @month int)
as
begin
declare @maxdate datetime
select @maxdate = max(orderdate) from orders 

select * from customers
where customerid not in 
( select distinct customerid from orders
  where orderdate >= dateadd(MONTH, -@month, @maxdate)
    )
end



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















