SHOW DATABASES;
USE classicmodels; # classicmodels 데이터베이스 사용
SHOW TABLES;
SELECT * FROM products;

# customer 의 customerNumber 조회
SELECT customerNumber FROM customers;

# payments 의 amount 의 총합과 checknumber 개수 구하기
SELECT SUM(amount), COUNT(checkNumber) FROM payments;

# products 의 productName, productLine 조회
SELECT productName, productLine FROM products;

# products 의 productCode 의 개수를 구하고, 컬럼 명을 n_products 로 변경
SELECT COUNT(productCode) AS n_products FROM products;

# orderdetails 의 ordernumber 의 중복을 제거하고 조회
SELECT DISTINCT orderNumber FROM orderdetails;

# orderdetails 의 priceeach 가 30 에서 50 사이인 데이터 조회
SELECT * FROM orderdetails WHERE priceEach BETWEEN 30 AND 50;

# orderdetails 의 priceeach 가 30 이상인 데이터 조회
SELECT * FROM orderdetails WHERE priceEach >= 30;

# customer 의 country 가 USA 또는 Canada 인 customernumber 를 조회
SELECT customerNumber FROM customers WHERE country IN ("USA", "Canada");

# customer 의 country 가 USA 또는 Canada 가 아닌 customernumber 를 조회
SELECT customerNumber FROM customers WHERE country NOT IN ("USA", "Canada");

# employees 의 reportsTo 의 값이 Null 인 employeenumber 를 조회
SELECT employeeNumber FROM employees WHERE reportsTo IS NULL; # 반대는 IS NOT NULL

# customers 의 addressline1 에 ST 가 포함된 addressline1 을 출력
SELECT addressline1 FROM customers WHERE addressline1 LIKE "%ST%";

# customer 테이블을 이용해 국가, 도시별 고객 수 구하기
SELECT country, city, COUNT(customerNumber) AS n_customers FROM customers GROUP BY country, city;

# customer 테이블을 이용해 USA 거주자의 수를 계산하고, 그 비중 구하기
SELECT * FROM customers;
SELECT SUM(CASE WHEN country = "USA" THEN 1 ELSE 0 END) AS n_USA,
SUM(CASE WHEN country = "USA" THEN 1 ELSE 0 END) / COUNT(*) AS USA_portion FROM customers;

# customer, order 테이블을 결합하고 ordernumber 와 country 출력(LEFT JOIN)
SELECT orderNumber, country FROM orders LEFT JOIN customers
ON orders.customerNumber = customers.customerNumber;

# customer, order 테이블을 이용해 USA 거주자의 customerNumber, country 출력(INNER JOIN)
SELECT * FROM customers;
SELECT * FROM orders;
SELECT orderNumber, country FROM orders INNER JOIN customers 
ON orders.customerNumber = customers.customerNumber WHERE customers.country = "USA";

# customers 의 country 컬럼을 이용해 북미(Canada, USA), 비북미를 출력하는 컬럼 생성
SELECT country, CASE WHEN country IN ("Canada", "USA") THEN "North America"
ELSE "Others" END AS region FROM customers;

# customers 의 country 컬럼을 이용해 북미(Canada, USA), 비북미를 출력하는 컬럼을 생성하고
# 북미, 비북미 거주 고객의 수 계산
SELECT CASE WHEN country IN ("Canada", "USA") THEN "North America"
ELSE "Others" END AS region,
COUNT(customerNumber) AS n_customers
FROM customers
GROUP BY 1;

# products 테이블에서 buyprice 컬럼으로 순위 매기기(오름차순)(ROW_NUMBER, RANK, DENSE RANK 사용)
SELECT buyPrice,
ROW_NUMBER() OVER(ORDER BY buyPrice) AS RowNumber,
RANK() OVER(ORDER BY buyPrice) AS RNK,
DENSE_RANK() OVER(ORDER BY buyPrice) AS DenseRank
FROM products;

# products 테이블의 productline 별로 순위 매기기(buyPrice 컬럼 기준, 오름차순)(ROW_NUMBER, RANK, DENSE RANK 사용)
SELECT buyPrice,
ROW_NUMBER() OVER(PARTITION BY productLine ORDER BY buyPrice) AS RowNumber,
RANK() OVER(PARTITION BY productLine ORDER BY buyPrice) AS RNK,
DENSE_RANK() OVER(PARTITION BY productLine ORDER BY buyPrice) AS DenseRank
FROM products;

# customers 와 orders 를 이용해 USA 거주자의 주문 번호 출력
SELECT orderNumber FROM orders
WHERE customerNumber IN (SELECT customerNumber FROM customers
WHERE country = "USA");