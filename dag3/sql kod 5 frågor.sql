/* ---- SQL-kod 5 frågor ---- */

/* ---- 1. Visa en Ordersumma för varje order ---- */
SELECT orders.orderId, orders.orderDate, ROUND(SUM(order_rows.numberOf * order_rows.unitPrice),0) AS 'Order sum'
FROM orders INNER JOIN order_rows ON orders.orderId = order_rows.orderId
WHERE orders.orderId = order_rows.orderId
GROUP BY orders.orderId

/* ---- 2. Antal ordrar per företag/kund ---- */
SELECT 
    customers.customerId,
    customers.companyname,
    COUNT(orders.orderId) AS 'numberOfOrders'
FROM customers 
LEFT JOIN orders  
    ON customers.customerId = orders.customerId
GROUP BY 
    customers.customerId,
    customers.companyname;

/* ---- 3. Antal ordrar och ordersumma per anställd ---- */
SELECT
    employees.employeeId,
    employees.firstname,
    employees.lastname,
    COUNT(DISTINCT orders.orderId) AS 'numberOfOrders',
    ROUND(SUM(order_rows.unitPrice * order_rows.numberOf * (1 - order_rows.discount)), 0) AS 'orderTotal'
FROM employees
LEFT JOIN orders
    ON employees.employeeId = orders.employeeId
LEFT JOIN order_rows
    ON orders.orderId = order_rows.orderId
GROUP BY
    employees.employeeId,
    employees.firstname,
    employees.lastname;

/* ---- 4. Antal ordrar per produkt ---- */
SELECT
    products.productId,
    products.productname,
    COUNT(DISTINCT order_rows.orderId) AS numberOfOrders
FROM products
LEFT JOIN order_rows
    ON products.productId = order_rows.productId
GROUP BY
    products.productId,
    products.productname;

/* ---- 5. Medel ordervärde per land ---- */
SELECT
    customers.country,
    ROUND(SUM(order_rows.unitPrice * order_rows.numberOf * (1 - order_rows.discount)) / COUNT(DISTINCT orders.orderId),0) AS 'avgOrderValue'
FROM customers
JOIN orders
    ON customers.customerId = orders.customerId
JOIN order_rows
    ON orders.orderId = order_rows.orderId
GROUP BY
    customers.country;



