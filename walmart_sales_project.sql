CREATE DATABASE walmartsales;
USE walmartsales;
CREATE TABLE salesdata (
invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
branch VARCHAR(5) NOT NULL,
city VARCHAR(30) NOT NULL,
customer_type VARCHAR(30) NOT NULL,
gender VARCHAR(10) NOT NULL,
product_line VARCHAR(100) NOT NULL,
unit_price DECIMAL(10, 2) NOT NULL,
quantity INT NOT NULL,
vat FLOAT(6, 4) NOT NULL,
total DECIMAL(12, 4),
date DATETIME NOT NULL,
time TIME NOT NULL,
payment_method VARCHAR(15) NOT NULL,
cogs DECIMAL(10, 2) NOT NULL,
gross_margin_percentage FLOAT(11, 9),
gross_income DECIMAL(12, 4),
rating FLOAT (2, 1)
);

-- feature engineering
-- time_of_day

SELECT time,
CASE WHEN `time` BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
	 WHEN `time` BETWEEN '02:01:00' AND '16:00:00' THEN 'Afternoon'
     ELSE 'Evening'
     END time_of_date
FROM salesdata;

ALTER TABLE salesdata ADD column time_of_day VARCHAR(20);

UPDATE salesdata
SET time_of_day = (CASE WHEN `time` BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
	 WHEN `time` BETWEEN '02:01:00' AND '16:00:00' THEN 'Afternoon'
     ELSE 'Evening'
     END);
     
-- day_name
SELECT  `date`,
dayname(`date`) day_name
FROM salesdata;

ALTER TABLE salesdata
ADD column day_name VARCHAR(10);

UPDATE salesdata
SET day_name = dayname(`date`);

-- month_name
SELECT  `date`,
monthname(`date`) month_name
FROM salesdata;

ALTER TABLE salesdata
ADD COLUMN month_name VARCHAR(10);

UPDATE salesdata
SET month_name = monthname(`date`);

-- -------------------------------------------------------------------------------------------------------------
-- -------------- Exploratory Data Analysis --------------------------------------------------------------------
-- Generic Questions to answer --------------
-- 1. How many unique cities does the data have?
SELECT DISTINCT city
FROM salesdata;

-- 2. In which city is each branch
SELECT DISTINCT city, branch
FROM salesdata;

-- ---------------------------- PRODUCT ---------------------------------------
-- 1. HOW MANY UNIQUE PRODUCT LINE DOES THE DATA HAVE
SELECT COUNT(DISTINCT product_line)
FROM salesdata;
-- 2. WHAT IS THE MOST COMMON PAYMENT METHOD
SELECT payment_method, count(payment_method) total_payment_method
FROM salesdata
GROUP BY payment_method
ORDER BY count(payment_method) DESC;
-- 3. WHAT IS THE MOST SELLING PRODUCT LINE
SELECT product_line, COUNT(product_line) most_selling
FROM salesdata
GROUP BY product_line
ORDER BY COUNT(product_line) DESC;
-- 4. WHAT IS THE TOTAL REVENUE BY MONTH
SELECT month_name, SUM(total) total_revenue
FROM salesdata
GROUP BY month_name
ORDER BY SUM(total) DESC;
-- 5. WHAT MONTH HAD THE LARGEST COGS (cost of goods)?
SELECT month_name, SUM(cogs) cogs_per_month
FROM salesdata
GROUP BY month_name
ORDER BY SUM(cogs) DESC;
-- 6. WHAT PRODUCT LINE HAD THE LARGEST REVENUE?
SELECT product_line, SUM(total) product_revenue
FROM salesdata
GROUP BY product_line
ORDER BY  SUM(total) DESC;
-- 7. WHAT IS THE CITY WITH THE LARGEST REVENUE
SELECT city, SUM(total) city_revenue
FROM salesdata
GROUP BY city
ORDER BY SUM(total) DESC;
-- 8. WHAT PRODUCT LINE HAD THE LARGEST VAT?
SELECT product_line, SUM(vat) product_line_vat
FROM salesdata
GROUP BY product_line
ORDER BY  SUM(vat) DESC;
-- 9. FECTH EACH PRODUCT LINE AND ADD A COLUMN TO THOSE LINE SHOWING 'GOOD', 'BAD'. GOOD IF IT IS > AVERAGE SALES
SELECT product_line, 
CASE	WHEN product_line > avg_sales THEN 'Good'
		ELSE 'Bad'
	END product_rating
    FROM (
SELECT product_line,
AVG(total) avg_sales
FROM salesdata
GROUP BY product_line, total) T;
-- 10. WHICH BRanch SOLD MORE PRODUCTS THAN AVERAGE PRODUCT SOLD
SELECT branch, avg(quantity)
FROM (
SELECT branch, quantity, sum(quantity)
FROM salesdata
GROUP BY branch, quantity)t
GROUP BY branch
HAVING sum(quantity) > avg(quantity);
-- 11. WHAT IS THE MOST COMMON PRODUCT LINE BY GENDER
SELECT gender, product_line, Count(GENDER) total_gender
FROM salesdata
GROUP BY  gender, product_line
ORDER BY Count(GENDER), gender, product_line DESC;

-- 12. what is the average rating of each product line?
SELECT product_line, AVG(rating) avg_rating
FROM salesdata
GROUP BY product_line
ORDER BY AVG(rating) DESC;
-- ==========================================================
-- -------------------- Sales --------------------------------
-- Number of sales made in each time of the day per weekday
SELECT time_of_day, Count(total) totat_sales
FROM salesdata
GROUP BY time_of_day
ORDER BY Count(total) DESC;
-- Which of the customer types brings the most revenue?
SELECT customer_type, SUM(total) total_revenue
FROM salesdata
GROUP BY customer_type
ORDER BY SUM(total);
-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT city, sum(vat) highest_vat
FROM salesdata
GROUP BY city
ORDER BY sum(vat) DESC;
--  Which customer type pays the most in VAT?
SELECT customer_type, sum(vat) highest_vat
FROM salesdata
GROUP BY customer_type
ORDER BY sum(vat) DESC;
-- ===========================================================================
-- --------------Customer--------------------------------------------------
-- How many unique customer types does the data have?
SELECT DISTINCT customer_type
FROM salesdata;
-- How many unique payment methods does the data have?
SELECT DISTINCT payment_method
FROM salesdata;
-- What is the most common customer type?
SELECT customer_type, count(*) customer_per_type
FROM salesdata
GROUP BY customer_type
ORDER BY count(*) DESC;
-- Which customer type buys the most?
SELECT customer_type, count(quantity) total_quantity
FROM salesdata
GROUP BY customer_type
ORDER BY COUNT(quantity) desc;
-- What is the gender of most of the customers?
SELECT gender, count(*) gender_total
FROM salesdata
GROUP BY gender
ORDER BY count(gender) DESC;
-- What is the gender distribution per branch?
SELECT branch, count(gender) gender_count
FROM salesdata
GROUP BY branch;
-- Which time of the day do customers give most ratings?
SELECT time_of_day, avg(rating) avg_rating
FROM salesdata
GROUP BY time_of_day
ORDER BY count(rating) DESC;
-- Which time of the day do customers give most ratings per branch?
SELECT distinct branch, time_of_day, avg(rating) avg_rating
FROM salesdata
WHERE branch = 'A' -- branch = 'b' -- use the where clause to check for each branch
GROUP BY time_of_day, branch
ORDER BY count(rating) DESC;
-- Which day OF the week has the best avg ratings?
SELECT day_name, avg(rating) avg_rating
FROM salesdata
GROUP BY day_name
ORDER BY avg(rating) DESC; 
-- Which day of the week has the best average ratings per branch?

SELECT branch, day_name, avg(rating) avg_rating
FROM salesdata
WHERE branch = 'C' -- do for other branches
GROUP BY day_name, branch
ORDER BY avg(rating) DESC
LIMIT 1; -- Limit help us to choose the 1 day with the highest rating. Friday for Branch A, Monday for branch B, and Saturday for C.



