/*--------------------------------------------------------------------------------------*/
--REPASO GENERAL DE SELECT + INNER JOIN + AGRUPAMIENTO
/*--------------------------------------------------------------------------------------*/


--1) Averiguar el producto más caro
SELECT TOP 1 * 
FROM Products 
order by UnitPrice desc

--2) Productos que que precio unitario superan el precio unitario promedio
select distinct ProductName, UnitPrice
from Products
where UnitPrice > (select avg(UnitPrice) from Products)
order by UnitPrice;

--3) Listado que muestre la  Cantidad de Ordenes por empleado y el valor maximo de peso (Freight) de las ordenes que generó
--sin incluir Ordenes pendientes (que aun no tiene fecha de envio (ShippedData) ; y que el peso grupal sea mayor/igual a 800

SELECT EmployeeID,COUNT(*) as CantOrdenes, MAX(Freight) as PesoMax
FROM Orders
WHERE ShippedDate IS NOT NULL
GROUP BY  EmployeeID
HAVING MAX(Freight) >= 800
ORDER BY EmployeeID


--4)Listado de Id de Ordenes y Cantidad de lineas/items que tiene cada una para aquellas ordenes enviadas por el flete 3 (col shipvia)
-- de aquellas ordenes que tienen mas de 1 item /producto

SELECT o.OrderID, COUNT(*) AS Lines
FROM orders o 
JOIN [order details] od
ON o.OrderID = od.OrderID
WHERE ShipVia = 3
GROUP BY o.OrderID
HAVING COUNT(*) > 1
ORDER BY o.OrderID


--5) Listado de Cantidad de Ventas por categoria y por pais
SELECT CategoryName, Country, COUNT(*) AS Count
FROM "Order Details" O, Products P, Categories C, Suppliers S
WHERE O.ProductID = P.ProductID AND P.CategoryID = C.CategoryID AND
P.SupplierID = S.SupplierID
GROUP BY CategoryName, Country
ORDER BY CategoryName, Country

--6) Listado de las 3 categorias que mas ventas(Ordenes) tuvieron (en cantidad de ordenes)
SELECT  TOP 3 c.CategoryName, s.Country, COUNT(distinct o.OrderID) AS cant
FROM "Order Details" d
inner join Orders o on d.OrderID = o.OrderID
inner join Products P on p.ProductID = d.ProductID
inner join Categories C on c.CategoryID  = p.CategoryID
inner join Suppliers S on s.SupplierID = p.SupplierID
GROUP BY c.CategoryName,s.Country
ORDER BY cant desc

--7) Calcular el número de pedidos por cliente
SELECT c.companyname,count(o.OrderID) total 
FROM customers c
inner join orders o on c.CustomerID = o.CustomerID
group by c.CompanyName


--8) Calcular el total de ventas por empleado
SELECT e.LastName,sum(d.quantity*d.UnitPrice) total 
FROM employees e
join orders o on e.EmployeeID = o.EmployeeID
join [Order Details] d on d.OrderID = o.OrderID 
group by e.LastName

--9) Averiguar el Total de Ordenes de Compra en que se vendio cada producto
select p.ProductName,  count(*) as Total
from products p
inner join [Order Details] d on d.ProductID = p.ProductID
inner join Orders o on o.OrderID = d.OrderID
group by p.ProductName
order by total desc

--10) Averiguar el Total de $ en ventas por producto
select p.ProductName, sum(d.quantity*d.UnitPrice) total 
from products p
inner join [Order Details] d on d.ProductID = p.ProductID
group by p.ProductName

--11) Mostrar aquellos productos que su precio unitario  sea mayor a $15
select p.ProductName,p.UnitPrice
from products p
where p.unitprice > 15
 

--12) Mostrar aquellos productos que su precio unitario promedio es Mayor al precio promedio de los productos que su rango de precio unitario varia entre 15 y 19 $   (SUBCONSULTAS)
select p.ProductName, avg(p.unitprice) as prom
from products p
group by p.ProductName
having avg(p.unitprice) > (SELECT avg(p1.unitprice) FROM Products p1 WHERE p1.UnitPrice BETWEEN 15 AND 19)
order by prom desc

--13) Mostrar los clientes con más de $100000 en ventas
select c.CompanyName, sum(d.quantity*d.UnitPrice) as total 
from customers c 
join orders o on c.CustomerID = o.CustomerID
join [Order Details] d on d.OrderID = o.OrderID
group by c.CompanyName
having sum(d.quantity*d.UnitPrice) > 100000
order by total desc

--14) Mostrar los primeros 5 clientes que compraron más de 3 veces(ordenes) en el año 1996
select top 5 c.CompanyName, count(o.OrderID) as total 
from customers c 
join orders o on c.CustomerID = o.CustomerID
where year(o.OrderDate) = 1996
group by c.CompanyName
having count(o.OrderID) > 3
order by total desc


--15) Ver la cantidad de $ pagados de las compras realizadadas x cliente
select c.CompanyName, SUM(d.Quantity*d.UnitPrice) as total 
from customers c 
join orders o on c.CustomerID = o.CustomerID
join [Order Details] d on d.OrderID = o.OrderID
group by c.CompanyName
order by c.CompanyName

--16) Mostrar al cliente que pagó mas $ en un item de una orden de compra realizada. (Si deseo saber la factura total mas grande, debo usar subconsultas)

select TOP 1 c.CompanyName, MAX(d.Quantity*d.UnitPrice - d.Quantity*d.UnitPrice * d.Discount) as total 
from customers c 
join orders o on c.CustomerID = o.CustomerID
join [Order Details] d on d.OrderID = o.OrderID
group by c.CompanyName
order by total desc


 



