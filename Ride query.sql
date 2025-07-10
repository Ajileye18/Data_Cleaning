use datawarehouseanalytics;

CREATE TABLE ride (
Ride_ID VARCHAR(10) PRIMARY KEY NOT NULL,
User_ID VARCHAR(10) NOT NULL,
Driver_ID VARCHAR(10) NOT NULL,
Ride_DateTime DATETIME,
Pickup_Location VARCHAR(50),
Dropoff_Location VARCHAR(50),
Distance_km DECIMAL(4, 2),
Ride_Duration_min INT,
Fare_Amount DECIMAL(5, 2),
Payment_Method VARCHAR(50),
Ride_Status VARCHAR(50),
User_Rating DECIMAL(4, 2),
Driver_Rating DECIMAL(4, 2),
Surge_Pricing VARCHAR(50),
Promo_Code_Used VARCHAR(50),
Vehicle_Type VARCHAR(50),
Weather_Condition VARCHAR(50),
Traffic_Level VARCHAR(50),
Driver_Experience_Years INT,
User_Type VARCHAR(50)
);

SELECT *
FROM ride;

-- What are the most popular pickup and drop-off locations?
SELECT
Pickup_Location,
COUNT(Pickup_Location) total_pickup_location
FROM ride
GROUP BY Pickup_Location
ORDER BY COUNT(Pickup_Location) DESC;

SELECT
Dropoff_Location,
COUNT(Dropoff_Location) dropoff_location
FROM ride
GROUP BY Dropoff_Location
ORDER BY COUNT(Dropoff_Location) DESC;

-- How do weekends vs. weekdays impact ride demand?
-- Result: There are more demand for ride during weekdays than weekend. This is probably due to many people not going to work during weekend
-- Total ride demand in the weekend
SELECT
COUNT(Ride_DateTime) weekend_ride
FROM (
SELECT
Ride_DateTime,
dayofweek(Ride_DateTime) num_dy_week,
CASE WHEN dayofweek(Ride_DateTime) = 7  THEN 'Weekend'
	 WHEN dayofweek(Ride_DateTime) = 1  THEN 'Weekend'
ELSE dayofweek(Ride_DateTime)
END dyofweek
FROM ride) T
WHERE dyofweek = 'Weekend';

-- ride demand in the weekdays
SELECT
COUNT(Ride_DateTime) weekdays_ride
FROM (
SELECT
Ride_DateTime,
dayofweek(Ride_DateTime) num_dy_week,
CASE WHEN dayofweek(Ride_DateTime) = 7  THEN 'Weekend'
	 WHEN dayofweek(Ride_DateTime) = 1  THEN 'Weekend'
ELSE dayofweek(Ride_DateTime)
END dyofweek
FROM ride) T
WHERE num_dy_week BETWEEN 2 AND 6;

-- Which vehicle types (SUV, Sedan, Motorcycle, Electric) are most preferred?
-- Result: Sedan is the most preferred vehicle
SELECT
Vehicle_Type,
COUNT(Vehicle_Type) AS total_vehicle
FROM ride
GROUP BY Vehicle_Type
ORDER BY COUNT(Vehicle_Type) DESC;

-- Which drivers have the highest and lowest ratings?
WITH driver_rating AS (
SELECT
Driver_ID,
sum(Driver_Rating) total_rating
FROM ride
GROUP BY Driver_ID
)

, min_rating AS (SELECT driver_id,
		total_rating,
		min(total_rating) lowest_diver_rating
FROM driver_rating
GROUP BY driver_id
ORDER BY min(total_rating) asc
LIMIT 1) -- driver with the lowest rating

SELECT driver_id,
		MAX(total_rating) lowest_diver_rating
FROM min_rating
GROUP BY driver_id
ORDER BY min(total_rating) DESC
LIMIT 1; -- driver with highest rating

-- How does driver experience impact ride completion rates and customer ratings?

-- What is the average ride duration per driver, and how does it vary by location and traffic?
SELECT driver_id,
		AVG(Ride_Duration_min) average_ride_duration,
		Traffic_Level,
        Dropoff_Location
FROM ride
GROUP BY driver_id, Traffic_Level,
        Dropoff_Location
ORDER BY 
        Dropoff_Location ASC;
        
-- What is the average fare amount per ride type?
SELECT
AVG(Fare_Amount),
User_Type
FROM ride
GROUP BY user_type;

-- How does surge pricing affect ride fare and total revenue?

SELECT Surge_Pricing,
		COUNT(*) count_of_surge,
		avg(Fare_Amount) avg_fare,
        SUM(fare_amount) total_revenue
FROM ride
GROUP BY  Surge_Pricing;

-- What is the cancellation rate (No-show rides vs. Completed rides), and what factors contribute to it?

SELECT ride_status,
		count(*) total_ride_status
FROM ride
WHERE ride_status IN ('no-show', 'completed')
GROUP BY ride_status;

WITH ride_counts AS (
    SELECT
        Ride_Status,
        COUNT(*) AS total
    FROM ride
    WHERE Ride_Status IN ('Completed', 'No-show')
    GROUP BY Ride_Status
),
cancellation_rate AS (
    SELECT
        (SELECT total FROM ride_counts WHERE Ride_Status = 'No-show') * 100.0 /
        NULLIF((SELECT total FROM ride_counts WHERE Ride_Status = 'Completed'), 0)
        AS cancellation_rate
),
ratings_summary AS (
    SELECT
        Ride_Status,
        AVG(User_Rating) AS avg_user_rating,
        AVG(Driver_Rating) AS avg_driver_rating
    FROM ride
    WHERE Ride_Status IN ('Completed', 'No-show')
    GROUP BY Ride_Status
),
numerical_summary AS (
    SELECT
        Ride_Status,
        AVG(Distance_km) AS avg_distance_km,
        AVG(Ride_Duration_min) AS avg_duration_min,
        AVG(Fare_Amount) AS avg_fare,
        AVG(Driver_Experience_Years) AS avg_driver_experience
    FROM ride
    WHERE Ride_Status IN ('Completed', 'No-show')
    GROUP BY Ride_Status
),
categorical_summary AS (
    SELECT
        Ride_Status,
        Payment_Method,
        COUNT(*) AS count
    FROM ride
    WHERE Ride_Status IN ('Completed', 'No-show')
    GROUP BY Ride_Status, Payment_Method
),
surge_summary AS (
    SELECT
        Ride_Status,
        Surge_Pricing,
        COUNT(*) AS count
    FROM ride
    WHERE Ride_Status IN ('Completed', 'No-show')
    GROUP BY Ride_Status, Surge_Pricing
),
promo_summary AS (
    SELECT
        Ride_Status,
        Promo_Code_Used,
        COUNT(*) AS count
    FROM ride
    WHERE Ride_Status IN ('Completed', 'No-show')
    GROUP BY Ride_Status, Promo_Code_Used
)
-- Final select: combine all important factors
SELECT * FROM cancellation_rate;

-- Which payment methods are most commonly used?
SELECT Payment_Method,
		COUNT(*) toal_pmt_mthd
FROM ride
GROUP BY Payment_Method
ORDER BY COUNT(*) DESC;

-- How does weather condition (Rainy, Snowy, Foggy) impact ride duration and customer ratings?
SELECT Weather_Condition,
		AVG(Ride_Duration_min) total_ride_duration,
        AVG(User_Rating) total_rating
FROM ride
GROUP BY Weather_Condition
ORDER BY Weather_Condition DESC, AVG(Ride_Duration_min) ASC, AVG(User_Rating) DESC;

-- What is the effect of traffic level (Low, Medium, High) on ride duration and fare amounts?
SELECT Traffic_Level,
		AVG(Ride_Duration_min) average_duration,
        AVG(Fare_Amount) average_fare
FROM ride
GROUP BY Traffic_Level;