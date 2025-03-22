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


