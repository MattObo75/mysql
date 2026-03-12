/* ---- SQL-kod XTreme_db ---- */

/* ---- Tabeller med fält ---- */

/* ---- Customers 17 fält---- */
CustomerId, 
CustomerName,
FirstName, 
LastName, 
Title,
Position,
LastYearsSales,
Address1,
Address2,
City,
Region,
Country,
PostalCode,
Email,
Website,
Phone,
Fax

/* ---- Orders 12 fält---- */
OrderId
OrderAmount,
CustomerID,
EmployeeID,
OrderDate,
RequiredDate,
ShipDate,
CourierWebsite,
ShipVia,
Shipped,
PO,
PaymentReceived

/* ---- OrderDetails 4 fält ---- */
OrderID,
ProductID,
UnitPrice,
Quantity

/* ---- Products 9 fält ---- */
ProductID,
ProductName,
Color,
Size,
MF,
PriceUnit,
ProductTypeID,
ProductClass,
SupplierID

/* ---- ProductTypes 2 fält---- */
ProductTypeID,
ProductTypeName


/* ---- Suppliers 9 fält ---- */
SupplierID,
SupplierName,
Address1,
Address2,
City,
Region,
Country,
PostalCode,
Phone

/* ---- Lägg till Customers från Importtabell---- */
INSERT INTO customers (customers.CustomerID,customers.Name,customers.FirstName,customers.LastName,customers.Title,customers.Position,customers.LastYearsSales,customers.Address1,customers.Address2,customers.City,customers.Region,customers.Country,customers.PostalCode,customers.Email,customers.WebSite,customers.Phone,customers.Fax)
SELECT 
cimp.CustomerID,cimp.CustomerName,cimp.ContactFirstName,cimp.ContactLastName,cimp.ContactTitle,cimp.ContactPosition,cimp.LastYearsSales,cimp.Address1,cimp.Address2,cimp.City,cimp.Region,cimp.Country,cimp.PostalCode,cimp.Email,cimp.WebSite,cimp.Phone,cimp.Fax
FROM customers_imported cimp

/* ---- Lägg till Orders från Importtabell---- */
INSERT INTO orders (orders.OrderId, orders.OrderAmount, orders.CustomerID, orders.EmployeeID, orders.OrderDate, orders.RequiredDate, orders.ShipDate, orders.CourierWebsite, orders.ShipVia, orders.Shipped, orders.PO, orders.PaymentReceived)
SELECT 
oimp.OrderId, oimp.OrderAmount, oimp.CustomerID, oimp.EmployeeID, oimp.OrderDate, oimp.RequiredDate, oimp.ShipDate, oimp.CourierWebsite, oimp.ShipVia, oimp.Shipped, oimp.PO, oimp.PaymentReceived
FROM orders_imported oimp

/* ---- Lägg till OrderDetails från Importtabell---- */
INSERT INTO orderdetails (orderdetails.OrderId, orderdetails.ProductID, orderdetails.UnitPrice, orderdetails.Quantity)
SELECT 
oimp.OrderId, oimp.ProductID, oimp.UnitPrice, oimp.Quantity
FROM orderdetails_imported oimp

/* ---- Lägg till Products från Importtabell---- */
INSERT INTO products (products.ProductID,products.ProductName,products.Color,products.Size,products.MF,products.PriceUnit,products.ProductTypeID,products.ProductClass,products.SupplierID)
SELECT 
pimp.ProductID,pimp.ProductName,pimp.Color,pimp.Size,pimp.MF,pimp.PriceUnit,pimp.ProductTypeID,pimp.ProductClass,pimp.SupplierID
FROM products_imported pimp

/* ---- Lägg till ProductTypes från Importtabell---- */
INSERT INTO producttypes (producttypes.ProductTypeID, producttypes.ProductTypeName)
SELECT 
pimp.ProductTypeID, pimp.ProductTypeName
FROM producttypes_imported pimp

/* ---- Lägg till Suppliers från Importtabell---- */
INSERT INTO suppliers (suppliers.SupplierID, suppliers.SupplierName, suppliers.Address1, suppliers.Address2, suppliers.City, suppliers.Region, suppliers.Country, suppliers.PostalCode, suppliers.Phone)
SELECT 
simp.SupplierID, simp.SupplierName, simp.Address1, simp.Address2, simp.City, simp.Region, simp.Country, simp.PostalCode, simp.Phone
FROM suppliers_imported simp

/* ---- Lägg till Employees från Importtabell---- */
INSERT INTO employees (employees.EmployeeID, employees.LastName, employees.FirstName,Position)
SELECT 
em.Anställningsnr, em.Efternamn, em.Förnamn, em.Befattning	
FROM employees_imported em



/* ---- SQL-kod 6 frågor ---- */

/* ---- 1. Visa alla kunder från USA. ---- */
SELECT Name, Country
FROM customers
WHERE Country = 'USA';

/* ---- 2. Visa alla leverantörer från Japan och deras produkter. ---- */
SELECT DISTINCT suppliers.SupplierName, Products.ProductName
FROM suppliers
INNER JOIN Products ON suppliers.SupplierID = Products.SupplierID
WHERE suppliers.Country = 'Japan';

/* ---- 3. Visa alla produkter för produkttyperna Mountain och Competition. ---- */
SELECT DISTINCT producttypes.ProductTypeName, Products.ProductName
FROM producttypes
INNER JOIN Products ON producttypes.ProductTypeID = Products.ProductTypeID
WHERE producttypes.ProductTypeName IN ('Mountain', 'Competition');

/* ---- 4. Visa totalt ordervärde per kund. ---- */
SELECT customers.Name, ROUND(SUM(orders.OrderAmount)) AS TotalOrderValue
FROM customers
INNER JOIN orders ON customers.CustomerId = orders.CustomerID
GROUP BY customers.Name

/* ---- 5. Visa antal produkter per produkttyp. ---- */
SELECT producttypes.ProductTypeName, COUNT(Products.ProductID) AS NumberOfProducts
FROM producttypes
INNER JOIN Products ON producttypes.ProductTypeID = Products.ProductTypeID
GROUP BY producttypes.ProductTypeName

/* ---- 6. Visa totalt ordervärde per order. ---- */
SELECT OrderID, ROUND(SUM(UnitPrice * Quantity)) AS TotalOrderValue
FROM orderdetails
GROUP BY OrderID
ORDER BY TotalOrderValue DESC





