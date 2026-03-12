/* ---- SQL-kod SELECT ---- */

/* ---- Visa alla data från alla fält i tabellen kunder ---- */
SELECT * FROM customers

/* ---- Visa företagsnamn och land där land börjar på s ---- */
SELECT customers.companyname, customers.country
FROM customers
WHERE customers.country LIKE 's%'

/* ---- Visa datumintervall ---- */
SELECT orders.orderId, orders.orderDate
FROM orders
WHERE orders.orderDate >= '1997-0-01' AND orders.orderDate <= '1997-12-31'
WHERE orders.orderDate BETWEEN '1997-0-01' AND '1997-12-31'

/* ---- Visa skilt ifrån ---- */
SELECT * FROM customers
WHERE customers.country <> 'Sverige'
WHERE customers.country != 'Sverige'

/* ---- AND och OR ---- */
SELECT * FROM products
WHERE (products.pricePerpiece < 200 OR products.stockQuantity > 0) AND products.productName LIKE 's%'

/* ---- Visa företagsnamn och land där land = Sverige eller(,) Spanien ---- */ 	
SELECT customers.companyname, customers.country
FROM customers
WHERE customers.country IN('Sverige','Spanien')

/* ---- Visa alla ordrar där orderdatum börjar med 199_(_ istället för ett tecken) ---- */ 
SELECT * FROM orders
WHERE LEFT(orders.orderDate, 4) LIKE '199_'

/* ---- Visa alla ordrar där orderdatum börjar med 199_(_ istället för ett tecken) ---- */
/* ---- OCH orderdatum slutar med 01 ---- */
SELECT * FROM orders
WHERE LEFT(orders.orderDate, 4) LIKE '199_' AND RIGHT(orders.orderDate, 2) = '01'

/* ---- Visa alla produktnamn där ordern 'sill' finns med ---- */
SELECT * FROM products
WHERE products.productName REGEXP 'sill'

/* ---- Visa alla produktnamn som börjar med(^) a,b,c eller d ---- */
SELECT * FROM products
WHERE products.productName REGEXP '^[abcd]'
------------------------------------------------------------------

/* ---- Funktionen CONCAT används för att bygga upp en textsträng bestående av flera delar ---- */
SELECT CONCAT(customers.companyname, ' (', customers.country, ')') AS 'Customer and Country'
FROM customers

/* ---- Beräkna antal företag per land. Gruppera på land! ---- */
SELECT customers.country, COUNT(customers.companyname) AS 'Companies per Country'
FROM customers
GROUP BY customers.country

/* ---- Visa land med versaler och sortera på land och företagsnamn ---- */
SELECT customers.companyname, UCASE(customers.country) AS 'Country' 
FROM customers
ORDER BY customers.country, customers.companyname

/* ---- Skapa en fråga som visar restorder (beställt antal större än antal i lager) ---- */
SELECT products.productName, products.pricePerpiece, products.stockQuantity, SUM(order_rows.numberOf) AS 'Number of orders'	
FROM products INNER JOIN order_rows ON products.productId = order_rows.productId
WHERE order_rows.numberOf > products.stockQuantity
GROUP BY products.productName









