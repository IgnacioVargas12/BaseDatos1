USE Astilleros
GO

--ROL (Seguridad y Control de Acces0) -> Sentencias DCL (Data Control Lenguage)

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'RolOperativo' AND type = 'R')
	CREATE ROLE RolOperativo;
GO

--GRANT: Concedemos permiso de lectura (SELECT) sobre la tabla clientes
GRANT SELECT ON clientes TO RolOperativo;
GO

--REVOKE: Si por cambios en los requerimientos ya no queremos que tenga ese acceso libre; retiramos el permiso
REVOKE SELECT ON clientes FROM RolOperativo;
GO

--DENY: Denegamos explicitiamente permisos crïticos de borrado (DELETE)
DENY DELETE ON clientes TO RolOperativo;
GO

--Seguridad basada en Vistas (VIEWS)
--Por lo general, no queremos dar permiso de uso de tablas a las personas, por lo que para consultas
--siempre utilizamos vistas para omitir los datos que no queremos mostrar e impedir que se modifiquen los datos
IF OBJECT_ID('VW_EmpleadosPublico', 'V') IS NOT NULL
	DROP VIEW VW_EmpleadosPublico;
GO

CREATE VIEW VW_EmpleadosPublico AS
SELECT empleado, nombre, categoria, estado --Omitimos datos sensibles como cuit, estado civil, dirección
FROM empleados;
GO

--Otorgamos permisos sobre la vista a un rol específico
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'RolPublico' AND type = 'R')
	CREATE ROLE RolPublico;
GO

--Concedemos SELECT exclusivamente sobre la vista segura
GRANT SELECT ON VW_EmpleadosPublico TO RolPublico;
GO

--Creamos una vista de prueba
IF OBJECT_ID('VW_ResumenPresupuestosClientes', 'V') IS NOT NULL
    DROP VIEW VW_ResumenPresupuestosClientes;
GO

CREATE VIEW VW_ResumenPresupuestosClientes AS
SELECT 
    p.presupuesto AS NroPresupuesto,
    p.fecha AS FechaEmision,
    c.nombre AS NombreCliente,
    c.localidad AS LocalidadCliente,
    p.importe AS ImporteTotal
FROM presupuesto p
INNER JOIN clientes c ON p.cliente = c.cliente;
GO

--Realizamos una consulta
SELECT * FROM VW_ResumenPresupuestosClientes WHERE ImporteTotal > 5000;
GO

--Actividada Practica
IF OBJECT_ID('VW_MaterialesPublicos', 'V') IS NOT NULL
    DROP VIEW VW_MaterialesPublicos;
GO

CREATE VIEW VW_MaterialesPublicos AS
SELECT 
    material,
    nombre,
    costo
    -- Omitimos deliberadamente 'proveedor', 'tipomaterial' y 'accesorio' por seguridad
FROM materiales;
GO

-- 1. Nos aseguramos de que el rol exista
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'RolVentas' AND type = 'R')
BEGIN
    CREATE ROLE RolVentas;
END
GO

-- 2. Otorgamos el permiso de lectura exclusivamente sobre la vista segura
GRANT SELECT ON VW_MaterialesPublicos TO RolVentas;
GO


DENY UPDATE, DELETE ON materiales TO RolVentas;
GO

-------------------------------------------------------------
-- PASO 1: Creamos un usuario de prueba para simular al personal de ventas
-------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'UsuarioVentasDemo')
    CREATE USER UsuarioVentasDemo WITHOUT LOGIN;
GO

-- Asignamos nuestro usuario de prueba al RolVentas creado en la Consigna 2
EXEC sp_addrolemember N'RolVentas', N'UsuarioVentasDemo';
GO

-------------------------------------------------------------
-- PASO 2: Simulamos la ejecución con la identidad de [UsuarioVentasDemo]
-------------------------------------------------------------
EXECUTE AS USER = 'UsuarioVentasDemo';
GO

-- PRUEBA 1: Consultar la Vista segura (Debe FUNCIONAR gracias al GRANT de la Consigna 2)
BEGIN TRY
    SELECT TOP 3 material, nombre, costo FROM VW_MaterialesPublicos;
    PRINT 'ÉXITO (GRANT): El usuario pudo consultar la vista segura de materiales.';
END TRY
BEGIN CATCH
    PRINT 'ERROR: No se pudo consultar la vista.';
    PRINT ERROR_MESSAGE();
END CATCH
GO

-- PRUEBA 2: Intentar modificar la tabla física de materiales (Debe FALLAR por el DENY de la Consigna 3)
BEGIN TRY
    UPDATE materiales SET costo = 9999 WHERE material = 101;
    PRINT 'PRUEBA FALLIDA: El usuario pudo modificar la tabla física.';
END TRY
BEGIN CATCH
    PRINT 'ÉXITO (DENY): La modificación de la tabla física fue bloqueada estrictamente por el motor.';
    PRINT 'Mensaje del motor: ' + ERROR_MESSAGE();
END CATCH
GO

-- PRUEBA 3: Intentar borrar de la tabla física materiales (Debe FALLAR también por el DENY)
BEGIN TRY
    DELETE FROM materiales WHERE material = 101;
    PRINT 'PRUEBA FALLIDA: El usuario pudo borrar de la tabla física.';
END TRY
BEGIN CATCH
    PRINT 'ÉXITO (DENY): El borrado de la tabla física fue bloqueado correctamente.';
    PRINT 'Mensaje del motor: ' + ERROR_MESSAGE();
END CATCH
GO

-- Volvemos a nuestra identidad original de administrador (dbo)
REVERT;
GO