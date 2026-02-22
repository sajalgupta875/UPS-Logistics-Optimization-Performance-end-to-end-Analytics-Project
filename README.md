# UPS-Logistics-Optimization-Performance-end-to-end-Analytics-Project
End-to-end logistics optimization dashboard built using MySQL and Power BI. Designed a star schema data model, developed advanced DAX measures, and created executive-level insights on route efficiency, warehouse performance, and delivery optimization. Includes SQL queries and interactive BI visuals.

📌 Project Overview:
This project presents an end-to-end logistics optimization and performance analysis dashboard built using MySQL and Power BI.
The objective was to analyze delivery efficiency, identify delay patterns, evaluate route performance, and assess warehouse operations using a structured business intelligence approach.
This case study demonstrates data modeling, SQL querying, DAX calculations, and interactive dashboard design.

🎯 Business Problem
Logistics operations face challenges such as:
Delivery delays
Route inefficiencies
Warehouse bottlenecks
Inconsistent on-time performance

The goal was to:
Measure on-time delivery rate
Analyze average delay across routes and warehouses
Identify worst-performing routes
Provide executive-level insights for operational improvement

🛠️ Tech Stack:
MySQL – Data storage & SQL querying
Power BI – Data modeling & dashboard development
DAX – Performance measures & KPIs
Star Schema Modeling – Optimized data model

🧱 Data Model
A structured star schema was implemented:
FactOrders – Order-level delivery data
FactShipmentTracking – Shipment event tracking
DimRoutes – Route details
DimWarehouses – Warehouse information
DimDeliveryAgents – Agent allocation data
Date Table – Time intelligence
The model ensures optimized filter propagation and analytical accuracy.

📊 Dashboard Pages-
1️⃣ Executive Overview:
Total Orders
On-Time %
Average Delay
Monthly Performance Trends

2️⃣ Route Performance:
On-Time % by Route
Average Delay by Route
Top 5 Worst Routes
Delay vs On-Time Scatter Analysis

3️⃣ Warehouse Performance:
Warehouse-level delay analysis
Order distribution by warehouse
On-Time % comparison

4️⃣ Agent Route Performance:
Agent allocation by route
Performance comparison (route-based evaluation)

📈 Key KPIs Developed:
Total Orders
Total On-Time Orders
On-Time %
Average Delay (Days)
Route Ranking (Worst Performing)

💡 Key Insights:
Certain routes contribute disproportionately to overall delays.
Warehouse processing time impacts delivery performance.
Route-level performance strongly influences overall on-time percentage.
Operational focus should be on high-volume routes with high delay rates.

🚀 Business Impact
This dashboard enables:
Data-driven route optimization
Warehouse efficiency monitoring
Performance benchmarking
Executive-level operational visibility
