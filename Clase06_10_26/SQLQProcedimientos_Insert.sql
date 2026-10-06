USE Astilleros;
GO

--Procedimientos almacenados (2º Parte)
CREATE PROCEDURE dbo.sp_RegistrarPresupuestoSeguro
    @Presupuesto INT,
    @Fecha DATETIME,
    @Cliente INT,
    @Importe DECIMAL(12,2)
AS
BEGIN
    -- 1. Iniciamos la transacción
    BEGIN TRANSACTION;

    BEGIN TRY
        -- 2. Validación de negocio usando SELECT 1 por eficiencia
        IF NOT EXISTS (SELECT 1 FROM clientes WHERE cliente = @Cliente)
        BEGIN
            RAISERROR('El cliente especificado no existe en el sistema.', 16, 1);
        END

        -- 3. Intentamos la inserción
        INSERT INTO presupuesto (presupuesto, fecha, cliente, importe)
        VALUES (@Presupuesto, @Fecha, @Cliente, @Importe);

        -- 4. Si todo salió bien, confirmamos permanentemente
        COMMIT TRANSACTION;
        PRINT 'Presupuesto registrado y confirmado con éxito.';

    END TRY
    BEGIN CATCH
        -- 5. Si ocurre un error, deshacemos todo lo hecho en esta transacción
        ROLLBACK TRANSACTION;
       
        RAISERROR('La transacción falló y fue cancelada por completo.', 16, 1);
    END CATCH
END;
GO

EXEC dbo.sp_RegistrarPresupuestoSeguro
@Presupuesto = 10,
@Fecha = '20261025',
@Cliente = 101,
@Importe = 2500;
GO

SELECT * FROM presupuesto;
GO

-- =========================================================================
-- EJERCICIO 1: Prueba de Validación con SELECT 1
-- Ejecutar una consulta utilizando SELECT 1 para verificar la existencia
-- de empleados que pertenezcan a la categoría 2.
-- =========================================================================

IF EXISTS (SELECT 1 FROM empleados WHERE categoria = 2)
BEGIN
    PRINT '¡Aviso! Sí existen empleados registrados en la categoría 2.';
   
    -- Listamos los empleados para complementar la validación
    SELECT empleado, nombre, categoria
    FROM empleados
    WHERE categoria = 2;
END
ELSE
BEGIN
    PRINT 'No se encontraron empleados en dicha categoría.';
END
GO

-- =========================================================================
-- EJERCICIO 2: Creación del Procedimiento Transaccional
-- Diseñar un procedimiento almacenado llamado sp_ActualizarCostoConTransaccion
-- que reciba un código de material y un nuevo costo, evaluando dentro de un
-- TRY...CATCH con transacción que el costo no sea negativo.
-- =========================================================================

CREATE PROCEDURE dbo.sp_ActualizarCostoConTransaccion
    @IdMaterial INT,
    @NuevoCosto DECIMAL(10,2)
AS
BEGIN
    -- 1. Iniciamos la transacción explícita
    BEGIN TRANSACTION;

    BEGIN TRY
        -- 2. Validación de negocio: El costo no puede ser negativo
        IF @NuevoCosto < 0
        BEGIN
            RAISERROR('Error: El costo del material no puede ser un valor negativo.', 16, 1);
        END

        -- 3. Validación de existencia: Verificamos que el material exista
        IF NOT EXISTS (SELECT 1 FROM materiales WHERE material = @IdMaterial)
        BEGIN
            RAISERROR('Error: El material especificado no existe en el sistema.', 16, 1);
        END

        -- 4. Ejecutamos la actualización del costo
        UPDATE materiales
        SET costo = @NuevoCosto
        WHERE material = @IdMaterial;

        -- 5. Si todo salió bien, confirmamos los cambios permanentemente en disco
        COMMIT TRANSACTION;
        PRINT 'Costo actualizado y transacción confirmada con éxito.';

    END TRY
    BEGIN CATCH
        -- 6. Si ocurre cualquier error, revertimos toda la transacción
        ROLLBACK TRANSACTION;
       
        -- Lanzamos un mensaje informativo con el error capturado
        RAISERROR('La operación falló. Se han revertido todos los cambios por seguridad.', 16, 1);
    END CATCH
END;
GO

-- =========================================================================
-- EJERCICIO 3: Prueba de Fallo
-- Ejecutar el procedimiento pasando un costo negativo para comprobar
-- que la base de datos rechace la operación y aplique el ROLLBACK.
-- =========================================================================

-- Paso A: Consultar el costo actual del material 101 para tenerlo de referencia
SELECT material, nombre, costo
FROM materiales
WHERE material = 101;
GO

-- Paso B: Ejecutar el procedimiento pasando un costo inválido (ej: -500.00)
EXEC dbo.sp_ActualizarCostoConTransaccion
    @IdMaterial = 101,
    @NuevoCosto = -500.00;
GO

-- Paso C: Verificar que el costo NO haya cambiado gracias al ROLLBACK automático
SELECT material, nombre, costo
FROM materiales
WHERE material = 101;
GO

-- =========================================================================
-- EJERCICIO 1: Inserción Individual en la tabla proveedores
-- Completando todos los campos obligatorios definidos en su estructura.
-- =========================================================================

INSERT INTO proveedores (
    proveedor, nombre, cuit, ingbrutos, domicilio, cp, localidad,
    telefono, fax, contacto, email, fantasia, sitiva,
    retencionganancia, agenteretencion, provbdecambio, estado
)
VALUES (
    1258, 'ACEROS NAVALES SA', '30-44444444-1', '444444', 'Av. Industrial 500',
    5000, 'Cordoba', '0351-4999999', '0351-4999999', 'Esteban',
    'ventas@acerosnavales.com', 'ACEROS NAVALES', 1, 'S', 'S', 'N', 'A'
);
GO

-- Verificación de la inserción individual
SELECT proveedor, nombre, localidad FROM proveedores WHERE proveedor = 1258;
GO

-- =========================================================================
-- EJERCICIO 2: Inserción Múltiple en la tabla materiales
-- Dando de alta dos nuevos materiales utilizando un único comando INSERT
-- con múltiples valores en la cláusula VALUES.
-- =========================================================================

INSERT INTO materiales (material, nombre, modelo, costo)
VALUES
(107, 'Lona Náutica Impermeable (M2)', 1, 1200.00),
(108, 'Adhesivo Epoxi Naval (Litros)', 2, 2300.50);
GO

-- Verificación de la inserción múltiple
SELECT material, nombre, costo FROM materiales WHERE material IN (107, 108);
GO

-- =========================================================================
-- EJERCICIO 3: Prueba de INSERT INTO ... SELECT
-- =========================================================================

-- Paso A: Crear la tabla de destino 'EmpleadosCategoria2' previamente
CREATE TABLE EmpleadosCategoria2 (
    empleado INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    estadocivil CHAR(1) NOT NULL,
    cuil VARCHAR(13) NOT NULL,
    direccion VARCHAR(50) NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    categoria INT NOT NULL,
    estado CHAR(1) NOT NULL,
    CONSTRAINT PK_EmpleadosCategoria2 PRIMARY KEY (empleado)
);
GO

-- Paso B: Poblar la nueva tabla copiando únicamente a los empleados con categoria = 2
INSERT INTO EmpleadosCategoria2 (empleado, nombre, estadocivil, cuil, direccion, telefono, categoria, estado)
SELECT empleado, nombre, estadocivil, cuil, direccion, telefono, categoria, estado
FROM empleados
WHERE categoria = 2;
GO

-- Paso C: Verificar el resultado de la transferencia de datos
SELECT * FROM EmpleadosCategoria2;
GO