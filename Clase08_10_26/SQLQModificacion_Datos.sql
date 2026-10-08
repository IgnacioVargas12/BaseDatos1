USE Astilleros;
GO

--Modificación de Datos (Se recomienda armar un select antes de ejecutar)
--Actualización simple de un registro único
UPDATE clientes
SET telefono = '0351-555999'
WHERE cliente = 100;
GO

--Actualización de múltiples columnas
UPDATE materiales
SET nombre = 'Fibra de vidrio reforzada', costo = 1650.00
WHERE material = 101;
GO

--Actualización masiva basada en condiciones (WHERE amplio)
--Se realiza un aumento del 15% a todos los materiales que pertenezcan a un modelo específico
UPDATE materiales
SET costo = costo * 1.15
WHERE modelo = 1;
GO


--DELETE: eliminación de registros/filas
DELETE FROM presupuesto
WHERE presupuesto = 5004;
GO

--ACTIVIDAD A
UPDATE empleados
SET estadocivil = 'C', telefono = '351-8888777'
WHERE empleado = 9;
GO

SELECT estadocivil FROM empleados where empleado = 9; 
GO

--ACTIVIDAD B
UPDATE materiales
SET costo = costo * 1.10
WHERE costo < 1000;
GO

SELECT costo FROM materiales WHERE costo < 1000;
GO

--ACTIVIDAD C
SELECT * FROM clientes WHERE cliente = 1;
GO

DELETE FROM clientes WHERE cliente = 1;
GO --Da error ya que tenemos varias FK sin la CONSTRAINT DELETE CASCADE

--ACTIVIDAD D
SELECT presupuesto FROM presupuesto WHERE presupuesto = 5001;
GO

DELETE FROM presupuesto
WHERE presupuesto = 5001;
GO

--TRUNCATE: Borrado Masivo
--Sintaxis básica:

--TRUNCATE TABLE NombreTabla; 
--GO