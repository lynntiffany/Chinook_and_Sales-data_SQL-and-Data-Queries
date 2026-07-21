-- Understand Dataset
SHOW TABLES;

DESCRIBE sales;

SELECT *
FROM sales
LIMIT 5;

SELECT COUNT(*) AS total_rows
FROM sales;

-- Check Missing Values
SELECT
    SUM(CASE WHEN ORDERNUMBER IS NULL THEN 1 ELSE 0 END) AS missing_order_number,
    SUM(CASE WHEN ORDERDATE IS NULL THEN 1 ELSE 0 END) AS missing_order_date,
    SUM(CASE WHEN CUSTOMERNAME IS NULL THEN 1 ELSE 0 END) AS missing_customer,
    SUM(CASE WHEN PRODUCTCODE IS NULL THEN 1 ELSE 0 END) AS missing_product,
    SUM(CASE WHEN SALES IS NULL THEN 1 ELSE 0 END) AS missing_sales,
    SUM(CASE WHEN COUNTRY IS NULL THEN 1 ELSE 0 END) AS missing_country
FROM sales;

-- Check Duplicate Records
SELECT
    ORDERNUMBER,
    ORDERLINENUMBER,
    PRODUCTCODE,
    COUNT(*) AS duplicate_count
FROM sales
GROUP BY
    ORDERNUMBER,
    ORDERLINENUMBER,
    PRODUCTCODE
HAVING COUNT(*) > 1;

SELECT ORDERDATE
FROM sales
LIMIT 5;

-- Convert orderdate to proper date
ALTER TABLE sales
ADD COLUMN order_date DATE;

UPDATE sales
SET order_date = STR_TO_DATE(ORDERDATE, '%m/%d/%Y %H:%i');

SELECT ORDERDATE, order_date
FROM sales
LIMIT 5;

-- Select/ Where/ Order by

SELECT
    ORDERNUMBER,
    CUSTOMERNAME,
    PRODUCTLINE,
    SALES
FROM sales;

-- Sales made in the USA
SELECT
    ORDERNUMBER,
    CUSTOMERNAME,
    COUNTRY,
    SALES
FROM sales
WHERE COUNTRY = 'USA';

-- Sales amount exceed 5000
SELECT
    ORDERNUMBER,
    CUSTOMERNAME,
    SALES
FROM sales
WHERE SALES > 5000;

-- Highest Revenue generating orders in 2004
SELECT
    ORDERNUMBER,
    CUSTOMERNAME,
    PRODUCTLINE,
    SALES as REVENUE
FROM sales
WHERE YEAR_ID = 2004
ORDER BY SALES DESC
LIMIT 10;

-- Total Revenue by Country
SELECT
    COUNTRY,
    ROUND(SUM(SALES),2) AS total_revenue
FROM sales
GROUP BY COUNTRY
ORDER BY total_revenue DESC;

-- Total Revenue by Product Line
SELECT
    PRODUCTLINE,
    ROUND(SUM(SALES),2) AS total_revenue
FROM sales
GROUP BY PRODUCTLINE
ORDER BY total_revenue DESC;

-- Countries with revenue above 500000
SELECT
    COUNTRY,
    ROUND(SUM(SALES),2) AS total_revenue
FROM sales
GROUP BY COUNTRY
HAVING SUM(SALES) > 500000
ORDER BY total_revenue DESC;

-- Product lines with more than 100 transactions
SELECT
    PRODUCTLINE,
    COUNT(*) AS total_orders
FROM sales
GROUP BY PRODUCTLINE
HAVING COUNT(*) > 100;

-- Average sales by dealsize
SELECT
    DEALSIZE,
    ROUND(AVG(SALES), 2) AS average_sales
FROM sales
GROUP BY DEALSIZE
ORDER BY average_sales DESC;

-- Which customers spent more than the average customer revenue?
SELECT
    CUSTOMERNAME,
    SUM(SALES) AS total_revenue
FROM sales
GROUP BY CUSTOMERNAME
HAVING SUM(SALES) >
(
    SELECT AVG(customer_revenue)
    FROM (
        SELECT SUM(SALES) AS customer_revenue
        FROM sales
        GROUP BY CUSTOMERNAME
    ) AS customer_totals
)
ORDER BY total_revenue DESC;

-- Rank customers by total revenue
SELECT
    CUSTOMERNAME,
    SUM(SALES) AS total_revenue,
    RANK() OVER (ORDER BY SUM(SALES) DESC) AS customer_rank
FROM sales
GROUP BY CUSTOMERNAME;

-- Assign a unique row number to customers ranked by revenue.
SELECT
    CUSTOMERNAME,
    SUM(SALES) AS total_revenue,
    ROW_NUMBER() OVER (ORDER BY SUM(SALES) DESC) AS row_num
FROM sales
GROUP BY CUSTOMERNAME;

-- Rank customers within each country based on total revenue.
SELECT
    COUNTRY,
    CUSTOMERNAME,
    SUM(SALES) AS total_revenue,
    RANK() OVER (
        PARTITION BY COUNTRY
        ORDER BY SUM(SALES) DESC
    ) AS country_rank
FROM sales
GROUP BY COUNTRY, CUSTOMERNAME;

-- Revenue change over time
SELECT
    YEAR_ID,
    MONTH_ID,
    ROUND(SUM(SALES),2) AS monthly_revenue
FROM sales
GROUP BY YEAR_ID, MONTH_ID
ORDER BY YEAR_ID, MONTH_ID;

-- Highest revenue generating productlines
SELECT
    PRODUCTLINE,
    ROUND(SUM(SALES),2) AS total_revenue
FROM sales
GROUP BY PRODUCTLINE
ORDER BY total_revenue DESC;

-- 	Top 10 customers by revenue
SELECT
    CUSTOMERNAME,
    ROUND(SUM(SALES),2) AS total_revenue
FROM sales
GROUP BY CUSTOMERNAME
ORDER BY total_revenue DESC
LIMIT 10;

-- Customer purchasing behaviour
SELECT
    CUSTOMERNAME,
    COUNT(DISTINCT ORDERNUMBER) AS total_orders,
    ROUND(SUM(SALES),2) AS total_revenue
FROM sales
GROUP BY CUSTOMERNAME
ORDER BY total_orders DESC;

-- Create indices 
CREATE INDEX idx_customer
ON sales (CUSTOMERNAME(100));

CREATE INDEX idx_order
ON sales (ORDERNUMBER);

CREATE INDEX idx_productline
ON sales (PRODUCTLINE(50));
