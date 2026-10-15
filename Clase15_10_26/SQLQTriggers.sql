USE Astilleros
GO

--Trigger (Disparadores)
-- |--> cuando hay manipulación de datos (Insert, Update, Delete)
--  |--> AFTER Triggers --> Tabla inserted (guarda filas nueva)
--  |--> INSTEAD OF Triggers --> Tabla deleted (guarda filas borradas o modificadas)

-- Cuando utilizamos un TRIGGER automaticamente crea esas 2 tablas en segundo plano pero que no la podemos
-- manipular directamente, utilizando el AFTER TRIGGER podemos crear una tabla para guardar estos registros
-- "secundarios" modificados

--El INSTEAD OF TRIGGER hace exáctamente lo mismo solo que lo hace antes de manipular los datos

--Tabla de respaldo que contiene las auditorias y las modificaciones de presupuestos
CREATE TABLE AuditoriaPresupuestos (
IdAuditoria INT IDENTITY (1,1) PRIMARY KEY,
PresupuestoAfectado INT NOT NULL,
FechaAccion DATETIME DEFAULT GETDATE(),
UsuarioResponsable VARCHAR (50) DEFAULT SYSTEM_USER
);
GO

CREATE TRIGGER TR_AuditarNuevoPresupuesto
ON presupuesto
AFTER INSERT
AS
BEGIN
	INSERT INTO AuditoriaPresupuestos (PresupuestoAfectado) --Ponemos que campos queremos que complete
	SELECT presupuesto --Ponemos los campos de dónde va a sacar los datos
	FROM inserted;
END;
GO

SELECT * FROM AuditoriaPresupuestos;
GO

INSERT INTO presupuesto (presupuesto, fecha, cliente, importe)
VALUES (99901, GETDATE(), 100, 75000.50);
GO

CREATE TRIGGER TR_PrevenirBorradoClienteConPresupuesto
ON clientes
AFTER DELETE
AS
BEGIN
	IF EXISTS(
	SELECT 1 
	FROM deleted d
	INNER JOIN presupuesto p ON d.cliente = p.cliente
	)
	BEGIN
		RAISERROR('Error de negocio, no se puede eliminar un cliente con un presupuesto registrado', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END
END;
GO

--Interceptamos cada vez que se modifique un cliente inactivo para hacerlo activo
CREATE TRIGGER TR_InterceptarClienteInactivo
ON clientes
INSTEAD OF INSERT
AS
BEGIN
    -- Incluimos todas las columnas obligatorias de la tabla física 'clientes' de AstillerosAzure
    INSERT INTO clientes (
        cliente, nombre, direccion, localidad, cp, cuit, ingbrutos,
        sitiva, telefono, fax, contacto, email, estado
    )
    SELECT
        cliente,
        nombre,
        direccion,
        localidad,
        cp,
        cuit,
        ingbrutos,
        sitiva,
        telefono,
        fax,
        contacto,
        email,
        'A' -- <-- Forzamos el estado a Activo por regla de negocio
    FROM inserted;
END;
GO

-- Intentamos dar de alta un cliente enviando explícitamente el estado 'I' (Inactivo)
INSERT INTO clientes (cliente, nombre, cuit, direccion, localidad, cp, telefono, estado, ingbrutos, sitiva, email, fax)
VALUES (8888, 'ASTILLERO PRUEBA INSTEAD', '30-88888888-8', 'Calle 10', 'Cordoba', '5000', '0351-7777777', 'I', '777', '1','wachin@camioneros.com','345-12442' );
GO

-- Verificamos el resultado:
SELECT cliente, nombre, estado FROM clientes WHERE cliente = 8888;
-- Verán que, gracias al INSTEAD OF, el registro se guardó con estado 'A' en lugar de 'I'.

--Ejercicio 1
CREATE TABLE AuditoriaClientes (
    IdAuditoria INT IDENTITY(1,1) PRIMARY KEY,
    ClienteAfectado INT NOT NULL,
    FechaAccion DATETIME DEFAULT GETDATE(),
    UsuarioResponsable VARCHAR(50) DEFAULT SYSTEM_USER
);
GO

CREATE TRIGGER TR_AuditarNuevoCliente
ON clientes
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditoriaClientes (ClienteAfectado)
    SELECT cliente
    FROM inserted;
END;
GO
--Insertamos un cliente
INSERT INTO clientes (cliente, nombre, cuit, direccion, localidad, cp, telefono, estado, ingbrutos, sitiva, email, fax)
VALUES (9999, 'ASTILLERO PRUEBA', '30-99999999-9', 'Puerto 1', 'Cordoba', '5000', '0351-5555555', 'I', '888', '2','piopio@pollitos.com','345-546245' );
GO

-- Verificación: Consultamos la tabla de auditoría
SELECT * FROM AuditoriaClientes;
GO

--Ejercicio 2
CREATE TRIGGER TR_PrevenirBorradoMaterialCostoso
ON materiales
AFTER DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM deleted
        WHERE costo > 10000.00
    )
    BEGIN
        RAISERROR('Error de Negocio: No se puede eliminar un material cuyo costo sea mayor a $10.000.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

--Ejercicio 3
UPDATE materiales
SET costo = 15000.00
WHERE material = 101;
GO

DELETE FROM materiales
WHERE material = 101;
GO
