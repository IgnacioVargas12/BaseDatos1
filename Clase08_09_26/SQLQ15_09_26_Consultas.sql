USE Astilleros;
GO
--Consulta anidadas (primero se resuelve la consulta de los paréntesis)
--En este caso, vemos los empleados con categoría mayor al promedio en categoría
SELECT empleado, nombre, categoria FROM empleados 
WHERE categoria > (SELECT AVG (categoria) FROM empleados);
GO

--Nos trae a los empleados con al menos un orden proceso
--El IN trae los datos que esten en ambas tablas
SELECT empleado, nombre, categoria FROM empleados
WHERE empleado IN (SELECT empleado FROM ordenproceso);
GO

--Trae a los empleados que NO tienen ordenes de proceso
SELECT empleado, nombre, categoria FROM empleados
WHERE empleado NOT IN (SELECT empleado FROM ordenproceso);
GO

--Exists (Devuelve lógicamente un SI o NO). Una vez que encuentra un Si, deja de ejecutarse
--Traemos solo los empleados que si tienen una orden de proceso asignada
SELECT empleado, nombre, categoria FROM empleados E 
WHERE EXISTS (SELECT 1 FROM ordenproceso OP 
WHERE OP.empleado = E.empleado);
GO
--Verificamos todos los empleados
SELECT * FROM empleados;
GO

--Traemos al empleado mas viejo
SELECT empleado, categoria, nombre, fechanacimiento FROM empleados
WHERE fechanacimiento = (SELECT MIN (fechanacimiento) FROM empleados);
GO