-- Task 1: Data Cleaning & Preparation--

                                               -- 1.● Identify and delete duplicate Order_ID records--
SELECT order_id, COUNT(*) AS cnt
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

                                   -- #2.● Replace null Traffic_Delay_Min with the average delay for that route.--
SELECT *
FROM routes
WHERE Traffic_Delay_Min IS NULL;

SET SQL_SAFE_UPDATES = 0;
UPDATE routes r
JOIN (
SELECT route_id, AVG(Traffic_Delay_Min) AS average_delay
FROM routes
WHERE Traffic_Delay_Min IS NOT NULL
GROUP BY  route_id
) t
ON r.route_id = t.route_id

SET r.traffic_delay_min = t.average_delay
WHERE r.traffic_delay_min IS NULL;

                                         -- 3.● Convert all date columns into YYYY-MM-DD format using SQL functions.--
                                                         -- a. Verifying current Date format --
SELECT order_date, expected_delivery_date, actual_delivery_date
FROM orders
LIMIT 3;

														-- b. Converting format (if stored as STRING) --
UPDATE orders
SET Order_Date = STR_TO_DATE(Order_Date, '%d-%m-%Y'),
    Expected_Delivery_Date = STR_TO_DATE(Expected_Delivery_Date, '%d-%m-%Y'),
    Actual_Delivery_Date = STR_TO_DATE(Actual_Delivery_Date, '%d-%m-%Y');

 
                                      -- 4.● Ensure that no Actual_Delivery_Date is before Order_Date (flag such records).--
SELECT Order_id, Order_date, Actual_Delivery_Date, "INVALID DATE SEQUENCE" as ISSUE_FLAG 
FROM orders
WHERE Order_date> Actual_Delivery_Date;


-- TASK 2: Delivery Delay Analysis--

                                                  -- 1 ● Calculate delivery delay (in days) for each order.--
SELECT Order_id, Route_id, DATEDIFF(Expected_Delivery_Date, Actual_Delivery_Date) AS delivery_delay_days
FROM orders
GROUP BY Order_id, Route_id, delivery_delay_days
ORDER BY delivery_delay_days DESC;
-- Positive = delayed , Zero / negative = on time or early

                                                   -- 2 ● Find Top 10 delayed routes based on average delay days.--
SELECT Route_id, round(AVG(DATEDIFF(Expected_Delivery_Date, Actual_Delivery_Date))) AS avg_delay_days
FROM orders
GROUP BY Route_id 
ORDER  BY avg_delay_days DESC
LIMIT 10; 

                                           -- 3 ● Use window functions to rank all orders by delay within each warehouse--
SELECT Order_id, Warehouse_id, DATEDIFF(Expected_Delivery_Date, Actual_Delivery_Date) AS delivery_delay_days,
RANK() OVER ( PARTITION BY Warehouse_id
ORDER BY DATEDIFF(Expected_Delivery_Date, Actual_Delivery_Date) DESC
) AS delay_rank
FROM orders;

-- TASK 3: Route Optimization Insights

                                                         -- #1 ● For each route, calculate:
                                                       -- ○ Average delivery time (in days).--
                                                           -- ○ Average traffic delay. --
                                          -- ○ Distance-to-time efficiency ratio: Distance_KM / Average_Travel_Time_Min--
SELECT r.route_id, ROUND(AVG(DATEDIFF(o.actual_delivery_date, o.order_date))) AS avg_delivery_time_days,
ROUND(AVG(r.traffic_delay_min))  AS avg_traffic_delay_min,
ROUND(r.distance_km / r.average_travel_time_min, 3) AS distance_time_efficiency
FROM routes r
JOIN orders o
ON r.route_id = o.route_id
GROUP BY r.route_id, r.distance_km, r.average_travel_time_min ;

                                                   -- 2 ● Identify 3 routes with the worst efficiency ratio.--
SELECT Route_ID, ROUND(distance_km/ average_travel_time_min, 3) AS efficiency_ratio
FROM routes
ORDER BY efficiency_ratio ASC
LIMIT 3 ;

                                                       -- #3 ● Find routes with > 20% delayed shipments.--
SELECT route_id, ROUND( SUM(
CASE
WHEN actual_delivery_date > expected_delivery_date 
THEN 1 ELSE 0 
END ) * 100 / COUNT(*), 2) AS delayed_percentage -- SUM(delayed) * 100 / COUNT(*)
FROM orders
GROUP BY route_id
HAVING delayed_percentage > 20;

                                                         -- #4 ● Recommend potential routes for optimization.--
SELECT route_id, ROUND(AVG(DATEDIFF(actual_delivery_date, order_date)), 2) 
AS avg_delivery_time_days,
ROUND( SUM( CASE
WHEN actual_delivery_date > expected_delivery_date 
THEN 1 ELSE 0 
END) * 100.0 / COUNT(*), 2) AS delayed_percentage
FROM orders
GROUP BY route_id
HAVING avg_delivery_time_days >
(SELECT AVG(DATEDIFF(actual_delivery_date, order_date)) FROM orders)
AND delayed_percentage > 20
ORDER BY avg_delivery_time_days DESC;

-- TASK 4: Warehouse Performance
                                            -- #1 ● Find the top 3 warehouses with the highest average processing time.--
SELECT warehouse_id, ROUND(AVG(processing_time_min), 2) AS avg_processing_time_min
FROM warehouses
GROUP BY warehouse_id
ORDER BY avg_processing_time_min DESC
LIMIT 3;

                                               -- #2 ● Calculate total vs.delayed shipments for each warehouse.--
SELECT o.warehouse_id, COUNT(*) AS total_shipments,
SUM(
CASE
WHEN o.actual_delivery_date > o.expected_delivery_date
THEN 1 ELSE 0
END ) AS delayed_shipments
FROM orders o
GROUP BY o.warehouse_id;

                                            -- #3 ● Use CTEs to find bottleneck warehouses where processing time > global average.--
WITH average_processing AS
(SELECT AVG(processing_time_min) AS global_average_processing_time
FROM warehouses
)
SELECT w.warehouse_id, w.processing_time_min
FROM warehouses w 
JOIN  average_processing a
ON w.Processing_Time_Min> a. global_average_processing_time;


                                                    -- ● Rank warehouses based on on-time delivery percentage.--
SELECT warehouse_id,
ROUND( SUM(
CASE
WHEN actual_delivery_date <= expected_delivery_date
THEN 1 ELSE 0
END ) * 100.0 / COUNT(*), 2
) AS on_time_percentage,
RANK() OVER (
ORDER BY SUM(
CASE
WHEN actual_delivery_date <= expected_delivery_date
THEN 1 ELSE 0
END
) * 1.0 / COUNT(*) DESC ) AS warehouse_rank
FROM orders
GROUP BY warehouse_id;                       

-- TASK 5: Delivery Agent Performance

                                              -- #1 ● Rank agents (per route) by on-time delivery percentage.--
SELECT agent_id, route_id, on_time_percentage,
RANK() OVER (PARTITION BY route_id ORDER BY on_time_percentage DESC) AS agent_rank
FROM deliveryagents;

                                                      -- #2 ● Find agents with on-time % < 80%.--
SELECT agent_id, route_id, on_time_percentage
FROM deliveryagents
WHERE on_time_percentage < 80;

                                           -- #3 ● Compare avera14144ge speed of top 5 vs bottom 5 agents using subqueries.--
SELECT 'Top 5 Agents' AS agent_group, ROUND(AVG(avg_speed_km_hr), 2) AS avg_speed
FROM ( SELECT avg_speed_km_hr
FROM deliveryagents
ORDER BY on_time_percentage DESC
LIMIT 5) a
UNION ALL
SELECT 'Bottom 5 Agents' AS agent_group, ROUND(AVG(avg_speed_km_hr), 2) AS avg_speed
FROM (SELECT avg_speed_km_hr
FROM deliveryagents
ORDER BY on_time_percentage ASC
LIMIT 5) b;

-- TASK 6: Shipment Tracking Analytics

                                               -- #1 ● For each order, list the last checkpoint and time.--
# GROUP BY order_id, checkpoint, checkpoint_time → this groups every unique row So nothing is reduced You still get multiple rows per order

# approach 1
SELECT st.order_id, st.checkpoint, st.checkpoint_time
FROM `shipment tracking table` st
JOIN (
SELECT order_id, MAX(checkpoint_time) AS last_checkpoint_time
FROM `shipment tracking table`
GROUP BY order_id
) last_cp
ON st.order_id = last_cp.order_id
AND st.checkpoint_time = last_cp.last_checkpoint_time;

# approach 2
SELECT order_id, checkpoint, checkpoint_time
FROM ( SELECT order_id, checkpoint, checkpoint_time,
ROW_NUMBER() OVER ( PARTITION BY order_id
ORDER BY checkpoint_time DESC, shipment_id DESC
) AS rn
FROM `shipment tracking table`
) t
WHERE rn = 1;

                                                 -- #2 ● Find the most common delay reasons (excluding None).--
SELECT delay_reason, COUNT(*) AS occurrence_count
FROM `shipment tracking table`
WHERE delay_reason IS NOT NULL
GROUP BY delay_reason
ORDER BY occurrence_count DESC;

                                                   -- #3 ● Identify orders with >2 delayed checkpoints--
SELECT order_id, COUNT(*) AS delayed_checkpoint_count
FROM `shipment tracking table`
WHERE delay_reason IS NOT NULL
GROUP BY order_id
HAVING COUNT(*) > 2;

-- TASK 7: Advanced KPI Reporting
                                                          -- Calculate KPIs using SQL queries:--

                                                -- ● #1. Average Delivery Delay per Region (Start_Location).--
SELECT r.start_location, ROUND(AVG(DATEDIFF(o.actual_delivery_date, o.expected_delivery_date)), 2) AS avg_delivery_delay_days
FROM orders o
JOIN routes r
ON o.route_id = r.route_id
GROUP BY r.start_location;

                                          -- ● #2. On-Time Delivery % = (Total On-Time Deliveries / Total Deliveries) * 100.--
SELECT ROUND(SUM (
CASE
WHEN actual_delivery_date <= expected_delivery_date
THEN 1 ELSE 0
END ) * 100.0 / COUNT(*), 2) AS on_time_delivery_percentage
FROM orders;

                                                       -- ● #3. Average Traffic Delay per Route.--
SELECT route_id, ROUND(AVG(traffic_delay_min), 2) AS avg_traffic_delay_min
FROM routes
GROUP BY route_id;

                                             -- ● #4. CREATE A VIEW TO VIEW IT IN POWER BI--
CREATE VIEW view_order_performance AS
SELECT
    o.order_id,
    o.order_date,
    o.expected_delivery_date,
    o.actual_delivery_date,

    o.route_id,
    r.distance_km,
    r.average_travel_time_min,
    r.traffic_delay_min,
    r.start_location,
    r.end_location,

    o.warehouse_id,
    w.processing_time_min,
    w.location AS warehouse_location,

    a.agent_id,
    a.avg_speed_km_hr,

    DATEDIFF(o.actual_delivery_date, o.expected_delivery_date) AS delay_days,

    CASE 
        WHEN o.actual_delivery_date <= o.expected_delivery_date THEN 1
        ELSE 0
    END AS on_time_flag

FROM orders o
LEFT JOIN routes r ON o.route_id = r.route_id
LEFT JOIN warehouses w ON o.warehouse_id = w.warehouse_id
LEFT JOIN deliveryagents a ON r.route_id = a.route_id;