-- SQL Script for Analyzing Superstore Sales
-- Assumes table 'superstore_sales' exists and is populated from 'global_superstore_clean.csv'

-- Question 1: Which product categories and sub-categories are the most/least profitable?
-- We'll use a Common Table Expression (CTE) for clarity.

WITH CategoryProfit AS (
    SELECT
        Category,
        Sub_Category,
        SUM(Profit) AS Total_Profit,
        SUM(Sales) AS Total_Sales,
        SUM(Quantity) AS Total_Quantity_Sold
    FROM
        superstore_sales
    GROUP BY
        Category, Sub_Category
)
SELECT
    Category,
    Sub_Category,
    Total_Profit,
    Total_Sales,
    Total_Quantity_Sold,
    -- Calculate Profit Margin for better comparison
    (Total_Profit / Total_Sales) * 100 AS Profit_Margin_Percent
FROM
    CategoryProfit
ORDER BY
    Total_Profit DESC; -- Order by most profitable

-- Question 2: How do discounts affect the quantity of products sold and the overall profit?
SELECT
    -- Create discount buckets for easier analysis
    CASE
        WHEN Discount = 0.0 THEN 'No Discount'
        WHEN Discount > 0.0 AND Discount <= 0.1 THEN '1-10%'
        WHEN Discount > 0.1 AND Discount <= 0.2 THEN '11-20%'
        WHEN Discount > 0.2 AND Discount <= 0.3 THEN '21-30%'
        ELSE 'Over 30%'
    END AS Discount_Bucket,
    COUNT(Order_ID) AS Number_of_Orders,
    SUM(Quantity) AS Total_Quantity_Sold,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    AVG(Profit) AS Average_Profit_Per_Order
FROM
    superstore_sales
GROUP BY
    Discount_Bucket
ORDER BY
    Discount_Bucket;

-- Question 4: Which regions are underperforming?
-- Let's find regions with below-average profit margins.

WITH RegionMetrics AS (
    SELECT
        Region,
        SUM(Sales) AS Total_Sales,
        SUM(Profit) AS Total_Profit
    FROM
        superstore_sales
    GROUP BY
        Region
),
OverallAvg AS (
    SELECT
        SUM(Total_Profit) / SUM(Total_Sales) * 100 AS Avg_Profit_Margin
    FROM
        RegionMetrics
)
SELECT
    rm.Region,
    rm.Total_Sales,
    rm.Total_Profit,
    (rm.Total_Profit / rm.Total_Sales) * 100 AS Regional_Profit_Margin,
    oa.Avg_Profit_Margin
FROM
    RegionMetrics rm, OverallAvg oa
WHERE
    (rm.Total_Profit / rm.Total_Sales) * 100 < oa.Avg_Profit_Margin -- Filter for underperforming regions
ORDER BY
    Regional_Profit_Margin ASC;
