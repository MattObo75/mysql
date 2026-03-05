/* ---- SQL-kod UPDATE ---- */

/* ---- Ändra deliveryCountry till stora bokstäver och endast 3 första ---- */
UPDATE order_archive SET order_archive.deliveryCountry = UCASE(LEFT(order_archive.deliveryCountry,3)) 

/* ---- Ange makulerad och Okänt i fälten deliveryCountry, deliveryPlace för angivna OrderId ---- */
UPDATE order_archive SET order_archive.State = 'Makulerad', order_archive.deliveryPlace = 'Okänd', order_archive.deliveryCountry = 'Okänd'
WHERE order_archive.orderId IN(10248, 10258, 10268, 10278)

/* ---- Ändra customer_Id i ordrar till de nya numriska värdena ---- */
UPDATE orders 
JOIN customers ON customers.customerId = orders.customerId
SET orders.customer_Id = customers.customer_Id;
