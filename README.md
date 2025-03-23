# NorthWind Graduation Project

This repository contains the work completed by the ITI Power BI Track (Q2) students from Mansoura for our graduation project focused on NorthWind Traders, a virtual company. Our goal was to apply the skills and tools acquired during the ITI program to deliver a detailed, end-to-end analysis and solution for NorthWind Traders.

---

## Table of Contents
1. [Introduction](#introduction)
2. [Tech Stack](#tech-stack)
3. [Project Stages](#project-stages)
   - [1. Data Extraction from CSV Files](#1-data-extraction-from-csv-files)
   - [2. Database Administration and Development](#2-database-administration-and-development)
   - [3. Data Warehouse Modeling and Implementation (On-Premises)](#3-data-warehouse-modeling-and-implementation-on-premises)
   - [4. On-Cloud Data Warehouse and ETL](#4-on-cloud-data-warehouse-and-etl)
   - [5. Cube Creation](#5-cube-creation)
   - [6. Power BI Dashboarding](#6-power-bi-dashboarding)
   - [7. Tableau Dashboarding](#7-tableau-dashboarding)
   - [8. Excel Dashboard](#8-excel-dashboard)
   - [9. SSRS (SQL Server Reporting Services)](#9-ssrs-sql-server-reporting-services)
   - [10. Python Dashboard](#10-python-dashboard)
   - [11. Web Application with AI Integration](#11-web-application-with-ai-integration)
4. [Contributors](#contributors)
5. [Conclusion](#conclusion)

---

## Introduction

The NorthWind database is a sample dataset originally developed by Microsoft to demonstrate database concepts. It represents the operations of NorthWind Traders, a fictitious company specializing in importing and exporting specialty foods globally. The database models a small-business ERP system, encompassing entities like customers, orders, inventory, suppliers, shipping, employees, and basic accounting.

Key entities in the NorthWind Traders database include:
- **Suppliers**: Vendors providing products.
- **Customers**: Buyers of NorthWind products.
- **Employees**: Staff managing operations.
- **Products**: Inventory details.
- **Shippers**: Logistics partners.
- **Orders and Order Details**: Sales transactions.

For a complete overview, refer to the documentation in the repository under `(1- Original Data Set CSV and ERD)`.

---

## Tech Stack

This project leverages a wide range of tools and technologies, showcasing our skills across data extraction, database management, warehousing, visualization, reporting, and AI integration:

### Data Extraction and Integration
- **SQL Server Integration Services (SSIS)**: ETL processes and data loading from CSV files.

### Database Management
- **SQL Server**: Database creation, administration, and querying.
- **Stored Procedures, Views, Triggers, Constraints, Indexes**: Performance optimization and data integrity enforcement.

### Data Warehousing
- **SQL Server Analysis Services (SSAS)**: Multidimensional cube creation.
- **Azure SQL Database**: Cloud-based data warehousing.
- **Azure Data Factory**: Cloud ETL and automated pipelines.

### Data Visualization
- **Power BI**: Advanced dashboards and deployment via Power BI Server.
- **Tableau**: Interactive dashboards deployed on Tableau Server.
- **Excel**: Dashboarding and data visualization.
- **Streamlit (Python)**: Web-based interactive dashboards.

### Reporting
- **SQL Server Reporting Services (SSRS)**: Structured report generation.

### AI Integration
- **Cursor.ai**: Development of an AI-powered management application.

---

## Project Stages

### 1. Data Extraction from CSV Files
We began by analyzing NorthWind Traders' entities and crafting an Entity-Relationship Diagram (ERD) to understand the business structure:

![ERD Diagram Final](https://github.com/user-attachments/assets/4cb2fdab-5fde-495a-90d3-6326b363ee16)

Using SSIS, we extracted data from 11 CSV files and loaded it into SQL Server:

![SSIS Data Load](https://github.com/user-attachments/assets/ae4a6be2-8ffa-4960-9c96-2f4125f1a8e9)

The resulting database mapping is shown below:

![Database Mapping](https://github.com/user-attachments/assets/ae355c84-864a-403a-89ac-e2972679cc79)

*Further details are available in the documentation for this stage.*

---

### 2. Database Administration and Development
With the data loaded into an on-premises SQL Server, we enhanced performance, maintainability, and security through:

#### Stored Procedures
- **Total Created**: 49
- **Examples**:
  - `GetTopNExpensiveProducts`: Returns the top N most expensive products.
  - `GetInactiveCustomers`: Identifies customers inactive for a specified period.
  - `CustomerPerformance`: Tracks spending and order frequency.
  - `CustomerOrderHistoryOverYears`: Analyzes historical order trends.

#### Views
- **Total Created**: 28
- **Examples**:
  - `InventoryStatus`: Monitors stock levels (Critical, Low, Sufficient).
  - `CustomerOrderSummary`: Aggregates order data for performance tracking.
  - `AllInvoices`: Combines order, customer, and product details.
  - `BestSellingProducts`: Highlights top-performing products by sales volume.

#### Triggers
- **Total Created**: 13
- **Examples**:
  - `CheckStockBeforeOrder`: Prevents orders exceeding available stock.
  - `UpdateStockOnOrderInsert`: Adjusts inventory upon order placement.
  - `WarnLowStock`: Alerts when stock falls below a threshold.
  - `CheckStockOnOrder`: Ensures stock sufficiency during transactions.

#### Constraints
- **Total Created**: 15
- Enforced rules for data integrity and consistency.

#### Indexes
- **Total Created**: 5
- Optimized query performance on frequently accessed columns.

---

### 3. Data Warehouse Modeling and Implementation (On-Premises)
To enable business analysis, we designed a **Snowflake Schema** data warehouse for:
- Reduced redundancy
- Optimized storage
- Simplified maintenance
- Support for complex hierarchies (e.g., Employee-Territory relationships)

![Snowflake Schema](https://github.com/user-attachments/assets/b52de1d6-b8c4-49c5-bbc6-9a7d272366fd)

#### ETL from OLTP to OLAP
Using SSIS and SSMS, we transformed and loaded data into the OLAP system:
- **Dimensions ETL**:  
  ![Dimensions ETL](https://github.com/user-attachments/assets/15e1d344-0de4-44c0-a93c-429cca8af21e)
- **Fact Table Incremental Load**:  
  ![OrderFactTable ETL](https://github.com/user-attachments/assets/8467ea12-8e6b-4582-8afa-457c1bd54188)
- **Automated Pipeline**: SQL Server Jobs for scheduled updates  
  ![SQL Server Jobs](https://github.com/user-attachments/assets/11b122cd-45aa-4fbf-b2cb-03b577c4f976)

*See documentation for additional details.*

---

### 4. On-Cloud Data Warehouse and ETL
Using **Azure SQL Database** and **Azure Data Factory**, we replicated the on-premises process in the cloud, achieving:
- 24/7 availability
- Automated pipelines handling:
  - Slowly Changing Dimensions
  - Incremental fact table updates
  - Hands-free operation via SQL Jobs

Screenshots of the Azure ETL process:
![Azure ETL 1](https://github.com/user-attachments/assets/b317e1f1-238c-412a-b11a-7d277e1002b7)  
![Azure ETL 2](https://github.com/user-attachments/assets/6a8d4042-c775-4f09-8a1d-466cf1b7b317)  
![Azure ETL 3](https://github.com/user-attachments/assets/9e6b92e6-e32b-4809-a8e2-f98f1ce9559e)

*Refer to the documentation for more details.*

---

### 5. Cube Creation
We have made 6 Cubes caching out the important aggregations that we will use later on the reports

1. Data Warehouse Cube

![DWH Cube](https://github.com/user-attachments/assets/ad2d9558-7693-43c4-97d6-2c89cc35b7b7)

   
2. Customers

![Customers Cube](https://github.com/user-attachments/assets/f55608d6-2b01-494b-a4c4-26a2fcece9d6)

   
3. ShipInfo

![ShipInfo Cube](https://github.com/user-attachments/assets/e8f0c934-a7d7-4912-b8b1-c278f3c30e0f)

4. Shippers

![Shippers Cube](https://github.com/user-attachments/assets/b7507101-473e-41dd-8373-884e662c98f0)

   
5. Products

![Products Cube](https://github.com/user-attachments/assets/00458b7a-d90b-4f47-bea6-813ac0da83a2)


7. Employees
   
![Employees Cube](https://github.com/user-attachments/assets/d8f8c354-94e5-4a5f-b404-80a40e6349e1)

---

### 6. Power BI Dashboarding
Usign **Power BI**, we created this dashboard to provides insights into key Northwind database dimensions, designed to answer key business questions.
 It includes light and dark mode options for user flexibility and leverages bookmarks for intuitive navigation.
  Check the screenshots below for specific dimensions. Full details are available in the documentation.

### Screenshots
- Overview:
   ![Overview](https://github.com/user-attachments/assets/4823aa44-a29d-4fba-adf3-207dddff43e3)
  
- Employee Analysis:
   ![Employee](https://github.com/user-attachments/assets/c0b1b16d-0f7e-4c4f-9d02-f83a5bfd4ad4)

- Demographics Analysis:
  ![Demographics](https://github.com/user-attachments/assets/6619c12b-ca5a-48ba-a39b-53a1eed83ddc)
  
- Customer Analysis:
  ![Customer](https://github.com/user-attachments/assets/a1f59dc6-0c0c-4531-872e-a81ee2d7bd81)
  
- Suppliers Analysis:
  ![Supplier](https://github.com/user-attachments/assets/399bea37-7634-485e-ab5b-9d986c6311df)
  
- Product Analysis:
  ![Product](https://github.com/user-attachments/assets/ffcd7298-d877-43e7-817c-58686a20f8c4)
  
- Shippers Analysis:
   ![Shipper](https://github.com/user-attachments/assets/5037706e-4c97-4333-81a2-2ff453e61da5)
  
- Dark Mode:
  
   ![DarkMode](https://github.com/user-attachments/assets/06403c28-4699-47f7-90b9-bb176e23bca1)







---

### 7. Tableau Dashboarding
Using **Tableau**, we created dashboards to answer key business questions, such as:
- Total sales and product volumes
- Customer and supplier counts
- Top-selling categories and products
- Inventory status

Dashboards include:
- Overview: ![Overview](https://github.com/user-attachments/assets/e1e43916-cdd2-4d59-8f16-da108dca0951)
- Employee Analysis: ![Employee Analysis](https://github.com/user-attachments/assets/621bcc14-29b4-4de3-8008-93c13757fb35)
- Territories Analysis: ![Territories Analysis](https://github.com/user-attachments/assets/fc007e7b-bc57-4d15-beb5-13313973e3b2)
- Customers Analysis: ![Customers Analysis](https://github.com/user-attachments/assets/8aa3de2f-e298-41bb-83dd-427570ec00b7)
- Suppliers Analysis: ![Suppliers Analysis](https://github.com/user-attachments/assets/a805b5cd-27e3-4770-acad-19def2e57bf4)
- Product Analysis: ![Product Analysis](https://github.com/user-attachments/assets/58c02f90-8fab-4cd9-9714-0afa4d91e8fb)
- Shippers Analysis: ![Shippers Analysis](https://github.com/user-attachments/assets/f17ab950-6ea5-458d-b030-859b7a4ba40f)

*Source workbooks are available in the repository.*

---

### 8. Excel Dashboard
[Placeholder for content]

---

### 9. SSRS (SQL Server Reporting Services)
We have made 4 comprehensive reports about

1. Employee Performance
   
![Employee Performance](https://github.com/user-attachments/assets/703b3f7c-a1a1-4e6b-b297-ba24da70fcd7)

2. Products
   
![Products](https://github.com/user-attachments/assets/5bf90af6-c4ff-4227-9994-acbbcf164374)

3. Customers
   
![Customers](https://github.com/user-attachments/assets/7693f1d5-1625-450b-94df-3e6fe80d8353)

4. Suppliers
   
![Suppliers](https://github.com/user-attachments/assets/fa86473c-69c0-4ee2-b506-f49ca317eb4d)

---

### 10. Python Dashboard
We developed an interactive dashboard using **Streamlit** in Python, deployed at:  
[NorthWind Dashboard](https://northwind-dashboard-3wofycj7yznyf7dcqh9dvb.streamlit.app/)

Screenshots:  
![Screenshot 1](https://github.com/user-attachments/assets/c72bb0a3-1bf2-4359-ab83-ca9b55e868f2)  
![Screenshot 2](https://github.com/user-attachments/assets/929bba51-1aa0-4f09-af61-73410fb11964)  
![Screenshot 3](https://github.com/user-attachments/assets/6da69ce7-ac24-4b45-800c-77967e031d2c)

---

### 11. Web Application with AI Integration
Using **Cursor.ai**, we built a management app enabling NorthWind Traders to:
- Manage customers, products, and orders
- Monitor business performance metrics

Screenshots:  
![App Screenshot 1](https://github.com/user-attachments/assets/266ab66a-908f-466d-ac61-b9b3c2574c8d)  
![App Screenshot 2](https://github.com/user-attachments/assets/707ba605-c137-4007-8149-387a3372ab2e)  
![App Screenshot 3](https://github.com/user-attachments/assets/6a93d8c3-8f24-425b-b18b-196444be5436)

---

## Contributors
- **Abdelrahman Shear**
- **Nada Aglan**
- **Khalid Sabry**
- **Yasmeen Ragheb**
- **Abdelrahman Abdelhady**

---

## Conclusion
This project encapsulates our journey through the ITI Power BI Track, showcasing a full lifecycle solution—from data extraction to AI-driven applications. We delivered a scalable, automated, and insightful system for NorthWind Traders, reflecting our proficiency in modern data tools and techniques.
