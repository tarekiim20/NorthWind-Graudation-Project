# NorthWind Grduation Project
This repo contains all work done by ITI - Power BI Track - Q2 - Mansoura Students for our graduation project on NorthWind Traders (Virtual Company).

We tried to implement all the skills learned from the ITI and used so many tools, procedures and methods to reach a comprehensive and detailed analysis for the NorthWind Company.

This project represent a show case and real implementation of:
1- Data Extraction from CSV files 
2- Database mapping and implmentation using SQL Server
3- Database Adminstartion (Views, Stored Procedures, Triggers, Constraints and Indexes)
4- Data warehouse modeling
5- ETL using SSIS
6- Cube Creation using SSAS
7- Advanced Data Visualization using Power BI and Deplyoment using Power BI server
8- Advancced Data Visualization using Tableau and Tableau Server
9- Dashobarding and Data visualization using Excel
10- Dashboarding and Deployment using Python (Streamlit)
11- Reporting Using SSRS
11- AI implementation and craation for a managmenet app using Cursor.ai 

We will briefly write about each stage, show case what we was able to achieve using the tool and how the work flows from one stage to another. But before that we need to write about what is NorthWind Traders?

## NorthWind Traders
The Northwind database is a sample database that was originally created by Microsoft and used as the basis for their tutorials in a variety of database products for decades. The Northwind database contains the sales data for a fictitious company called “Northwind Traders,” which imports and exports specialty foods from around the world. The Northwind database is an excellent tutorial schema for a small-business ERP, with customers, orders, inventory, purchasing, suppliers, shipping, employees, and single-entry accounting. 

Some of the entities in the NorthWind Traders

- Suppliers: Suppliers and vendors of Northwind
- Customers: Customers who buy products from Northwind
- Employees: Employee details of Northwind traders
- Products: Product information
- Shippers: The details of the shippers who ship the products from the traders to the end-customers
- Orders and Order_Details: Sales Order transactions taking place between the customers & the company

More Data are in the complete documentation located in the repo in the file of (1- Original Data Set CSV and ERD)

## 1. Data Extraction from CSV Files 
After a careful review of the entities and understanding of the nature of the business for NorthWind Traders, we were able to craft an ERD of the business

![ERD Diagram Final](https://github.com/user-attachments/assets/4cb2fdab-5fde-495a-90d3-6326b363ee16)


Now, comes the initial stage of the project where we Extract the data from (11 CSV files).

We used SSIS to do the extraction of the data and the loading in SQL Server

![SSIS Data Load](https://github.com/user-attachments/assets/ae4a6be2-8ffa-4960-9c96-2f4125f1a8e9)

And here the final Database Mapping after creation

![Database Mapping](https://github.com/user-attachments/assets/ae355c84-864a-403a-89ac-e2972679cc79)

*More Details Are found in the documetnation section of this stage*

## 2. Database Adminstartion and Development
Now we have our data ready and loaded in SQL Server on permises.

In this stage we tried to improve the performance, maintainability, security, and reduced Network Traffic

### Stored Procedures
A Stored Procedure is a precompiled collection of SQL statements that can be executed as a single unit. 

In total we have created **49** stored procedures and here are the main takeways:

1. Basic Stored Procedures for business logic like adding, updating or deleting a new order, customer, product, supplier, or a shipper (This will become handy later)
2. Some examples of advanced stored procedures:
  - *GetTopNExpensiveProducts*, takes an integer @TopN as input and returns the top N most expensive products
  - *GetInactiveCustomers*, Identifies customers who have not placed any orders within the last given number of months by comparing the most recent order dates
  - *Customers Performance with most spend Product & Most Ordered Product*
  - *Customers Order History Over Years*

### Views
A view in SQL is a virtual table that is based on the result of a SELECT query. It does not store data
physically but provides a way to simplify complex queries, enhance security, and improve data
management

In total we have created **28** view which are very helpful in terms of security and abstraction and here are some of the main examples

1. *InventoryStatus*, Provides an overview of product inventory with stock status (Critical, Low, Sufficient) based on UnitsInStock and ReorderLevel.
2. *CustomerOrderSummary*, Aggregates customer order data, including total orders, spending, and last order date for customer performance tracking
3. *AllInvoices*, Provides a comprehensive invoice view with order, customer, employee, shipper, and product details, including subtotals and totals.
4. *Best Selling Products*, The BestSellingProducts view is designed to identifyfy the top-selling products based on total sales volume or revenue. This helps businesses understand customer preferences and optmize inventory

### Triggers
A Trigger is a special type of stored procedure in SQL that automatically executes when a specific event (INSERT, UPDATE, DELETE) occurs in a table. Triggers help enforce business rules, maintain data integrity, and automate tasks

In total we have done **13** triggers of different kinds (after/instead of insert / update)

Here are some examples of the Triggers

- *CheckStockBeforeOrder*, This trigger ensures that an order cannot be placed if the requested quan�ty of a product exceeds the available stock.
- *UpdateStockOnOrderInsert*, Reduces UnitsInStock in the Products table when a new order detail is inserted, rolling back if insufficient stock is available.
- *WarnLowStock*, Logs a warning to the LowStockWarnings table and outputs a message when UnitsInStock falls below 10 after an update to the Products table.
- *CheckStockOnOrder* , checks if the available stock (unitsinstock) is sufficient to fulfill the order quantity. If not, it raises an error and rolls back the transaction, preventing orders that exceed available inventory

### Constraints
Constraints are rules applied to table columns to maintain data integrity and consistency in a database. They ensure that invalid data cannot be inserted, updated, or deleted.

We have done a total of *15* constraint on the database


### Indexes
An Index in a database improves query performance by allowing faster data retrieval from a table. It works like a book’s index, making it quicker to find specific rows without scanning the entire table.

we have done *5* indexes on the main columns that we expect our quiries and reports to be associated with


## 3. Data Ware House Modeling and Implementation (On premises)

After having a fully developed and functional database to *run* the business, now it is time to create a data warehouse model to *analyze* the business

We have dececided to follow a *snowflake schema* for the data model for the following reasons 

1. Removing redundancy in the data
2. Optimizing Storage (So Important because we will deploy it on the cloud in the next section)
3. Ease of maintainability
4. Support for Complex Hierarchies (Employee and Territories)

Here is the model

![WhatsApp Image 2025-03-05 at 16 20 42_921d2e02](https://github.com/user-attachments/assets/b52de1d6-b8c4-49c5-bbc6-9a7d272366fd)


### ETL from OLTP to OLAP using SSIS

In the same phase after creating the data warehouse modeling, it is time to convert form the OLTP system and laod the data into the OLAP system using *SQL SERVER Integration Services SSIS* and *SQL Server Management Studio SSMS*


here is some of the ETL screenshots

- Dimensions
  
  ![Dimensions ETL](https://github.com/user-attachments/assets/15e1d344-0de4-44c0-a93c-429cca8af21e)
  
- Incremental Loading of Fact Table
  
  ![OrderFactTable ETL](https://github.com/user-attachments/assets/8467ea12-8e6b-4582-8afa-457c1bd54188)
  
- Automated Pipeline to Retrieve Data from the source using SQL Server Jobs
  
  ![image](https://github.com/user-attachments/assets/11b122cd-45aa-4fbf-b2cb-03b577c4f976)

*Much More Details and Features are avialable on the documentation*


## 4. On cloud Data Ware house and ETL
By using Azure SQL Database and Azure Data FactoryOn this stage we tried to implement the same process of working on premsis allowing us to have **24/7 SQL Server To host our data**, at the end of this phase we will have a complete **automated pipeline** that have the following features

1. Handles new dimensions data correclty (Slowly Chaning Dimensions)
2. Increments the data on the fact Table (Incremental Load)
3. Runs without any human intervention (SQL Jobs)
4. 24/7 Running server (Azure SQL Database)

With these set of features we ensured that our solution is *scalable, maintainable and automated*

Here are some of screenshots of the ETL Using *Azure Data Factory* and Loading the data into *Azure SQL Database*

![694179ee343e4268aa22799c30a7be1c](https://github.com/user-attachments/assets/b317e1f1-238c-412a-b11a-7d277e1002b7)

![6d0de34f5b1949e8a95cc127ed2ef796](https://github.com/user-attachments/assets/6a8d4042-c775-4f09-8a1d-466cf1b7b317)

![ca87948d11064f3680f846a7b0469de0](https://github.com/user-attachments/assets/9e6b92e6-e32b-4809-a8e2-f98f1ce9559e)


*More Detailed Information could be found in the Documentation of this section*


## 5. Cube Creation
After having all our data stored on a logical design to be able to perform our analysis efficiently, it is now time to cache the data into a cube in which we will store our measures


--- 
## 6. Power BI Dashboarding



## 7. Tableeau Dashboarding

We utilized the powerful tool *Tableau* to create a comprehensive dashboard to be able to answer the following business questions:

1. 





  

