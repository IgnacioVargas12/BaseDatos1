USE Astilleros
GO

--Combinación de tablas: JOIN - INNER JOIN
--Traemos los empleados y los procesos que realizan
SELECT empleados.nombre AS 'Nombre', ordenproceso.op AS 'Orden proceso', ordenproceso.fechainicio AS 'Fecha inicio' 
FROM empleados INNER JOIN ordenproceso
ON empleados.empleado = ordenproceso.empleado;
GO

--Ahora utilizamos AS para cambiar el alias de las tablas
SELECT e.nombre AS 'Nombre', o.op AS 'Orden proceso', o.fechainicio AS 'Fecha inicio' 
FROM empleados AS e INNER JOIN ordenproceso AS o
ON e.empleado = o.empleado;
GO

--Traemos todos los empleados independientemente de si tiene un proceso a cargo
-- El LEFT JOIN hace que la tabla izquierda este completa
SELECT e.nombre AS 'Nombre', o.op AS 'Orden proceso'
FROM empleados AS e LEFT JOIN ordenproceso AS o
ON e.empleado = o.empleado;
GO

SELECT e.nombre AS 'Nombre', e.EsSupervisadoPor AS 'Supervisador'
FROM empleados AS e;
GO

--Lo mismo que LEFT JOIN pero a la inversa
SELECT e.nombre AS 'Nombre', o.op AS 'Orden proceso'
FROM ordenproceso AS o RIGHT JOIN empleados AS e
ON o.empleado = e.empleado ;
GO

--CROSS JOIN arroja todas las combinaciones posibles entre las tablas
SELECT e.nombre AS 'Empleado', c.nombre AS 'Cliente a inspeccionar'
FROM empleados AS e CROSS JOIN clientes AS c;
GO

--Combinar JOIN con WHERE: trae el primer empleado que tenga una orden de proceso
SELECT e.nombre AS 'Empleado', o.op AS 'Numero de orden', o.fechainicio AS 'Fecha inicio'
FROM empleados AS e INNER JOIN ordenproceso AS o
ON e.empleado = o.empleado
WHERE e.empleado = 1;
GO

--Cruce de 3 tablas con Auto-Join
SELECT e.nombre AS 'Empleado',s.nombre AS 'Supervisor', o.op AS 'Numero de orden', o.fechainicio
FROM empleados as e INNER JOIN empleados AS s 
ON e.EsSupervisadoPor = s.empleado
INNER JOIN ordenproceso AS o 
ON e.empleado = o.empleado;
GO