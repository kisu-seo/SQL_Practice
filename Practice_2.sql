SHOW DATABASES;
USE classicmodels;
SHOW TABLES;


# 일별 매출액 조회
SELECT orderDate, SUM(priceEach * quantityOrdered) AS Sales
FROM orders
LEFT JOIN orderdetails 
ON orders.orderNumber = orderdetails.orderNumber
GROUP BY 1
ORDER BY 1;


# 월별 매출액 조회
SELECT SUBSTR(orderDate,1,7) AS MM, SUM(priceEach * quantityOrdered) AS Sales
FROM orders
LEFT JOIN orderdetails
ON orders.orderNumber = orderdetails.orderNumber
GROUP BY 1
ORDER BY 1;


# 연도별 매출액 조회
SELECT SUBSTR(orderDate,1,4) AS MM, SUM(priceEach * quantityOrdered) AS Sales
FROM orders
LEFT JOIN orderdetails
ON orders.orderNumber = orderdetails.orderNumber
GROUP BY 1
ORDER BY 1;


# 구매자 수, 구매 건수(일자별, 월별, 연도별)
SELECT orderDate, customerNumber, orderNumber
FROM orders;

SELECT COUNT(orderNumber) AS n_orders,
COUNT(DISTINCT orderNumber) AS n_orders_distinct
FROM orders;

## 일자별
SELECT orderDate AS DD,
COUNT(DISTINCT customerNumber) AS n_purchaser,
COUNT(orderNumber) as n_orders
FROM orders
GROUP BY 1
ORDER BY 1;

## 월별
SELECT SUBSTR(orderDate,1,7) AS MM,
COUNT(DISTINCT customerNumber) AS n_purchaser,
COUNT(orderNumber) as n_orders
FROM orders
GROUP BY 1
ORDER BY 1;

## 연도별
SELECT SUBSTR(orderDate,1,4) AS YY,
COUNT(DISTINCT customerNumber) AS n_purchaser,
COUNT(orderNumber) as n_orders
FROM orders
GROUP BY 1
ORDER BY 1;


# 인당 매출액(연도별)
SELECT SUBSTR(orderDate,1,4) AS YY,
COUNT(DISTINCT customerNumber) AS n_purchaser,
SUM(priceEach * quantityOrdered) AS sales,
SUM(priceEach * quantityOrdered) / COUNT(DISTINCT customerNumber) AS AMV
FROM orders
LEFT JOIN orderdetails
ON orders.orderNumber = orderdetails.orderNumber
GROUP BY 1
ORDER BY 1;

SELECT SUBSTR(orderDate,1,4) AS YY,
COUNT(DISTINCT orderNumber)
FROM orders
GROUP BY 1
ORDER BY 1;

# 건당 구매 금액(ATV, Average Transaction Value)(연도별)
SELECT SUBSTR(orderDate,1,4) AS YY,
COUNT(DISTINCT A.orderNumber) AS n_order,
SUM(priceEach * quantityOrdered) AS sales,
SUM(priceEach * quantityOrdered) / COUNT(DISTINCT A.orderNumber) AS ATV
FROM orders AS A
LEFT JOIN orderdetails AS B
ON A.orderNumber = B.orderNumber
GROUP BY 1
ORDER BY 1;


# 국가별, 도시별 매출액
SELECT * FROM orders as A
LEFT JOIN orderdetails as B
ON A.orderNumber = B.orderNumber
LEFT JOIN customers as C
ON A.customerNumber = C.customerNumber;

SELECT country, city, priceEach * quantityOrdered FROM orders as A
LEFT JOIN orderdetails as B
ON A.orderNumber = B.orderNumber
LEFT JOIN customers as C
ON A.customerNumber = C.customerNumber
;

SELECT country, city, SUM(priceEach * quantityOrdered) AS SALES
FROM orders AS A
LEFT JOIN orderdetails AS B
ON A.orderNumber = B.orderNumber
LEFT JOIN customers AS C
ON A.customerNumber = C.customerNumber
GROUP BY 1,2
ORDER BY 1,2;


# 북미(USA, Canada) vs 비북미 매출액 비교
SELECT CASE WHEN country IN ("USA", "Canada") THEN "North America"
Else "Others" END country_group
FROM customers;

SELECT CASE WHEN country IN ("USA", "Canada") THEN "North America"
ELSE "Others" END country_group,
SUM(priceEach * quantityOrdered) AS sales
FROM orders as A
LEFT JOIN orderdetails as B
ON A.orderNumber = B.orderNumber
LEFT JOIN customers as C
ON A.orderNumber = B.orderNumber
GROUP BY 1
ORDER BY 2 DESC; # DESC 는 높은 순으로 정렬 


# 매출 TOP 5 국가 및 매출
CREATE TABLE classicmodels.STAT AS
SELECT country, SUM(priceEach * quantityOrdered) AS sales
FROM orders AS A 
LEFT JOIN orderdetails AS B
ON A.orderNumber = B.orderNumber
LEFT JOIN customers AS C
ON A.customerNumber = C.customerNumber
GROUP BY 1
ORDER BY 2 DESC;

SELECT * FROM STAT;

SELECT country, sales,
DENSE_RANK() OVER(ORDER BY sales DESC) AS RNK
FROM STAT;

CREATE TABLE STAT_RNK AS
SELECT country, sales,
DENSE_RANK() OVER(ORDER BY sales DESC) AS RNK
FROM STAT;

SELECT * FROM STAT_RNK;

SELECT * FROM STAT_RNK WHERE RNK BETWEEN 1 AND 5;


# Subquery
SELECT * FROM
(SELECT country, sales, DENSE_RANK() OVER(ORDER BY sales DESC) AS RNK FROM 
(SELECT C.country, SUM(priceEach * quantityOrdered) as sales
FROM orders AS A
LEFT JOIN
orderdetails AS B
ON A.orderNumber = B.orderNumber
LEFT JOIN
customers AS C
ON A.customerNumber = C.customerNumber

GROUP BY 1) A) A
WHERE RNK <= 5;


# 재구매율
SELECT
A.customerNumber,
A.orderDate,
B.customerNumber,
B.orderDate
FROM orders AS A
LEFT JOIN orders AS B
ON A.customerNumber = B.customerNumber AND
SUBSTR(A.orderDate,1,4) = SUBSTR(B.orderDate,1,4) -1
;


# 국가별 2004, 2005 Retention Rate(%)
SELECT
C.country,
SUBSTR(A.orderDate,1,4) AS YY,
COUNT(DISTINCT A.customerNumber) AS BU_1,
COUNT(DISTINCT B.customerNumber) AS BU_2,
COUNT(DISTINCT B.customerNumber) / COUNT(DISTINCT A.customerNumber) AS RETENTION_RATE
FROM orders AS A
LEFT JOIN orders AS B
ON A.customerNumber = B.customerNumber AND
SUBSTR(A.orderDate,1,4) = SUBSTR(B.orderDate,1,4) -1
LEFT JOIN customers AS C
ON A.customerNumber = C.customerNumber
GROUP BY 1,2;


# Best Seller
CREATE TABLE PRODUCT_SALES AS
SELECT
D.productName, SUM(priceEach * quantityOrdered) AS sales
FROM orders AS A
LEFT JOIN customers AS B
ON A.customerNumber = B.customerNumber
LEFT JOIN orderdetails AS C
ON A.orderNumber = C.orderNumber
LEFT JOIN products AS D
ON C.productCode = D.productCode
WHERE B.country = "USA"
GROUP BY 1;

SELECT * FROM
(SELECT *,
ROW_NUMBER() OVER(ORDER BY sales DESC) AS RNK
FROM PRODUCT_SALES) AS A
WHERE RNK <= 5
ORDER BY RNK;


# Churn Rate(%) 구하기
SELECT MAX(orderDate) AS MX_ORDER
FROM orders;

SELECT customerNumber, MAX(orderDate) AS MX_ORDER
FROM orders
GROUP BY 1;

SELECT
customerNumber, MX_ORDER, "2005-06-01", DATEDIFF("2005-06-01", MX_ORDER) AS DIFF
FROM
(SELECT customerNumber, MAX(orderDate) AS MX_ORDER
FROM orders
GROUP BY 1) AS BASE
;

SELECT *,
CASE WHEN DIFF >= 90 THEN "CHURN" ELSE "NON-CHURN" END AS CHURN_TYPE
FROM
(SELECT
customerNumber, MX_ORDER, "2005-06-01", DATEDIFF("2005-06-01", MX_ORDER) AS DIFF
FROM
(SELECT customerNumber, MAX(orderDate) AS MX_ORDER
FROM orders
GROUP BY 1) BASE) BASE

SELECT CASE WHEN DIFF >= 90 THEN "CHURN" ELSE "NON-CHURN" END AS CHURN_TYPE,
COUNT(DISTINCT customerNumber) AS N_CUS
FROM
(SELECT customerNumber,
MX_ORDER,
"2005-06-01",
DATEDIFF("2005-06-01", MX_ORDER) AS DIFF
FROM
(SELECT customerNumber,
MAX(orderDate) AS MX_ORDER
FROM orders
GROUP
BY 1) BASE) BASE
GROUP BY 1;


# Churn 고객이 가장 많이 구매한 Productline
CREATE TABLE CHURN_LIST AS
SELECT CASE WHEN DIFF >= 90 THEN "CHURN" ELSE "NON-CHURN" END AS CHURN_TYPE,
customerNumber
FROM
(SELECT customerNumber, MX_ORDER, "2005-06-01" AS END_POINT,
DATEDIFF("2005-06-01", MX_ORDER) AS DIFF
FROM
(SELECT customerNumber, MAX(orderDate) AS MX_ORDER
FROM orders
GROUP BY 1) BASE) BASE;

SELECT C.productLine, COUNT(DISTINCT B.customerNumber) AS BU
FROM orderdetails AS A
LEFT JOIN orders AS B
ON A.orderNumber = B.orderNumber
LEFT JOIN products AS C
ON A.productCode = C.productCode
GROUP BY 1;

SELECT D.CHURN_TYPE, C.productLine, COUNT(DISTINCT B.customerNumber) AS BU
FROM orderdetails AS A
LEFT JOIN orders AS B
ON A.orderNumber = B.orderNumber
LEFT JOIN products AS C
ON A.productCode = C.productCode
LEFT JOIN CHURN_LIST AS D
ON B.customerNumber = D.customerNumber
GROUP BY 1,2
ORDER BY 1,3 DESC;