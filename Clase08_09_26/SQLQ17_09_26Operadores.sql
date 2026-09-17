USE Astilleros;
GO

--Operadores de conjuntos: UNION, INTERSECT y EXCEPT

--UNION es la unión de 2 tablas, quitando las coincidencias
--UNION ALL trae las coincidencias
--Listar en una pantalla todos los clientes y todos los proveedores
SELECT nombre AS 'Nombre' , localidad AS 'Localidad' FROM clientes
UNION 
SELECT nombre, localidad FROM proveedores;
GO

--INTERSECT solo trae los datos que esten en ambas tablas a la vez
SELECT localidad AS 'Localidad' FROM clientes
INTERSECT
SELECT localidad FROM proveedores;
GO

--EXCEPT solo trae los datos que esten en 1 sola tabla a la vez
SELECT localidad AS 'Localidad' FROM clientes
EXCEPT
SELECT localidad FROM proveedores;
GO

--Ordenar los datos con ORDER BY
SELECT nombre AS 'Nombre',localidad AS 'Localidad' FROM clientes
UNION
SELECT nombre AS 'Nombre', localidad FROM proveedores
ORDER BY localidad ASC;
GO

--Ejercicio 1
SELECT nombre AS 'Nombre', telefono AS 'Telefono' FROM clientes
UNION ALL
SELECT nombre, telefono FROM empleados;
GO

--Ejercicio 2
SELECT nombre AS 'Nombre' FROM empleados
UNION
SELECT nombre FROM proveedores
ORDER BY nombre ASC;
GO

--Ejercicio 3
SELECT nombre AS 'Nombre' FROM empleados 
WHERE categoria > 2
UNION
SELECT nombre FROM clientes
ORDER BY nombre ASC;
GO