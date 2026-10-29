-- 1.4. Consultas
--1.4.1 Consulta: Total gastado por cada cliente
SELECT 
    C.Nombre AS Cliente, 
    SUM(DV.Cantidad * DV.PrecioUnitario) AS TotalGastado
FROM Clientes C
INNER JOIN Ventas V ON C.idCliente = V.idCliente
INNER JOIN DetalleVentas DV ON V.idVenta = DV.idVenta
GROUP BY C.Nombre;
GO

--1.4.2 Consulta: Clientes con mayor volumen de compras
SELECT 
    C.Nombre AS Cliente,
    COUNT(V.idVenta) AS TotalTickets,
    SUM(DV.Cantidad * DV.PrecioUnitario) AS GastoTotal
FROM Clientes C
INNER JOIN Ventas V ON C.idCliente = V.idCliente
INNER JOIN DetalleVentas DV ON V.idVenta = DV.idVenta
WHERE V.Fecha >= '2026-01-01'
GROUP BY C.Nombre
HAVING SUM(DV.Cantidad * DV.PrecioUnitario) > 10000;
GO

-- 1.4.3 Consulta: Libros de un género específico con stock crítico
SELECT 
    L.titulo AS Libro,
    A.nombre AS Autor,
    E.nombre AS Editorial,
    L.cantidad AS StockActual,
    L.precio AS Precio
FROM Libros L
INNER JOIN Autores A ON L.idAutor = A.idAutor
INNER JOIN Editoriales E ON L.idEditorial = E.idEditorial
INNER JOIN Generos G ON L.idGenero = G.idGenero
WHERE G.nombre = 'Ficción' AND L.cantidad <= 10;
GO

-- 1.4.4 Consulta: Rendimiento y recaudación por empleado
SELECT 
    Emp.Nombre AS Empleado,
    COUNT(DISTINCT V.idVenta) AS TicketsAtendidos,
    SUM(DV.Cantidad * DV.PrecioUnitario) AS RecaudacionTotal
FROM Empleados Emp
INNER JOIN Ventas V ON Emp.idEmpleado = V.idEmpleado
INNER JOIN DetalleVentas DV ON V.idVenta = DV.idVenta
GROUP BY Emp.Nombre;
GO

-- 1.4. Vistas
-- Vista 1: Catálogo completo de libros
CREATE VIEW vw_CatalogoLibrosDetallado AS
SELECT 
    L.idLibro AS IdLibro,
    L.titulo AS Titulo,
    A.nombre AS Autor,
    E.nombre AS Editorial,
    G.nombre AS Genero,
    L.precio AS Precio,
    L.cantidad AS Stock
FROM Libros L
INNER JOIN Autores A ON L.idAutor = A.idAutor
INNER JOIN Editoriales E ON L.idEditorial = E.idEditorial
INNER JOIN Generos G ON L.idGenero = G.idGenero;
GO

SELECT * FROM vw_CatalogoLibrosDetallado WHERE Stock = 0;
GO


--Vista 2: Resumen de ventas por cabecera y ticket
CREATE VIEW vw_ResumenVentasCabecera AS
SELECT 
    V.idVenta AS NumeroVenta,
    V.Fecha,
    C.Nombre AS Cliente,
    Emp.Nombre AS Empleado,
    SUM(DV.Cantidad * DV.PrecioUnitario) AS MontoTotalVenta
FROM Ventas V
INNER JOIN Clientes C ON V.idCliente = C.idCliente
INNER JOIN Empleados Emp ON V.idEmpleado = Emp.idEmpleado
INNER JOIN DetalleVentas DV ON V.idVenta = DV.idVenta
GROUP BY V.idVenta, V.Fecha, C.Nombre, Emp.Nombre;
GO

SELECT * FROM vw_ResumenVentasCabecera ORDER BY MontoTotalVenta DESC;
GO

-- 1.4 Procedimientos Almacenados
-- Procedimiento 1: Actualizar precio de un libro 
CREATE PROCEDURE sp_ActualizarPrecioLibro
    @IdLibro INT,
    @NuevoPrecio DECIMAL(10,2)
AS
BEGIN
    -- Validamos la regla del negocio (precio >= 1000)
    IF @NuevoPrecio >= 1000
    BEGIN
        UPDATE Libros
        SET precio = @NuevoPrecio
        WHERE idLibro = @IdLibro;
        
        PRINT 'El precio del libro se actualizó correctamente.';
    END
    ELSE
    BEGIN
        RAISERROR('Error: El precio no puede ser menor a 1000.', 16, 1);
    END
END;
GO

EXEC sp_ActualizarPrecioLibro @IdLibro = 1, @NuevoPrecio = 14500.00;
SELECT * FROM vw_CatalogoLibrosDetallado WHERE Precio = 14500.00;
GO


--Procedimiento 2: Consultar ventas por un rango de fechas dinámico
CREATE PROCEDURE sp_ConsultarVentasPorFechas
    @FechaInicio DATE,
    @FechaFin DATE
AS
BEGIN
    SELECT 
        V.idVenta AS NumeroVenta,
        V.Fecha,
        C.Nombre AS Cliente,
        Emp.Nombre AS Empleado,
        SUM(DV.Cantidad * DV.PrecioUnitario) AS TotalVenta
    FROM Ventas V
    INNER JOIN Clientes C ON V.idCliente = C.idCliente
    INNER JOIN Empleados Emp ON V.idEmpleado = Emp.idEmpleado
    INNER JOIN DetalleVentas DV ON V.idVenta = DV.idVenta
    WHERE V.Fecha BETWEEN @FechaInicio AND @FechaFin
    GROUP BY V.idVenta, V.Fecha, C.Nombre, Emp.Nombre
    ORDER BY V.Fecha ASC;
END;
GO

EXEC sp_ConsultarVentasPorFechas @FechaInicio = '2026-03-01', @FechaFin = '2026-03-10';
GO

--Procedimiento 3: Consultar por información de un libro por su ID
CREATE PROCEDURE sp_ObtenerInfoLibroPorId
    @IdLibro INT,                        
    @Titulo VARCHAR(50) OUTPUT,          
    @Stock INT OUTPUT,                   
    @Precio DECIMAL(10,2) OUTPUT         
AS
BEGIN
    SELECT 
        @Titulo = titulo,
        @Stock = cantidad,
        @Precio = precio
    FROM Libros
    WHERE idLibro = @IdLibro;
END;
GO

--Declarar las variables donde se guardarán los resultados
DECLARE @Tit VARCHAR(50);
DECLARE @Stk INT;
DECLARE @Prec DECIMAL(10,2);

--Ejecutar el procedimiento pasando las variables con la palabra OUTPUT
EXEC sp_ObtenerInfoLibroPorId 
    @IdLibro = 1,                 
    @Titulo = @Tit OUTPUT,         
    @Stock = @Stk OUTPUT,          
    @Precio = @Prec OUTPUT;        

-- Mostrar los valores devueltos por los parámetros de salida
SELECT 
    @Tit AS TituloLibro, 
    @Stk AS StockDisponible, 
    @Prec AS PrecioActual;
GO

--Etapa 2: Control de errores y Modificaciones
--2.1 Procedimiento almacenado con control de errores a la hora de registrar una venta
CREATE PROCEDURE sp_RealizarVentaSegura
    @IdCliente INT,
    @IdEmpleado INT,
    @IdLibro INT,
    @CantidadComprada INT
AS
BEGIN
    -- Bloque de control transaccional y de errores
    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Validar existencia del cliente utilizando SELECT 1 (muy eficiente)
        IF NOT EXISTS (SELECT 1 FROM Clientes WHERE idCliente = @IdCliente)
        BEGIN
            RAISERROR('Error crítico: El cliente especificado no se encuentra registrado.', 16, 1);
        END

        -- 2. Verificar existencia del libro y obtener stock/precio actual
        DECLARE @StockActual INT;
        DECLARE @PrecioLibro DECIMAL(10,2);

        SELECT @StockActual = cantidad, @PrecioLibro = precio 
        FROM Libros 
        WHERE idLibro = @IdLibro;

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Error crítico: El libro indicado no existe en el catálogo.', 16, 1);
        END

        -- 3. Validación de negocio: Validar stock suficiente
        IF @StockActual < @CantidadComprada
        BEGIN
            RAISERROR('Error de negocio: Stock insuficiente para completar la venta.', 16, 1);
        END

        -- 4. Inserción en la Cabecera (Ventas)
        INSERT INTO Ventas (idEmpleado, idCliente, Fecha)
        VALUES (@IdEmpleado, @IdCliente, GETDATE());

        -- Obtener el ID de la venta recién creada
        DECLARE @IdVentaNueva INT = SCOPE_IDENTITY();

        -- 5. Inserción en el Detalle (DetalleVentas)
        INSERT INTO DetalleVentas (idVenta, idLibro, Cantidad, PrecioUnitario)
        VALUES (@IdVentaNueva, @IdLibro, @CantidadComprada, @PrecioLibro);

        -- 6. Actualización del Stock en la tabla Libros
        UPDATE Libros
        SET cantidad = cantidad - @CantidadComprada
        WHERE idLibro = @IdLibro;

        -- Si todo sale bien, confirmamos los cambios de forma definitiva
        COMMIT TRANSACTION;
        PRINT '¡Transacción exitosa! Venta registrada correctamente.';

    END TRY
    BEGIN CATCH
        -- Si ocurre cualquier error, revertimos toda la transacción
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        -- Capturamos el mensaje de error original y lo propagamos
        DECLARE @MensajeError VARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@MensajeError, 16, 1);
    END CATCH
END;
GO

-- Prueba exitosa (asumiendo que el libro 1 tiene stock y el cliente 1 existe)
EXEC sp_RealizarVentaSegura @IdCliente = 1, @IdEmpleado = 1, @IdLibro = 1, @CantidadComprada = 2;
GO

-- Prueba de fallo por stock insuficiente (disparará el RAISERROR y hará ROLLBACK)
EXEC sp_RealizarVentaSegura @IdCliente = 1, @IdEmpleado = 1, @IdLibro = 1, @CantidadComprada = 9999;
GO

-- 2.2 Modificación masiva
--Aumento de precio en un 15% a todos los libros pertenecientes a la editorial planeta
--cuyo stock sea menor o igual a 5
UPDATE Libros
SET precio = precio * 1.15
WHERE cantidad <= 5 
  AND idEditorial IN (SELECT idEditorial FROM Editoriales WHERE nombre = 'Planeta');
GO


-- Borrar de la tabla Clientes a aquellos que NUNCA hayan realizado ninguna compra 
-- (combinando con un filtro de exclusión).
DELETE FROM Clientes
WHERE idCliente NOT IN (SELECT idCliente FROM Ventas);
GO

-- Ejemplo teórico aplicado a una tabla auxiliar de logs o auditoría:
-- TRUNCATE TABLE LogAuditoriaSistema;
-- GO