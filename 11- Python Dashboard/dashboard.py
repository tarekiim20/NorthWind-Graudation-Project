import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime
import calendar
import numpy as np
# Set page configuration
st.set_page_config(page_title="Northwind Traders Dashboard", layout="wide")

# Title
st.markdown("# :bar_chart: Northwind Traders Dashboard")
st.markdown("*Comprehensive business analytics for Northwind Traders made by ITI Students - Mansour - Power BI Developer - Q2*")

# Load CSV files
@st.cache_data
def load_data():
    orders = pd.read_csv("orders.csv")
    orderDetails = pd.read_csv("order-details.csv")
    products = pd.read_csv("products.csv")
    customers = pd.read_csv("customers.csv")
    shippers = pd.read_csv("shippers.csv")
    employees = pd.read_csv("employees.csv")
    categories = pd.read_csv("categories.csv") if "categories.csv" in [f for f in ["categories.csv"]] else None
    suppliers = pd.read_csv("suppliers.csv") if "suppliers.csv" in [f for f in ["suppliers.csv"]] else None
    return orders, orderDetails, products, customers, shippers, employees, categories, suppliers

orders, orderDetails, products, customers, shippers, employees, categories, suppliers = load_data()

# Data Preprocessing
orders["orderDate"] = pd.to_datetime(orders["orderDate"], errors='coerce')
orderDetails["totalSales"] = orderDetails["unitPrice"] * orderDetails["quantity"] * (1 - orderDetails["discount"])
orders["year"] = orders["orderDate"].dt.year
orders["month"] = orders["orderDate"].dt.month
orders["quarter"] = orders["orderDate"].dt.quarter

# Create shipper name mapping
shipper_map = dict(zip(shippers["shipperID"], shippers["companyName"]))
orders["shipperName"] = orders["shipVia"].map(shipper_map)

# Merge data for analysis
salesData = pd.merge(orders, orderDetails, on="orderID")
salesData = pd.merge(salesData, products, on="productID", how='left')
salesData = pd.merge(salesData, employees, on="employeeID", how='left')
salesData["employeeName"] = salesData["firstName"] + " " + salesData["lastName"]

# Sidebar Filters
st.sidebar.header("Filters")
year_options = sorted(salesData["orderDate"].dt.year.dropna().unique())
year = st.sidebar.selectbox("Select Year", year_options, index=len(year_options)-1)

# Add quarter filter
quarters = sorted(salesData[salesData["orderDate"].dt.year == year]["quarter"].unique())
quarter = st.sidebar.multiselect("Select Quarter", quarters, default=quarters)

# Add customer country filter
countries = sorted(customers["country"].unique())
country = st.sidebar.multiselect("Select Customer Countries", countries, default=[])

# Filter data based on selections
filtered_data = salesData[salesData["orderDate"].dt.year == year]
if quarter:
    filtered_data = filtered_data[filtered_data["quarter"].isin(quarter)]
if country:
    # Get customer IDs for selected countries
    customer_ids = customers[customers["country"].isin(country)]["customerID"].tolist()
    filtered_data = filtered_data[filtered_data["customerID"].isin(customer_ids)]

# KPI Metrics with comparison to previous period
st.markdown("## :bar_chart: Key Metrics")

# Calculate metrics for current period
current_sales = filtered_data["totalSales"].sum()
current_freight = filtered_data["freight"].sum()
current_customers = filtered_data["customerID"].nunique()
current_quantity = filtered_data["quantity"].sum()
current_orders = filtered_data["orderID"].nunique()
current_avg_order_value = current_sales / current_orders if current_orders > 0 else 0

# Create previous period for comparison (previous year or quarter)
if len(quarter) == 1 and quarter[0] > 1:
    # Previous quarter in same year
    prev_quarter = quarter[0] - 1
    prev_year = year
    prev_data = salesData[(salesData["orderDate"].dt.year == prev_year) & (salesData["quarter"] == prev_quarter)]
    comparison_label = f"vs Q{prev_quarter} {prev_year}"
else:
    # Previous year, same quarter(s)
    prev_year = year - 1
    prev_data = salesData[(salesData["orderDate"].dt.year == prev_year)]
    if quarter:
        prev_data = prev_data[prev_data["quarter"].isin(quarter)]
    comparison_label = f"vs {prev_year}"

# Calculate metrics for previous period
prev_sales = prev_data["totalSales"].sum()
prev_freight = prev_data["freight"].sum()
prev_customers = prev_data["customerID"].nunique()
prev_quantity = prev_data["quantity"].sum()
prev_orders = prev_data["orderID"].nunique()
prev_avg_order_value = prev_sales / prev_orders if prev_orders > 0 else 0

# Calculate percent changes
sales_change = ((current_sales - prev_sales) / prev_sales * 100) if prev_sales > 0 else 0
freight_change = ((current_freight - prev_freight) / prev_freight * 100) if prev_freight > 0 else 0
customer_change = ((current_customers - prev_customers) / prev_customers * 100) if prev_customers > 0 else 0
quantity_change = ((current_quantity - prev_quantity) / prev_quantity * 100) if prev_quantity > 0 else 0
orders_change = ((current_orders - prev_orders) / prev_orders * 100) if prev_orders > 0 else 0
aov_change = ((current_avg_order_value - prev_avg_order_value) / prev_avg_order_value * 100) if prev_avg_order_value > 0 else 0

# Display KPI metrics
kpi1, kpi2, kpi3 = st.columns(3)
kpi4, kpi5, kpi6 = st.columns(3)

kpi1.metric("Total Sales", f"${current_sales:,.2f}", f"{sales_change:+.1f}% {comparison_label}")
kpi2.metric("Total Orders", f"{current_orders:,}", f"{orders_change:+.1f}% {comparison_label}")
kpi3.metric("Avg Order Value", f"${current_avg_order_value:,.2f}", f"{aov_change:+.1f}% {comparison_label}")
kpi4.metric("Total Freight", f"${current_freight:,.2f}", f"{freight_change:+.1f}% {comparison_label}")
kpi5.metric("Unique Customers", f"{current_customers:,}", f"{customer_change:+.1f}% {comparison_label}")
kpi6.metric("Total Quantity", f"{current_quantity:,}", f"{quantity_change:+.1f}% {comparison_label}")

# Sales Over Time (Monthly Trend)
st.markdown("## :chart_with_upwards_trend: Sales Over Time")

# Monthly trends
# First, create named columns for the groupby
filtered_data["year_col"] = filtered_data["orderDate"].dt.year
filtered_data["month_col"] = filtered_data["orderDate"].dt.month

# Then use these named columns
monthly_sales = filtered_data.groupby(["year_col", "month_col"]).agg({
    "totalSales": "sum",
    "orderID": pd.Series.nunique,
    "quantity": "sum"
}).reset_index()
monthly_sales.columns = ["Year", "Month", "Total Sales", "Order Count", "Quantity"]
monthly_sales["Month Name"] = monthly_sales["Month"].apply(lambda x: calendar.month_abbr[x])
monthly_sales["YearMonth"] = monthly_sales["Year"].astype(str) + "-" + monthly_sales["Month"].astype(str).str.zfill(2)
monthly_sales = monthly_sales.sort_values("YearMonth")

# Create tabs for different time series views
time_series_tabs = st.tabs(["Monthly Sales", "Quarterly Sales", "Cumulative Growth"])

with time_series_tabs[0]:
    fig1 = px.line(monthly_sales, x="Month Name", y="Total Sales", 
                   title=f"Monthly Sales Trend for {year}",
                   markers=True, template="plotly_white", 
                   custom_data=["Order Count", "Quantity"])
    fig1.update_layout(xaxis_title="Month", yaxis_title="Sales ($)")
    fig1.update_traces(
        hovertemplate="<b>%{x}</b><br>Sales: $%{y:,.2f}<br>Orders: %{customdata[0]}<br>Quantity: %{customdata[1]}"
    )
    st.plotly_chart(fig1, use_container_width=True)

with time_series_tabs[1]:
    quarterly_sales = filtered_data.groupby([filtered_data["orderDate"].dt.year, filtered_data["quarter"]]).agg({
        "totalSales": "sum",
        "orderID": pd.Series.nunique
    }).reset_index()
    quarterly_sales.columns = ["Year", "Quarter", "Total Sales", "Order Count"]
    quarterly_sales["Quarter Label"] = "Q" + quarterly_sales["Quarter"].astype(str)
    
    fig_q = px.bar(quarterly_sales, x="Quarter Label", y="Total Sales", 
                   title=f"Quarterly Sales for {year}",
                   text_auto=True, template="plotly_white")
    fig_q.update_layout(xaxis_title="Quarter", yaxis_title="Sales ($)")
    st.plotly_chart(fig_q, use_container_width=True)

with time_series_tabs[2]:
    # Calculate cumulative growth
    monthly_sales["Cumulative Sales"] = monthly_sales["Total Sales"].cumsum()
    
    fig_cum = px.area(monthly_sales, x="Month Name", y="Cumulative Sales", 
                     title=f"Cumulative Sales Growth for {year}",
                     template="plotly_white")
    fig_cum.update_layout(xaxis_title="Month", yaxis_title="Cumulative Sales ($)")
    st.plotly_chart(fig_cum, use_container_width=True)

# Create two columns for product and customer analysis
col1, col2 = st.columns(2)

with col1:
    # Top 10 Products by Sales
    st.markdown("### :trophy: Top 10 Products by Sales")
    productSales = filtered_data.groupby(["productName"])["totalSales"].sum().reset_index()
    productSales = productSales.sort_values(by="totalSales", ascending=False).head(10)
    
    fig2 = px.bar(productSales, x="totalSales", y="productName", 
                 title="Top Products", template="plotly_white", 
                 orientation='h', text_auto='.2s')
    fig2.update_layout(yaxis=dict(autorange="reversed"), xaxis_title="Sales ($)", yaxis_title="")
    st.plotly_chart(fig2, use_container_width=True)

with col2:
    # Customer Distribution
    st.markdown("### :earth_americas: Customers by Country")
    customerSales = filtered_data.groupby("customerID")["totalSales"].sum().reset_index()
    customerData = pd.merge(customerSales, customers, on="customerID", how="left")
    countryData = customerData.groupby("country").agg({
        "totalSales": "sum",
        "customerID": "count"
    }).reset_index()
    countryData.columns = ["Country", "Total Sales", "Customer Count"]
    countryData = countryData.sort_values(by="Total Sales", ascending=False)
    
    country_tabs = st.tabs(["Sales by Country", "Customer Count"])
    
    with country_tabs[0]:
        fig3a = px.bar(countryData.head(10), x="Country", y="Total Sales", 
                      title="Top Countries by Sales", template="plotly_white", 
                      text_auto='.2s')
        st.plotly_chart(fig3a, use_container_width=True)
    
    with country_tabs[1]:
        fig3b = px.pie(countryData, names="Country", values="Customer Count", 
                      title="Customer Distribution", template="plotly_white")
        fig3b.update_traces(textposition='inside', textinfo='percent+label')
        st.plotly_chart(fig3b, use_container_width=True)

# Sales Performance Analysis
st.markdown("## :bar_chart: Sales Performance Analysis")

performance_tabs = st.tabs(["Sales by Employee", "Sales by Category", "Shipping Analysis"])

with performance_tabs[0]:
    # Sales by Employee
    salesByEmployee = filtered_data.groupby("employeeName").agg({
        "totalSales": "sum",
        "orderID": pd.Series.nunique
    }).reset_index()
    salesByEmployee["Average Order Value"] = salesByEmployee["totalSales"] / salesByEmployee["orderID"]
    salesByEmployee = salesByEmployee.sort_values(by="totalSales", ascending=False)
    
    fig4 = px.bar(salesByEmployee, x="employeeName", y="totalSales", 
                 title="Sales per Employee", template="plotly_white", 
                 text_auto='.2s', custom_data=["orderID", "Average Order Value"])
    fig4.update_traces(
        hovertemplate="<b>%{x}</b><br>Sales: $%{y:,.2f}<br>Orders: %{customdata[0]}<br>Avg Order: $%{customdata[1]:,.2f}"
    )
    fig4.update_layout(xaxis_title="Employee", yaxis_title="Sales ($)")
    st.plotly_chart(fig4, use_container_width=True)

with performance_tabs[1]:
    # Sales by Category (if categories.csv is available)
    if categories is not None and 'categoryID' in products.columns:
        # Join products with categories
        products_with_cat = pd.merge(products, categories, on="categoryID", how="left")
        # Join sales data with product categories
        category_sales = pd.merge(filtered_data, products_with_cat, on="productID", how="left")
        # Group by category
        category_sales = category_sales.groupby("categoryName").agg({
            "totalSales": "sum",
            "productID": pd.Series.nunique
        }).reset_index()
        category_sales = category_sales.sort_values(by="totalSales", ascending=False)
        
        fig_cat = px.pie(category_sales, names="categoryName", values="totalSales", 
                       title="Sales by Product Category", template="plotly_white",
                       hole=0.4)
        fig_cat.update_traces(textposition='inside', textinfo='percent+label')
        st.plotly_chart(fig_cat, use_container_width=True)
    else:
        st.info("Category analysis is not available. Make sure you have a categories.csv file with proper mapping to products.")

with performance_tabs[2]:
    # Orders by Shipping Company - FIXED to use company names instead of IDs
    st.markdown("### :package: Orders by Shipping Company")
    
    shipMethodDist = filtered_data.groupby("shipperName").agg({
        "orderID": pd.Series.nunique,
        "totalSales": "sum",
        "freight": "sum"
    }).reset_index()
    shipMethodDist.columns = ["Shipping Company", "Order Count", "Sales Value", "Freight Cost"]
    shipMethodDist["Freight Percentage"] = (shipMethodDist["Freight Cost"] / shipMethodDist["Sales Value"] * 100).round(2)
    
    shipper_tabs = st.tabs(["Order Distribution", "Freight Analysis"])
    
    with shipper_tabs[0]:
        fig5 = px.pie(shipMethodDist, names="Shipping Company", values="Order Count", 
                     title="Orders by Shipping Company", template="plotly_white")
        fig5.update_traces(textposition='inside', textinfo='percent+label')
        st.plotly_chart(fig5, use_container_width=True)
    
    with shipper_tabs[1]:
        fig_freight = px.bar(shipMethodDist, x="Shipping Company", y=["Sales Value", "Freight Cost"], 
                           title="Sales Value vs Freight Cost by Shipper", template="plotly_white",
                           barmode="group")
        st.plotly_chart(fig_freight, use_container_width=True)
        
        # Display freight as percentage of sales
        st.markdown("### Freight as Percentage of Sales")
        fig_pct = px.bar(shipMethodDist, x="Shipping Company", y="Freight Percentage", 
                        title="Freight Cost as % of Sales", template="plotly_white",
                        text_auto=True)
        fig_pct.update_layout(yaxis_title="Freight %", xaxis_title="Shipping Company")
        st.plotly_chart(fig_pct, use_container_width=True)

# Additional Business Insights
st.markdown("## :bulb: Additional Insights")

insight_tabs = st.tabs(["Discount Analysis", "Order Fulfillment", "Seasonal Patterns"])

with insight_tabs[0]:
    # Discount Effect Analysis
    discount_analysis = filtered_data.copy()
    discount_analysis["discount_bin"] = pd.cut(
        discount_analysis["discount"], 
        bins=[0, 0.05, 0.1, 0.15, 0.2, 0.25, 1], 
        labels=["0-5%", "5-10%", "10-15%", "15-20%", "20-25%", "Over 25%"]
    )
    
    discount_summary = discount_analysis.groupby("discount_bin").agg({
        "orderID": pd.Series.nunique,
        "totalSales": "sum",
        "quantity": "sum"
    }).reset_index()
    
    discount_summary.columns = ["Discount Range", "Order Count", "Sales", "Quantity"]
    discount_summary["Avg Order Value"] = discount_summary["Sales"] / discount_summary["Order Count"]
    discount_summary["Avg Quantity per Order"] = discount_summary["Quantity"] / discount_summary["Order Count"]
    
    fig_disc = px.bar(discount_summary, x="Discount Range", y="Order Count", 
                     title="Orders by Discount Range",
                     template="plotly_white", text_auto=True)
    st.plotly_chart(fig_disc, use_container_width=True)
    
    fig_disc_value = px.line(discount_summary, x="Discount Range", y=["Avg Order Value", "Avg Quantity per Order"], 
                            title="Effect of Discounts on Order Value and Quantity",
                            template="plotly_white", markers=True)
    st.plotly_chart(fig_disc_value, use_container_width=True)

with insight_tabs[1]:
    # Order Fulfillment Analysis
    if "requiredDate" in orders.columns and "shippedDate" in orders.columns:
        fulfillment = orders[["orderID", "orderDate", "requiredDate", "shippedDate"]].copy()
        fulfillment["orderDate"] = pd.to_datetime(fulfillment["orderDate"])
        fulfillment["requiredDate"] = pd.to_datetime(fulfillment["requiredDate"])
        fulfillment["shippedDate"] = pd.to_datetime(fulfillment["shippedDate"])
        
        # Calculate fulfillment times and early/late deliveries
        fulfillment["processing_time"] = (fulfillment["shippedDate"] - fulfillment["orderDate"]).dt.days
        fulfillment["fulfillment_status"] = np.where(
            fulfillment["shippedDate"] <= fulfillment["requiredDate"], 
            "On Time", 
            "Late"
        )
        
        # Filter to current year
        fulfillment = fulfillment[fulfillment["orderDate"].dt.year == year]
        
        # On-time fulfillment rate
        ontime_rate = (fulfillment["fulfillment_status"] == "On Time").mean() * 100
        
        st.metric("On-Time Delivery Rate", f"{ontime_rate:.1f}%")
        
        # Processing time distribution
        fig_proc = px.histogram(fulfillment, x="processing_time", 
                              title="Order Processing Time Distribution (Days)",
                              template="plotly_white", nbins=10)
        st.plotly_chart(fig_proc, use_container_width=True)
        
        # Fulfillment status pie chart
        status_counts = fulfillment["fulfillment_status"].value_counts().reset_index()
        status_counts.columns = ["Status", "Count"]
        
        fig_status = px.pie(status_counts, names="Status", values="Count", 
                          title="Order Fulfillment Status", template="plotly_white")
        st.plotly_chart(fig_status, use_container_width=True)
    else:
        st.info("Order fulfillment analysis requires requiredDate and shippedDate columns in the orders dataset.")

with insight_tabs[2]:
    # Seasonal Patterns
    if len(year_options) > 1:
        # Multi-year analysis
        multi_year = salesData.copy()
        multi_year["year_col"] = multi_year["orderDate"].dt.year
        multi_year["month_col"] = multi_year["orderDate"].dt.month
        
        # Then use these named columns in the groupby
        monthly_pattern = multi_year.groupby(["year_col", "month_col"]).agg({"totalSales": "sum"}).reset_index()
        monthly_pattern.columns = ["Year", "Month", "Sales"]
        monthly_pattern["Month Name"] = monthly_pattern["Month"].apply(lambda x: calendar.month_abbr[x])
        
        # Pivot for comparison
        seasonal_pivot = monthly_pattern.pivot(index="Month", columns="Year", values="Sales").reset_index()
        seasonal_pivot["Month Name"] = seasonal_pivot["Month"].apply(lambda x: calendar.month_abbr[x])
        
        # Melt for plotting
        plot_data = pd.melt(seasonal_pivot, id_vars=["Month", "Month Name"], var_name="Year", value_name="Sales")
        plot_data = plot_data.sort_values(["Year", "Month"])
        
        fig_seasonal = px.line(plot_data, x="Month Name", y="Sales", color="Year",
                             title="Monthly Sales Pattern Across Years",
                             template="plotly_white", markers=True)
        fig_seasonal.update_layout(xaxis_title="Month", yaxis_title="Sales ($)")
        st.plotly_chart(fig_seasonal, use_container_width=True)
    else:
        st.info("Seasonal pattern analysis requires data from multiple years.")

# Footer
st.markdown("---")
st.caption("Northwind Traders Dashboard | ITI Graduation Project")