
create trigger trg_check_stock_before_order
on [Order Details]
for insert
as
begin  
if exists (
    select 1
    from inserted 
    join products  on inserted.productid = products.productid
    where inserted.quantity > products.unitsinstock
)
begin
    rollback ;
    select 'order cancelled: quantity exceeds available stock for one or more products.'
end
else
begin
    update Products
    set Products.unitsinstock = Products.unitsinstock - inserted.quantity
    from products 
    join inserted  on Products.productid = inserted.productid;
end
end;

