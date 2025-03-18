
-- ######################  EmployeesTerritories>>PK_Constraint  #################

ALTER TABLE EmployeesTerritories
add constraint d_PK PRIMARY KEY (EmployeeID,TerritoryId)

--########################  OrderDetails>> PK & Not Null Constraint  ##############################

ALTER TABLE OrderDetails
alter column orderid INT  Not null

ALTER TABLE OrderDetails
alter column PRODUCTid INT  Not null

ALTER TABLE OrderDetails
add constraint dou_PK PRIMARY KEY (OrderId,ProductId)

--##########################  Region>>> Pk Consstraint  ###################################

ALTER TABLE Regions
alter column RegionId INT  Not null

ALTER TABLE Regions
add constraint reg_PK PRIMARY KEY (RegionId)

--########################  Shippers>>>> PK Constraint  ############################

ALTER TABLE Shippers
alter column ShipperId INT  Not null

ALTER TABLE Shippers
add constraint ship_PK PRIMARY KEY (ShipperId)

--####################  Suppliers>> PK Constraint  #######################

ALTER TABLE Suppliers
alter column SupplierId INT  Not null

ALTER TABLE Suppliers
add constraint sup_PK PRIMARY KEY (SupplierId)

--####################################  Territories>>> PK & FK Constraint  ##########################

ALTER TABLE Territories
alter column TerritoryId INT  Not null

ALTER TABLE Territories
add constraint Ter_PK PRIMARY KEY (TerritoryId)


ALTER TABLE Territories
add constraint REG_FK Foreign KEY (RegionId) REFERENCES Regions (RegionId)

--##############################  Products>>> PK & FK Constraints  ########################

ALTER TABLE Products
alter column ProductId INT  Not null

ALTER TABLE Products
add constraint P_PK PRIMARY KEY (ProductId)


ALTER TABLE Products
add constraint Cat_FK Foreign KEY (CategoryId) REFERENCES Categories (CategoryId)

ALTER TABLE Products
add constraint Supp_FK Foreign KEY (SupplierId) REFERENCES Suppliers (SupplierId)

--################################  Orders>>>> PK & FK Constraint  #################################

ALTER TABLE Orders
alter column OrderId INT  Not null


ALTER TABLE Orders
add constraint Ord_PK PRIMARY KEY (OrderId)

ALTER TABLE Orders
add constraint Cust_FK Foreign KEY (CustomerId) REFERENCES Customers (CustomerId)

ALTER TABLE Orders
add constraint Emp_FK Foreign KEY (EmployeeId) REFERENCES Employees (EmployeeId)

ALTER TABLE Orders
add constraint Ship_FK Foreign KEY (ShipVia) REFERENCES Shippers (ShipperId)


--#################################  Category>>> PK Constraint ################################

ALTER TABLE Categories
alter column CategoryId INT  Not null


ALTER TABLE Categories
add constraint Cat_PK PRIMARY KEY (CategoryId)

--########################################  Customers>>> PK Constraint  ####################################

ALTER TABLE Customers
alter column Customers nvarchar(50)  Not null

ALTER TABLE Customers
add constraint Cust_PK PRIMARY KEY (Customers)

--########################################  Employees>>> PK & FK  Constraint  ####################################

ALTER TABLE Employees
alter column EmployeeId INT  Not null


ALTER TABLE Employees
add constraint Emp_PK PRIMARY KEY (EmployeeId)

ALTER TABLE Employees
add constraint EmpSupV_FK Foreign KEY (ReportSto) REFERENCES Employees (EmployeeId)