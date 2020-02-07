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