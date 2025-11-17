-- table creation
CREATE DATABASE zepto_project;

CREATE TABLE zepto(
    category VARCHAR(120),
    name VARCHAR(150) NOT NULL,
    mrp NUMERIC(8,2),
    discountPercent NUMERIC(5,2),
    availableQuantity INT,
    discountedSellingPrice NUMERIC(8,2),
    weightInGms INT,
    outOfStock BOOLEAN,
    quantity INT
);

-- data exploration

-- count of rows
SELECT
    count(*)
FROM zepto;

-- null values
SELECT * FROM zepto
WHERE 
    category IS NULL OR
    name IS NULL OR
    mrp IS NULL OR
    discountPercent IS NULL OR
    discountedSellingPrice IS NULL OR
    weightInGms IS NULL OR
    availableQuantity IS NULL OR
    outOfStock IS NULL OR
    quantity IS NULL;

-- different product categories
SELECT 
    DISTINCT category
FROM zepto
ORDER BY category;

-- product names present multiple times
SELECT
    name,
    count(*) AS Total_count
FROM zepto
GROUP BY name
HAVING count(*)>1
ORDER BY count(*) DESC;

-- data cleaning

-- products with price 0
SELECT * FROM zepto
WHERE
    mrp=0 OR
    discountedSellingPrice=0;
    
DELETE FROM zepto WHERE mrp=0;

-- data analysis

-- Q1. Find the top 20 products based on the highest discount percentage.
SELECT
    name,
    category,
    mrp,
    discountedSellingPrice,
    discountPercent,
    (mrp - discountedSellingPrice) AS discount_amount
FROM zepto
WHERE discountPercent > 20 AND outOfStock = 'FALSE'
ORDER BY discountPercent DESC
LIMIT 20;

-- Q2.What are the Products with High MRP but Out of Stock

SELECT
    DISTINCT name,
    category,
    mrp,
    discountedSellingPrice,
    discountPercent
FROM zepto
WHERE outOfStock = 'TRUE' AND mrp > 300
ORDER BY mrp DESC;

-- Q3.Calculate Total Revenue and average selling price for each category. 
SELECT
    category,
    COUNT(*) AS total_products,
    SUM(discountedSellingPrice * availableQuantity) AS total_revenue,
    AVG(discountedSellingPrice) AS avg_selling_price
FROM zepto
GROUP BY category
ORDER BY total_revenue DESC; 

-- Q4.Find all products where MRP is greater than ₹500 and discount is less than 10%.
SELECT
    DISTINCT name,
    mrp,
    discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;

-- Q5. Identify the top 5 categories offering the highest average discount percentage.
SELECT
    category,
    ROUND(AVG(discountPercent),2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

-- Q6. Find the price per gram for products above 100g and sort by best value.
SELECT
    DISTINCT name, 
    weightInGms,
    discountedSellingPrice,
    ROUND(discountedSellingPrice/weightInGms,2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;

-- Q7.Group the products into categories like Low, Medium, Bulk.
SELECT
    DISTINCT name,
    weightInGms,
    CASE
        WHEN weightInGms < 1000 THEN 'Low'
        WHEN weightInGms < 5000 THEN 'Medium'
    ELSE 'Bulk'
    END AS weight_category
FROM zepto;

-- Q8.What is the Total Inventory Weight Per Category 
SELECT
    category,
    SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight;

-- Q9. Find the availability of stock rate in inventory. 
SELECT
    category,
    COUNT(*) AS total_products,
    SUM(CASE WHEN availableQuantity >= 5 THEN 1 ELSE 0 END) AS well_stocked,
    SUM(CASE WHEN availableQuantity BETWEEN 1 AND 4 THEN 1 ELSE 0 END) AS low_stock,
    SUM(CASE WHEN outOfStock = TRUE THEN 1 ELSE 0 END) AS out_of_stock,
    ROUND(SUM(CASE WHEN availableQuantity >= 5 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS stock_rate
FROM zepto
GROUP BY category
ORDER BY stock_rate DESC;

-- Q10. Check the discount percentage impact on sales of products in stock. 
SELECT
    CASE 
        WHEN discountPercent = 0 THEN 'No Discount'
        WHEN discountPercent BETWEEN 1 AND 10 THEN 'Low (1-10%)'
        WHEN discountPercent BETWEEN 11 AND 20 THEN 'Medium (11-20%)'
        WHEN discountPercent > 20 THEN 'High (>20%)'
    END AS discount_level,
    COUNT(*) AS product_count,
    SUM(discountedSellingPrice * quantity) AS total_revenue
FROM zepto
WHERE outOfStock = 'FALSE'
GROUP BY discount_level
ORDER BY total_revenue DESC;


-- Q11. Top 3 revenue-generating products for every category,but only where products are in stock.
WITH category_rankings AS (
    SELECT 
        category,
        name,
        discountedSellingPrice * quantity AS revenue,
        discountPercent,
        availableQuantity,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY discountedSellingPrice * quantity DESC) AS rank_number
    FROM zepto
    WHERE outOfStock = 'FALSE'
)
SELECT * 
FROM category_rankings 
WHERE rank_number <= 3
ORDER BY category, rank_number;

-- Q12. Find  the top 10 best selling products by revenue.
SELECT 
    name,
    category,
    discountedSellingPrice * quantity AS revenue,
    quantity,
    availableQuantity,
    discountPercent
FROM zepto
WHERE outOfStock = 0
ORDER BY revenue DESC
LIMIT 10;

