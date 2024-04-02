/*--------------------------------------------------------------------------------------*/
--SUBCONSULTAS , ANY, SOME, ALL + LEFT | RIGHT |FULL JOIN
/*--------------------------------------------------------------------------------------*/

/*1) Utilizando la función EXISTS mostrar código de cliente y nombre de empresa para todos los
clientes que ordenaron el producto 40 */

SELECT customerid,companyname
FROM customers
WHERE EXISTS (SELECT *
              FROM orders,[Order Details] d
			  WHERE orders.orderid=d.orderid and
			        ProductID=40 and
					orders.CustomerID=customers.CustomerID)


/*2) Utilizando ANY listar los nombres de productos para los que exista alguna orden con cantidad igual a 10 */

SELECT ProductName
FROM Products
WHERE ProductID = ANY (SELECT ProductID FROM [Order Details] WHERE Quantity = 10)
                      


/*3) Mostrar los nombres de los Shipper que enviaron todas las ordenes del cliente
SEVES*/

SELECT shippers.CompanyName
FROM shippers
WHERE shipperid = ALL (SELECT shipvia
                       FROM orders
                       WHERE customerid='SEVES')
--> No devuelve filas porque las ordenes fueron enviadas por distintos Shippers
--> Para probar, cambio en las ordenes del cliente y pongo al mismo shipper
UPDATE ORDERS SET ShipVia = 1 WHERE CustomerID = 'SEVES'

--Ejecuto otra vez la consulta ALL y veo como funciona



SET DATEFORMAT DMY
/* Inserto el cliente PEPSI para probar sustituyendo SEVES x PEPSI*/ 
INSERT INTO CUSTOMERS values('PEPSI','Pepsi Cola Manufacturing','Jhon Smith','Logistic Director','Minessota 2345 54ST','Minessota','West','33100','USA','306789123','3067883245')
INSERT INTO orders VALUES('PEPSI',1,'18-01-1997','18/01/1997','18/01/1997',1,550.40,'Peter White','2340ST 44 DR','Miami','East','33166','USA')
INSERT INTO [Order Details] VALUES(@@IDENTITY,1,38.75,200,0.15)


SELECT ProductName, UnitPrice
FROM Products
WHERE UnitPrice > ALL
    (SELECT UnitPrice
     FROM Products
     WHERE CategoryID = 
         (SELECT CategoryID
          FROM Categories
          WHERE CategoryName = 'Seafood'))

/*4) obtener los clientes que tienen pedidos en todos los países
*/

SELECT *
FROM Customers
WHERE CustomerID = ALL (SELECT CustomerID 
                        FROM Orders 
                        GROUP BY CustomerID 
                        HAVING COUNT(DISTINCT ShipCountry) = (SELECT COUNT(DISTINCT ShipCountry) 
                                                              FROM Orders));


/*5). Obtener todos los clientes que han realizado pedidos exclusivamente a USA.
*/
SELECT *
FROM Customers
WHERE CustomerID IN (SELECT CustomerID 
						FROM Orders 
						WHERE ShipCountry = 'USA'
						EXCEPT
						SELECT CustomerID 
						FROM Orders 
						WHERE ShipCountry <> 'USA');
 


-- Uso de la cláusula ANY y ALL

/*6) Obtener los clientes que han realizado una orden con un numero menor que cualquier orden realizada
    por el cliente con ID 'ALFKI':
*/
SELECT  CompanyName, OrderID
FROM Customers, Orders
WHERE Customers.CustomerID = Orders.CustomerID
AND OrderID < ALL
    (SELECT OrderID
     FROM Orders
     WHERE CustomerID = 'ALFKI')


/*7) Obtener los productos cuyo precio es mayor que el precio de algún producto en la categoría 'Beverages':
*/
SELECT ProductName, UnitPrice
FROM Products
WHERE UnitPrice > ANY
    (SELECT UnitPrice
     FROM Products
     WHERE CategoryID = 
         (SELECT CategoryID
          FROM Categories
          WHERE CategoryName = 'Beverages'))
		  
		  
/*8) Encontrar todos los pedidos que contengan al menos un producto cuyo precio de  venta sea mayor que el precio de lista.
*/

SELECT o.OrderID, o.OrderDate
FROM Orders o
inner join [Order Details] od on od.OrderID  = o.OrderID
inner join Products p on p.ProductID = od.ProductID
WHERE od.UnitPrice > ANY (SELECT p2.UnitPrice
                         FROM Products p2 
                         WHERE p2.ProductID = p.ProductID)		  
			  

-- Uso de la cláusula SOME
/*9).	Obtener los clientes que han realizado un pedido con un valor mayor que el valor mínimo de algún pedido 
realizado por el cliente con ID 'ALFKI':
*/

SELECT CompanyName, OrderID
FROM Customers, Orders
WHERE Customers.CustomerID = Orders.CustomerID
AND OrderID > SOME
    (SELECT MIN(OrderID)
     FROM Orders
     WHERE CustomerID = 'ALFKI')


-- Utilizando SELECT en el SELECT
/*10)	Obtener el nombre de cada producto y la diferencia entre su precio de venta y el precio promedio de todos los productos:
*/
SELECT ProductName, UnitPrice - (SELECT AVG(UnitPrice) 
                                 FROM Products) AS PriceDifference
FROM Products

/*11)	Obtener el nombre de cada proveedor y cantidad de productos que suministra, si algun proveedor no
suministra productos, también deben figurar sus datos
*/
SELECT CompanyName, (SELECT COUNT(*) 
                     FROM Products 
					 WHERE SupplierID = Suppliers.SupplierID) AS NumProductsSupplied
FROM Suppliers

-- Uso de Sub Consultas en el HAVING
/*12).	Obtener el país y el número de clientes que tienen un número de pedidos mayor que el promedio:
*/
SELECT Country, COUNT(*) AS NumCustomersWithMoreOrders
FROM Customers
WHERE CustomerID IN (
  SELECT CustomerID
  FROM Orders
  GROUP BY CustomerID
  HAVING COUNT(*) > (SELECT AVG(NumOrders) FROM (
    SELECT CustomerID, COUNT(*) AS NumOrders
    FROM Orders
    GROUP BY CustomerID) AS Subquery))
GROUP BY Country

/*13).	Obtener el nombre del producto y su cantidad en stock para los productos cuyo nombre contienen 
la cadena 'queso' y su cantidad en stock es mayor que el doble de la cantidad media en stock de todos 
los productos de la misma categoría:
*/
SELECT ProductName, UnitsInStock
FROM Products
WHERE ProductName LIKE '%queso%' AND UnitsInStock > 2 * (
  SELECT AVG(UnitsInStock)
  FROM Products
  WHERE CategoryID = Products.CategoryID)

-- Uso de la cláusula EXIST
/*14).	Obtener el nombre de los empleados que hayan realizado ventas:
*/
SELECT FirstName, LastName
FROM Employees
WHERE EXISTS (
  SELECT *
  FROM Orders
  WHERE Orders.EmployeeID = Employees.EmployeeID)

/*15).	Obtener el nombre de los productos que hayan sido vendidos al menos una vez en una orden con un descuento 
mayor que el 10%:
*/
SELECT ProductName
FROM Products
WHERE EXISTS (
  SELECT *
  FROM [Order Details] d, Orders
  WHERE d.ProductID = Products.ProductID AND 
        d.OrderID = Orders.OrderID AND 
		d.Discount > 0.1)

/*16).	Obtener el nombre de los empleados que hayan realizado ventas a clientes de España:
*/
SELECT FirstName, LastName
FROM Employees
WHERE EXISTS (
  SELECT *
  FROM Orders, Customers
  WHERE Orders.EmployeeID = Employees.EmployeeID AND 
        Orders.CustomerID = Customers.CustomerID AND 
		Customers.Country = 'Spain')

/*17.	Obtener el nombre de los productos que hayan sido vendidos al menos una vez en una orden con una fecha 
de envío posterior al 1 de enero de 1998:
*/
SELECT ProductName
FROM Products
WHERE EXISTS (
  SELECT *
  FROM [Order Details] d, Orders
  WHERE d.ProductID = Products.ProductID AND 
        d.OrderID = Orders.OrderID AND 
		Orders.ShippedDate > '1998-01-01')

/* USO DE LEFT, RIGHT, FULL JOIN*/

--19-) LISTAR LA CANTIDAD DE ORDENES POR CLIENTES. INCLUIR AQUELLOS QUE NO HICIERON ORDENES TAMBIEN 

SELECT C.CustomerID,COUNT(O.OrderID) AS CANTORDENES
FROM CUSTOMERS C
LEFT JOIN ORDERS O ON O.CustomerID = C.CustomerID
GROUP BY C.CustomerID
ORDER BY CANTORDENES ASC

--20-) LISTAR LOS EMPLEADOS  Y DATOS DE ORDENES TRABAJADAS. INCLUIR AQUELLOS EMPLEADPS QUE NO TUVIERON ORDENES

SELECT *
FROM Employees E
LEFT JOIN ORDERS O ON E.EmployeeID = O.EmployeeID
ORDER BY E.EmployeeID DESC

--AGREGO UN EMPLEADO DE PRUEBA--
INSERT INTO Employees VALUES ('EMPLEADO','DE PRUEBA', 'SEÑOR','SR','1/2/1980',gETDATE(),'CUAREIM ESQ. MERCEDES','MVD',
                              NULL,'11300','UY','99999999',4444,NULL,NULL,NULL,NULL)
 
 --> QUE PASA SI LA MISMA QUERY LA HAGO CON RIGHT JOIN?
 SELECT *
FROM Employees E
RIGHT JOIN ORDERS O ON E.EmployeeID = O.EmployeeID
ORDER BY E.EmployeeID DESC

--> QUE PASA SI LA MISMA QUERY LA HAGO CON FULL JOIN?
 SELECT *
FROM Employees E
FULL JOIN ORDERS O ON E.EmployeeID = O.EmployeeID
ORDER BY E.EmployeeID DESC
 

 /* DML CON SUBCONSULTAS*/

 /*21). Agregar una columna "FLAG" de tipo INT a la tabla CUSTOMERS y asignarle el valor 1 a aquellos clientes que  unicamente hicieron pedidos a Francia.
*/

ALTER TABLE CUSTOMERS ADD FLAG INT

UPDATE Customers SET
FLAG = 1
WHERE CustomerID IN (SELECT CustomerID
						FROM Customers
						WHERE CustomerID IN (SELECT CustomerID 
												FROM Orders 
												WHERE ShipCountry = 'France'
												EXCEPT
												SELECT CustomerID 
												FROM Orders 
												WHERE ShipCountry <> 'France'))
 

 /*22). BORRAR AQUELLOS CLIENTES QUE TENGAN MENOS DE  3 ORDENES REALIZADAS */
 DELETE 
 FROM Customers
 WHERE CUSTOMERID IN (
						SELECT O.CustomerID
						FROM Orders O
						GROUP BY O.CustomerID
						HAVING COUNT(O.ORDERID) < 3)
