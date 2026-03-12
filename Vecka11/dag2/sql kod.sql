/* ---- SQL-kod  ---- */

Lägg till nya patienter till patient-tabellen
INSERT INTO patienter(patienter.PersonNr, patienter.FirstName, patienter.LastName)
SELECT personervaccination.PersonNr, personervaccination.Fornamn, personervaccination.Efternamn
FROM personervaccination

DELIMITER |
CREATE PROCEDURE sp_Uppdatera_Patienter()
BEGIN
	-- Uppdatera fältet AGE i tabellen patienter
	UPDATE patienter
	SET patienter.Age = YEAR(CURRENT_DATE) - LEFT(patienter.PersonNr, 4);

	-- Uppdatera fältet Gender i tabellen patienter
	UPDATE patienter
	SET patienter.Gender = IF( LEFT(RIGHT(patienter.PersonNr,2), 1) MOD 2 = 0, 'K' , 'M');
    
END |

SELECT patienter.PersonNr, patienter.FirstName, patienter.LastName, vacciner.Vaccin, kommun.Kommun

FROM patienter INNER JOIN vaccinationer ON patienter.PatientID = vaccinationer.PatientID
            INNER JOIN vacciner ON vaccinationer.VaccinID = vacciner.VaccinID
            INNER JOIN platser ON vaccinationer.PlatsID = platser.PlatsID
            INNER JOIN kommun ON platser.KommunID = kommun.KommunID
            
WHERE kommun.Kommun = 'Gävle kommun'

SELECT kommun.Kommun, ROUND(AVG(YEAR(CURRENT_DATE) - LEFT(patienter.PersonNr, 4)),0) AS 'Medelålder alla patienter'

FROM patienter INNER JOIN vaccinationer ON patienter.PatientID = vaccinationer.PatientID
            INNER JOIN vacciner ON vaccinationer.VaccinID = vacciner.VaccinID
            INNER JOIN platser ON vaccinationer.PlatsID = platser.PlatsID
            INNER JOIN kommun ON platser.KommunID = kommun.KommunID
            
-- WHERE kommun.Kommun = 'Gävle kommun'
GROUP BY kommun.Kommun

INSERT IGNORE INTO patienter(patienter.PersonNr, patienter.FirstName, patienter.LastName)
SELECT personervaccinationny.PersonNr, personervaccinationny.Fornamn, personervaccinationny.Efternamn
FROM personervaccinationny

SELECT vaccinationer.VaccDatum, COUNT(vaccinationer.VaccinationsID) AS 'Antal vaccinationer per datum'
FROM vaccinationer 
GROUP BY vaccinationer.VaccDatum

SELECT patienter.PersonNr, patienter.FirstName, patienter.LastName, COUNT(vaccinationer.VaccinationsID) AS 'Antal vaccinationer per patient'
FROM vaccinationer INNER JOIN patienter ON patienter.PatientID = vaccinationer.PatientID
GROUP BY patienter.PersonNr

/* ------------------------------------------------------------------------------- * /



-- Infoga unika kunder från nyorderdata till customers
INSERT INTO customers(customers.CustomerName, customers.Contact, customers.Address, customers.Country)
SELECT DISTINCT nyorderdata.CompanyName, CONCAT(nyorderdata.FirstName, ' ', nyorderdata.LastName),
nyorderdata.Address, nyorderdata.Country
FROM nyorderdata
WHERE NOT (nyorderdata.CompanyName IN(SELECT customers.CustomerName FROM customers))

-- Infoga unika produkter från nyorderdata till products
INSERT INTO products(products.ProductName, products.NumInStore, products.UnitPrice)
SELECT DISTINCT nyorderdata.ProductName, nyorderdata.NumInStore, nyorderdata.UnitPrice
FROM nyorderdata
WHERE NOT (nyorderdata.ProductName IN(SELECT products.ProductNamne FROM products))

-- Skriv nya poster till order-tabellen. OBS värden till sekundärnyckeln CustomerID hämtas från
-- tabellen Customers. Därför måste tabellerna Customers och nyorderdata kopplas ihop
INSERT INTO orders(orders.OrderID, orders.OrderDate, orders.Shipped, orders.Freight, orders.CustomerID)
SELECT DISTINCT nyorderdata.OrderID, nyorderdata.OrderDate, nyorderdata.ShippedDate, nyorderdata.Freight, customers.CustomerID
FROM customers INNER JOIN nyorderdata ON customers.CustomerName = nyorderdata.CompanyName
GROUP BY nyorderdata.OrderID

-- Infoga data i tabellen orderdetails
INSERT IGNORE INTO orderdetails(orderdetails.OrderID, orderdetails.ProductID, orderdetails.Quantity)
SELECT DISTINCT orders.OrderID, products.ProductID, nyorderdata.Quantity
FROM orders INNER JOIN nyorderdata ON orders.OrderID = nyorderdata.OrderID
INNER JOIN products ON nyorderdata.ProductName = products.ProductNamne

DELIMITER |
CREATE PROCEDURE RaderaData()
BEGIN
    DELETE FROM orderdetails;
    DELETE FROM products;
    DELETE FROM orders;
    DELETE FROM customers;

END |

DELIMITER |
CREATE PROCEDURE InfogaData()
BEGIN

-- Infoga unika kunder från nyorderdata till customers
INSERT INTO customers(customers.CustomerName, customers.Contact, customers.Address, customers.Country)
SELECT DISTINCT nyorderdata.CompanyName, CONCAT(nyorderdata.FirstName, ' ', nyorderdata.LastName), nyorderdata.Address, nyorderdata.Country
FROM nyorderdata
WHERE NOT (nyorderdata.CompanyName IN(SELECT customers.CustomerName FROM customers));

-- Infoga unika produkter från nyorderdata till products
INSERT INTO products(products.ProductNamne, products.NumInStore, products.UnitPrice)
SELECT DISTINCT nyorderdata.ProductName, nyorderdata.NumInStore, nyorderdata.UnitPrice
FROM nyorderdata
WHERE NOT (nyorderdata.ProductName IN(SELECT products.ProductNamne FROM products));
    

-- Skriv nya poster till order-tabellen. OBS värden till sekundärnyckeln CustomerID hämtas från
-- tabellen Customers. Därför måste tabellerna Customers och nyorderdata kopplas ihop
INSERT INTO orders(orders.OrderID, orders.OrderDate, orders.Shipped, orders.Freight, orders.CustomerID)
SELECT DISTINCT nyorderdata.OrderID, nyorderdata.OrderDate, nyorderdata.ShippedDate, nyorderdata.Freight, customers.CustomerID
FROM customers INNER JOIN nyorderdata ON customers.CustomerName = nyorderdata.CompanyName
GROUP BY nyorderdata.OrderID;

-- Infoga data i tabellen orderdetails
INSERT IGNORE INTO orderdetails(orderdetails.OrderID, orderdetails.ProductID, orderdetails.Quantity)
SELECT DISTINCT orders.OrderID, products.ProductID, nyorderdata.Quantity
FROM orders INNER JOIN nyorderdata ON orders.OrderID = nyorderdata.OrderID
INNER JOIN products ON nyorderdata.ProductName = products.ProductName;

END |

-- Kolla om det finns dubletter av CustomerName
SELECT customers.CustomerName, COUNT(customers.CustomerName)
FROM customers
GROUP BY customers.CustomerName
HAVING COUNT(customers.CustomerName) > 1
ORDER BY customers.CustomerName

-- Funktion som beräknar frakt
DELIMITER |
CREATE FUNCTION sf_CalcFreight(orderValue FLOAT)
RETURNS FLOAT
BEGIN
    DECLARE Frakt FLOAT;
    IF orderValue > 2000 THEN
         SET Frakt = 1.05;
    ELSE
         SET Frakt = 1.1;
    END IF;
     RETURN Frakt * orderValue;
END |

DELIMITER |
CREATE PROCEDURE sp_OrderInkFrakt()
BEGIN

SELECT customers.CustomerName, orders.OrderID, orders.OrderDate,
    ROUND(sf_CalcFreight(SUM(orderdetails.Quantity * products.UnitPrice)), 2) AS 'Ordervärde ink frakt',
    ROUND(SUM(orderdetails.Quantity * products.UnitPrice), 2) AS 'Ordervärde exkl frakt'

FROM customers INNER JOIN orders ON customers.CustomerID = orders.CustomerID
    INNER JOIN orderdetails ON orders.OrderID = orderdetails.OrderID
    INNER JOIN products ON products.ProductID = orderdetails.ProductID
                
    GROUP BY orders.OrderID
    ORDER BY customers.CustomerName, orders.OrderID;
END |

