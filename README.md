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

## Table of Contents
1. [Introduction](##introduction)
2. [NorthWind Traders Overview](#northwind-traders-overview)
3. [Tech Stack](#tech-stack)
4. [Project Stages](#project-stages)
   - [Data Extraction from CSV Files](#1-data-extraction-from-csv-files)
   - [Database Administration and Development](#2-database-administration-and-development)
   - [Data Warehouse Modeling and Implementation](#3-data-warehouse-modeling-and-implementation)
   - [On-Cloud Data Warehouse and ETL](#4-on-cloud-data-warehouse-and-etl)
   - [Cube Creation](#5-cube-creation)
   - [Power BI Dashboarding](#6-power-bi-dashboarding)
   - [Tableau Dashboarding](#7-tableau-dashboarding)
   - [Excel Dashboard](#8-excel-dashboard)
   - [SSRS (SQL Server Reporting Services)](#9-ssrs-sql-server-reporting-services)
   - [Python Dashboard](#10-python-dashboard)
   - [Web Application with AI Integration](#11-web-application-with-ai-integration)
5. [Contributors](#contributors)
6. [Conclusion](#conclusion)

## Introduction
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
 
## 6. Power BI Dashboarding



## 7. Tableeau Dashboarding

We utilized the powerful tool *Tableau* to create a comprehensive dashboard to be able to answer the following business questions:

1.  How many products sold does our data reflect?
2.  What is the total sales for NorthWind?
3.  What is the Avg Discount for NorthWind Orders?
4.  How many customers does NorthWind Have?
5.  How many sold products did NorthWind Sell?
6.  How many suppliers does NorthWind have?
7.  What is the relationship between freight and Sales?
8.  How our customers are distributed around the world?
9.  Which Category has the highest sales from our products?
10.  What is the average price per supplier?
11.  What is the top 5 products sold?
12.  Inventory Status?
13.  Much more

here is the dashboards created 
![Overview](https://github.com/user-attachments/assets/e1e43916-cdd2-4d59-8f16-da108dca0951)
![Employee Analysis](https://github.com/user-attachments/assets/621bcc14-29b4-4de3-8008-93c13757fb35)
![Territories Analysis](https://github.com/user-attachments/assets/fc007e7b-bc57-4d15-beb5-13313973e3b2)
![Customers Analysis](https://github.com/user-attachments/assets/8aa3de2f-e298-41bb-83dd-427570ec00b7)
![Suppliers Analysis](https://github.com/user-attachments/assets/a805b5cd-27e3-4770-acad-19def2e57bf4)
![Product Analysis](https://github.com/user-attachments/assets/58c02f90-8fab-4cd9-9714-0afa4d91e8fb)
![Shippers Analysis](https://github.com/user-attachments/assets/f17ab950-6ea5-458d-b030-859b7a4ba40f)




*The Source Workbooks are in the Repo*


## 8. Excel Dashboard


## 9. SSRS (SQL Server Reporting Analysis)


## 10. Python Dashbaord

In this section we created a dashboard using *python's library streamlit* which is a handy library to create interactive dashboards and deploy them on the web


Link for the dashboard:

https://northwind-dashboard-3wofycj7yznyf7dcqh9dvb.streamlit.app/

here are some screenshot from the dashboard *in case you don't want to go to the link :)*

![Screenshot 2025-03-22 143720](https://github.com/user-attachments/assets/c72bb0a3-1bf2-4359-ab83-ca9b55e868f2)
![Screenshot 2025-03-22 143806](https://github.com/user-attachments/assets/929bba51-1aa0-4f09-af61-73410fb11964)
![Screenshot 2025-03-22 143801](https://github.com/user-attachments/assets/6da69ce7-ac24-4b45-800c-77967e031d2c)
![Screenshot 2025-03-22 143751](https://github.com/user-attachments/assets/8085d3ca-6e3a-4f6e-9ac8-695a861f12f9)
![Screenshot 2025-03-22 143742](https://github.com/user-attachments/assets/17bcac4c-9fd0-4e08-9f95-90cdb6a04b1f)
![Screenshot 2025-03-22 143733](https://github.com/user-attachments/assets/a742f561-e2ab-4c31-8af1-0a5d4df37b92)
![Screenshot 2025-03-22 143728](https://github.com/user-attachments/assets/1bc1f4f4-a818-48d0-b90c-5290c212ec56)


## 11. Web Application

As the revolution of AI continues to grow, we were tasked to create something with AI and use AI in a helpful manner in our projects, so we decided to use *Cursor.ai* to help us create a management app in which NorthWind Traders can utilize to:

1. Manage Customers ( Add, remove, or update customer details )  
2. Mange Products ( Add, remove, or update product details )
3. Manage Orders ( Add, remove, or update product details )
4. Look at quick and helpful measures to asses how their business is running and whether they are moving in the right directions or if there any bottlenecks

![image](https://github.com/user-attachments/assets/266ab66a-908f-466d-ac61-b9b3c2574c8d)
![image](https://github.com/user-attachments/assets/707ba605-c137-4007-8149-387a3372ab2e)
![image](https://github.com/user-attachments/assets/6a93d8c3-8f24-425b-b18b-196444be5436)
![image](https://github.com/user-attachments/assets/374ac7ca-e7db-43bf-90bd-afe4d41350b7)
![image](https://github.com/user-attachments/assets/9203530d-333e-4445-94ac-19f1e76f0515)
![image](https://github.com/user-attachments/assets/a9c71525-e520-4624-bbaa-83e07e842d4a)
![image](https://github.com/user-attachments/assets/7882e133-78e1-445b-ae8f-4a2cea5f6950)


## Tech Stack
The following technologies and tools were used in this project:

### Data Extraction and Integration
- **SQL Server Integration Services (SSIS)**: For ETL processes and data loading.

### Database Management
- **SQL Server**: For database creation, administration, and querying.
- **Stored Procedures, Views, Triggers, Constraints, and Indexes**: For optimizing performance and ensuring data integrity.

### Data Warehousing
- **SQL Server Analysis Services (SSAS)**: For cube creation and multidimensional analysis.
- **Azure SQL Database**: For cloud-based data warehousing.
- **Azure Data Factory**: For cloud-based ETL and pipeline automation.

### Data Visualization
- **Power BI**: For advanced dashboards and reports.
- **Tableau**: For interactive and comprehensive data visualization.
- **Excel**: For additional dashboarding and reporting.
- **Streamlit (Python)**: For creating and deploying interactive web-based dashboards.

### Reporting
- **SQL Server Reporting Services (SSRS)**: For generating and managing reports.

### AI Integration
- **Cursor.ai**: For building an AI-powered management application.


## Contributors
- **Abdelrahman Shear**
- **Nada Aglan**
- **Khalid Sabry**
- **Yasmeen Ragheb**
- **Abdelrahman Abdelhady**



## Conclusion
This project represents a comprehensive implementation of the skills and tools we learned during the ITI program. From data extraction and database administration to advanced visualization and AI integration, we delivered a scalable and maintainable solution for NorthWind Traders. We hope this project serves as a valuable resource for others and demonstrates our capabilities as data professionals.



  

