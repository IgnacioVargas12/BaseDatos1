USE Astilleros;
GO

--Procedimientos Almacenados (Stored Procedures)
CREATE PROCEDURE dbo.sp_Listar_Empleados AS BEGIN
SELECT empleado, nombre, categoria 
FROM dbo.empleados 
ORDER BY nombre ASC;
END;
GO

--Como ejecutar el procedimiento
EXECUTE dbo.sp_Listar_Empleados;
GO

--Procedimiento el cual recibe un parámetro/dato específico de entrada
CREATE PROCEDURE dbo.sp_Empleados_Categoria @CategoriaBuscada INT AS BEGIN
SELECT empleado, nombre, categoria 
FROM dbo.empleados 
WHERE categoria = @CategoriaBuscada;
END;
GO

EXECUTE dbo.sp_Empleados_Categoria @CategoriaBuscada = 3;
GO

--Procedimiento el cual da una variable de salida
CREATE PROCEDURE dbo.sp_Contar_Materiales_Modelo @ModeloBuscado INT, @TotalMateriales INT OUTPUT AS BEGIN
SELECT @TotalMateriales = COUNT (*) FROM dbo.materiales
WHERE modelo = @ModeloBuscado;
END;
GO

DECLARE @Resultado INT;
EXECUTE dbo.sp_Contar_Materiales_Modelo @ModeloBuscado = 10, @TotalMateriales = @Resultado OUTPUT;
PRINT 'La cantidad total de materiales es: ' + CAST (@Resultado AS VARCHAR)
GO

--Ejercicio
CREATE PROCEDURE dbo.sp_Presupuestos_Cliente @CodigoCliente INT AS BEGIN
SELECT presupuesto, fecha, importe 
FROM dbo.presupuesto
WHERE cliente = @CodigoCliente;
END;
GO

EXECUTE dbo.sp_Presupuestos_Cliente @CodigoCliente = 1;
GO

--Ejemplo de PROCEDURE más elaborado
CREATE PROCEDURE dbo.sp_InsertarOrdenProcesoSegura
@op NUMERIC(18,0),
@proceso INT,
@modelo INT,
@empleado INT,
@fechainicio DATETIME,
@fechafin DATETIME,
@estado CHAR(1)
AS
BEGIN
-- Validamos si el empleado existe en la tabla previamente cargada
IF NOT EXISTS (SELECT 1 FROM dbo.empleados WHERE empleado = @empleado)
BEGIN
RAISERROR('Error: El legajo del empleado ingresado no existe en el sistema.', 16, 1);
RETURN; -- Sale del procedimiento de forma anticipada
END

-- Bloque protegido para inserción
BEGIN TRY
INSERT INTO dbo.ordenproceso (op, proceso, modelo, empleado, fechainicio, fechafin, estado)
VALUES (@op, @proceso, @modelo, @empleado, @fechainicio, @fechafin, @estado);

PRINT 'Orden de proceso registrada exitosamente.';
END TRY
BEGIN CATCH
RAISERROR('Ocurrió un error inesperado al insertar la orden.', 16, 1);
END CATCH
END;
GO


EXEC dbo.sp_InsertarOrdenProcesoSegura
@op = 2001,
@proceso = 1,
@modelo = 1,
@empleado = 999,
@fechainicio = '20260320',
@fechafin = '20260325',
@estado = 'P';
GO