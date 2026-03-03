/* ---- SQL-kod SELECT ---- */

/* ---- Visa ordrar under 1997 där kundlandet börjar på s ---- */
SELECT customers.companyname, customers.country, orders.orderId, orders.orderDate
FROM customers INNER JOIN orders ON customers.customerId = orders.orderId
WHERE LEFT(orders.orderDate,4) REGEXP '1997' AND customers.country LIKE 's%'
ORDER BY customers.country, orders.orderDate DESC

/* ---- Visa restorder eller lagersaldo ok för alla produkter ---- */
SELECT products.productName, products.pricePerpiece, products.stockQuantity, SUM(order_rows.numberOf) AS 'Sum ordered',
products.stockQuantity - SUM(order_rows.numberOf) AS 'New stock quantity',
IF(products.stockQuantity -  SUM(order_rows.numberOf) <= 0, 'Rest order','stock quantity OK') AS 'Check stock quantity'
FROM Products INNER JOIN order_rows ON products.productId = order_rows.productId
GROUP BY products.productName

/* ---- Visa kunder med orderdata ---- */
SELECT customers.companyname, orders.orderId, order_rows.numberOf, products.productName, products.pricePerpiece, order_rows.numberOf * products.pricePerpiece AS 'Row sum'
FROM customers INNER JOIN orders ON customers.customerId = orders.customerId
INNER JOIN order_rows ON orders.orderId = order_rows.orderId
INNER JOIN products ON products.productId = order_rows.productId

/* ---- Visa alla kunder som saknar order ---- */
SELECT customers.companyname,customers.place, customers.country, orders.orderId
FROM customers LEFT OUTER JOIN orders ON customers.customerId = orders.customerId
WHERE orders.orderId IS NULL

/* ---- Visa totalt ordervärde för varje säljare ---- */
SELECT employees.employeeId, CONCAT(employees.firstname, ' ', employees.lastname) AS 'Sellers',
employees.position, ROUND(SUM(order_rows.unitPrice * order_rows.numberOf * (1 - order_rows.discount)),0) AS 'Total sum' 

FROM employees INNER JOIN orders on employees.employeeId = orders.employeeId
INNER JOIN order_rows ON orders.orderId = order_rows.orderId
GROUP BY employees.employeeId
HAVING employees.position = 'Säljare'
ORDER BY employees.lastname

/* ---- Visa orderraderna för varje order där det finns rabatt från 1998 ---- */
SELECT orders.orderId, orders.orderDate, products.productName, ROUND(order_rows.unitPrice * order_rows.numberOf * (1 - order_rows.discount),0) AS 'Amount'
FROM employees INNER JOIN orders ON employees.employeeId = orders.employeeId
INNER JOIN order_rows ON orders.orderId = order_rows.orderId
INNER JOIN products ON products.productId = order_rows.productId
WHERE order_rows.discount > 0 AND orders.orderdate REGEXP '1998'

/* ---- BERÄKNINGAR ---- */
/* ---- 3, närmaste heltal efter division---- */
SELECT 23 DIV 6;
/* ---- 5, det som blir över ---- */
SELECT 23 MOD 6;
/* ---- 3.8333 ---- */
SELECT 23/6;
/* ---- 3, avrundar nedåt ---- */
SELECT FLOOR(23/6);
/* ---- 4, avrundar till närmaste heltal ---- */
SELECT ROUND(23/6);
/* ---- decimaltal mellan 0 och 1 ---- */
SELECT RAND();
/* ---- slumptal mellan 1 och 10 ---- */
SELECT FLOOR((RAND() * 10) + 1);






