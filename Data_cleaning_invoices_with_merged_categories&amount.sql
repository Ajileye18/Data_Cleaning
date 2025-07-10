USE datawarehouseanalytics;
drop table merged_category;
CREATE TABLE merged_category (
Order_ID VARCHAR(50),
Category VARCHAR(50),
Amount VARCHAR(50)
);
DROP TABLE merged_category2;
CREATE TABLE merged_category2
LIKE merged_category;

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\8.-Invoices-with-Merged-Categories-and-Merged-Amounts.csv"
INTO TABLE merged_category
FIELDS TERMINATED BY ','
ENCLOSED BY "'"
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(Order_ID, Category, Amount);

SELECT * FROM datawarehouseanalytics.merged_category;

INSERT INTO merged_category2 (Order_ID, Category, Amount)
SELECT Order_ID, left(category,7), left(amount,6), 
Order_ID, substring(category, 11,3), substring(amount,10,4), 
Order_ID, substring(category,17,6), substring(amount,17,6),
Order_ID, substring(category, 26,9), substring(amount,26,6),
Order_ID, right(category, 5), right(amount,5)
FROM merged_category
WHERE Order_ID ='CA-2011-167199';

SELECT order_id, substring(category,1,15),left(amount,4) amount,
right(category,9),right(amount,5)
from merged_category
where order_id = 'CA-2011-149020';

SELECT order_id, left(category, 15), left(amount,3),
		Order_ID,substring(category,19,10), substring(amount,7,7),
        order_id, right(category,10), right(amount,6)
FROM merged_category
WHERE order_id = 'CA-2011-131905';

SELECT order_id, left(category, 11), left(amount,6),
		Order_ID,substring(category,15,6), substring(amount,10,7),
        order_id, right(category,7), right(amount,5)
FROM merged_category
WHERE order_id = 'CA-2011-127614';

INSERT INTO merged_category2
SELECT Order_ID, left(category,7), left(amount,6)
FROM merged_category
WHERE Order_ID ='CA-2011-167199';

INSERT INTO merged_category2
SELECT Order_ID, substring(category, 11,3), substring(amount,10,4)
FROM merged_category
WHERE Order_ID ='CA-2011-167199';

INSERT INTO merged_category2
SELECT Order_ID, substring(category,17,6), substring(amount,17,6)
FROM merged_category
WHERE Order_ID ='CA-2011-167199';

INSERT INTO merged_category2
SELECT Order_ID, substring(category, 26,9), substring(amount,26,6)
FROM merged_category
WHERE Order_ID ='CA-2011-167199';

INSERT INTO merged_category2
SELECT Order_ID, right(category, 5), right(amount,5)
FROM merged_category
WHERE Order_ID ='CA-2011-167199';

INSERT INTO merged_category2
SELECT order_id, substring(category,1,15),left(amount,4)
FROM merged_category
WHERE Order_ID = 'CA-2011-149020';

INSERT INTO merged_category2
SELECT Order_ID, right(category,9), right(amount,5)
FROM merged_category
WHERE Order_ID = 'CA-2011-149020';

INSERT INTO merged_category2
SELECT order_id, left(category, 15), left(amount,3)
FROM merged_category
WHERE Order_ID = 'CA-2011-131905';

INSERT INTO merged_category2
SELECT Order_ID,substring(category,19,10), substring(amount,7,7)
FROM merged_category
WHERE Order_ID = 'CA-2011-131905';

INSERT INTO merged_category2
SELECT order_id, right(category,10), right(amount,6)
FROM merged_category
WHERE Order_ID = 'CA-2011-131905';

INSERT INTO merged_category2
SELECT order_id, left(category, 11), left(amount,6)
FROM merged_category
WHERE Order_ID = 'CA-2011-127614';

INSERT INTO merged_category2
SELECT Order_ID,substring(category,15,6), substring(amount,10,7)
FROM merged_category
WHERE Order_ID = 'CA-2011-127614';

INSERT INTO merged_category2
SELECT order_id, right(category,7), right(amount,5)
FROM merged_category
WHERE Order_ID = 'CA-2011-127614';

SELECT * FROM merged_category2;
