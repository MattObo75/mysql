/* ---- SQL-kod UPDATE ---- */

/* ---- Ändra deliveryCountry till stora bokstäver och endast 3 första ---- */
UPDATE order_archive SET order_archive.deliveryCountry = UCASE(LEFT(order_archive.deliveryCountry,3)) 

/* ---- Ange makulerad och Okänt i fälten deliveryCountry, deliveryPlace för angivna OrderId ---- */
UPDATE order_archive SET order_archive.State = 'Makulerad', order_archive.deliveryPlace = 'Okänd', order_archive.deliveryCountry = 'Okänd'
WHERE order_archive.orderId IN(10248, 10258, 10268, 10278)

/* ---- EJ KLAR Ändra customer_Id i ordrar till de nya numriska värdena ---- */
SELECT orders.customerId, customers.customerId
FROM customers INNER JOIN orders ON customers.customerId = orders.customerId

UPDATE orders SET orders.customer_Id = customers.customer_Id
WHERE customers.customerId = orders.customerId



