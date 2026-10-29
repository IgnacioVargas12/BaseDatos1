USE DB_Vargas
GO

-- Etapa 3: Optimización y Automatización Avanzada
-- Optimización con índices
-- 1. Índice para acelerar las búsquedas por el título del libro (Cláusula WHERE o JOIN en Libros)
CREATE NONCLUSTERED INDEX IX_Libros_Titulo 
ON Libros (titulo);
GO

-- 2. Índice para acelerar los reportes y filtros por fecha en las ventas
CREATE NONCLUSTERED INDEX IX_Ventas_Fecha 
ON Ventas (Fecha);
GO

SELECT * FROM Libros WHERE titulo = 'Cien Años de Soledad';
GO

-- Automatización y reglas de negocio con Triggers
CREATE TABLE AuditoriaVentas (
    idAuditoria INT IDENTITY NOT NULL,
    idVentaRegistrada INT NOT NULL,
    IdEmpleado INT NOT NULL,
    IdCliente INT NOT NULL,
    FechaVenta DATE NOT NULL,
    FechaHoraAuditoria DATETIME NOT NULL CONSTRAINT DF_FechaAuditoria DEFAULT GETDATE(),
    CONSTRAINT PK_AuditoriaVentas PRIMARY KEY (idAuditoria)
);
GO

-- Crear el Trigger AFTER INSERT en la tabla Ventas
CREATE TRIGGER trg_AuditoriaNuevasVentas
ON Ventas
AFTER INSERT
AS
BEGIN
    -- Insertamos automáticamente en la tabla de auditoría usando la tabla mágica 'inserted'
    INSERT INTO AuditoriaVentas (idVentaRegistrada, IdEmpleado, IdCliente, FechaVenta)
    SELECT idVenta, idEmpleado, idCliente, Fecha
    FROM inserted;
END;
GO

-- Comprobación del trigger
-- PASO 1: Ver el estado de la tabla de auditoría ANTES de la inserción
PRINT '--- Estado actual de la Auditoría (Antes) ---';
SELECT * FROM AuditoriaVentas;
GO

-- PASO 2: Insertar la nueva venta (Cabecera) y guardar su ID
INSERT INTO Ventas (idEmpleado, idCliente, Fecha) 
VALUES (1, 1, GETDATE());

-- Capturamos automáticamente el idVenta que se acaba de generar
DECLARE @IdVentaNueva INT = SCOPE_IDENTITY();

-- PASO 3: Insertar los ítems en el Detalle de la Venta
INSERT INTO DetalleVentas (idVenta, idLibro, Cantidad, PrecioUnitario) 
VALUES (@IdVentaNueva, 1, 2, 12500.00);
GO

-- PASO 4: Comprobar el funcionamiento del Trigger de Auditoría
PRINT '--- Estado de la Auditoría DESPUÉS del Trigger (AFTER INSERT) ---';
SELECT * FROM AuditoriaVentas ORDER BY idAuditoria DESC;
GO

-- Trigger Delete: No permitimos borrar libros que no estén agotados
CREATE TRIGGER trg_Libros_ValidarBorrado
ON Libros
INSTEAD OF DELETE
AS
BEGIN
    -- Verificamos si alguno de los libros que se intenta borrar tiene stock > 0
    IF EXISTS (
        SELECT 1 
        FROM deleted D 
        WHERE D.cantidad > 0
    )
    BEGIN
        -- Lanzamos un error descriptivo y detenemos la operación
        RAISERROR('Error de negocio: No se puede eliminar un libro que cuenta con stock activo en el inventario.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Si no tienen stock (cantidad = 0), permitimos el borrado físicamente
    DELETE FROM Libros
    WHERE idLibro IN (SELECT idLibro FROM deleted);
END;
GO

-- Comprobación
DELETE FROM Libros WHERE idLibro = 1;
GO

-- Etapa 4: Logins, Usuarios y Roles
USE master;
GO

-- 1. Crear el Login 
CREATE LOGIN UsuOperador_Vargas WITH PASSWORD = 'Contraseña_1234';
GO

-- 2. Entrar a tu base de datos
USE DB_Vargas;
GO

-- 3. Asociar (mapear) el Login de servidor con el usuario que ya tenías en la base de datos
-- (Esto soluciona el usuario huérfano si ya existía en el script)
ALTER USER UsuOperador_Vargas WITH LOGIN = UsuOperador_Vargas;
GO

-- 1. Crear un nuevo Rol de base de datos personalizado
CREATE ROLE RolSoloLectura;
GO

-- 2. Otorgar permisos EXCLUSIVOS de lectura (SELECT) sobre las Vistas del sistema
-- El operador podrá ver los reportes pero no alterar tablas base ni hacer DML
GRANT SELECT ON vw_CatalogoLibrosDetallado TO RolSoloLectura;
GRANT SELECT ON vw_ResumenVentasCabecera TO RolSoloLectura;
GO

-- 3. Agregar al usuario 'UsuOperador_Vargas' como miembro de este nuevo rol
ALTER ROLE RolSoloLectura ADD MEMBER UsuOperador_Vargas;
GO

EXECUTE AS USER ='UsuOperador_Vargas';
GO

SELECT * FROM vw_CatalogoLibrosDetallado;
GO

SELECT * FROM vw_ResumenVentasCabecera;
GO

DELETE FROM Libros WHERE idLibro = 1;
GO