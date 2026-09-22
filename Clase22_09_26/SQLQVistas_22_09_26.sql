USE Astilleros;
GO

-- ==========================================
-- 1. CREACIÓN Y CARGA DE LA TABLA MODELOS
-- ==========================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[modelos]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[modelos] (
        [modelo] [int] NOT NULL,
        [nombre] [varchar](50) NOT NULL,
        [eslora] [decimal](5,2) NULL,
        CONSTRAINT [PK_modelos] PRIMARY KEY CLUSTERED ([modelo] ASC)
    );
END
GO

-- Insertamos modelos de embarcaciones para los astilleros
INSERT INTO [dbo].[modelos] ([modelo], [nombre], [eslora]) VALUES 
(1, 'Lancha Tracker 550', 5.50),
(2, 'Crusero Cabinado 800', 8.00),
(10, 'Bote Auxiliar 350', 3.50),
(12, 'Velero Oceánico 12m', 12.00),
(15, 'Lancha Deportiva V6', 6.20);
GO


-- ==========================================
-- 2. CREACIÓN Y CARGA DE LA TABLA MATERIALES
-- ==========================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[materiales]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[materiales] (
        [material] [int] NOT NULL,
        [nombre] [varchar](50) NOT NULL,
        [modelo] [int] NOT NULL,
        [costo] [decimal](10,2) NOT NULL,
        CONSTRAINT [PK_materiales] PRIMARY KEY CLUSTERED ([material] ASC),
        CONSTRAINT [FK_materiales_modelos] FOREIGN KEY ([modelo]) REFERENCES [dbo].[modelos] ([modelo])
    );
END
GO

-- Insertamos materiales asociados a los modelos de prueba
INSERT INTO [dbo].[materiales] ([material], [nombre], [modelo], [costo]) VALUES 
(101, 'Fibra de Vidrio (Rollo)', 1, 1500.00),
(102, 'Resina Poliéster (Litros)', 1, 800.50),
(103, 'Timón de Acero Inoxidable', 2, 3200.00),
(104, 'Cableado Eléctrico Naval', 2, 950.00),
(105, 'Pintura Anti-incrustante', 10, 450.00),
(106, 'Madera de Teka (M2)', 12, 5000.00);
GO


-- ==========================================
-- 3. CREACIÓN Y CARGA DE LA TABLA PRESUPUESTO
-- ==========================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[presupuesto]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[presupuesto] (
        [presupuesto] [int] NOT NULL,
        [fecha] [datetime] NOT NULL,
        [cliente] [int] NOT NULL,
        [importe] [decimal](12,2) NOT NULL,
        CONSTRAINT [PK_presupuesto] PRIMARY KEY CLUSTERED ([presupuesto] ASC),
        CONSTRAINT [FK_presupuesto_clientes] FOREIGN KEY ([cliente]) REFERENCES [dbo].[clientes] ([cliente])
    );
END
GO

-- Insertamos presupuestos vinculados a los clientes existentes (ej: clientes 1, 100, 101, etc.)
INSERT INTO [dbo].[presupuesto] ([presupuesto], [fecha], [cliente], [importe]) VALUES 
(5001, '20260210', 1, 45000.00),
(5002, '20260215', 100, 120000.00),
(5003, '20260220', 101, 85000.00),
(5004, '20260301', 100, 31000.00),
(5005, '20260305', 102, 99000.00);
GO

--Crear una VISTA (tabla virtual)
CREATE VIEW dbo.vw_ordenes_activas AS
SELECT OP.op AS Orden_Proceso,
OP.fechainicio AS Fecha,
P.nombre AS Nombre_Proceso,
E.nombre AS Nombre_Empleado
FROM dbo.ordenproceso OP
JOIN dbo.procesos P
ON OP.proceso = P.proceso
JOIN dbo.empleados E
ON OP.empleado = E.empleado;
GO

--Como usar la vista
SELECT * FROM dbo.vw_ordenes_activas
WHERE Nombre_Empleado = 'Suarez Pedro';
GO

--Como modificar una tabla vista
--ALTER VIEW dbo.vw_ordenes_activas AS SELECT op, fechainicio FROM ordenproceso;
--GO

--Como eliminar la tabla vista
--DROP VIEW dbo.vw_ordenes_activas;
--GO


--Ejercicio
CREATE VIEW dbo.vw_presupuestos_clientes AS
SELECT PR.presupuesto AS Presupuesto,
PR.fecha AS Fecha,
C.nombre AS Nombre_Cliente
FROM dbo.presupuesto AS PR
JOIN dbo.clientes AS C
ON PR.cliente = C.cliente;
GO

SELECT * FROM dbo.vw_presupuestos_clientes
GO;

CREATE VIEW dbo.vw_costos_materiales_modelo AS
SELECT m.modelo,
m.nombre AS nombre_modelo,
COUNT (mat.material) AS total_materiales,
SUM (mat.costo) AS costo_total_materiales
FROM dbo.modelos m
JOIN dbo.materiales mat
ON M.modelo = mat.modelo
GROUP BY m.modelo, m.nombre;
GO

SELECT * FROM dbo.vw_costos_materiales_modelo;
GO

--Encriptar una vista para no poder ver como esta formada:
sp_helptext 'dbo.vw_costos_materiales_modelo'
GO
--Esta linea nos permite ver como esta creada (a nivel codigo)

--Agregar la frase WITH ENCRYPTION ya bloquea que no se pueda ver su forma de creacion
CREATE VIEW dbo.vw_costo_materiales_protegida WITH ENCRYPTION AS
SELECT m.modelo,
m.nombre AS nombre_modelo,
COUNT (mat.material) AS total_materiales,
SUM (mat.costo) AS costo_total_materiales
FROM dbo.modelos m
JOIN dbo.materiales mat
ON M.modelo = mat.modelo
GROUP BY m.modelo, m.nombre;
GO

sp_helptext 'dbo.vw_costo_materiales_protegida'
GO

--Esto va a hacer que la tabla ordenproceso no se pueda actualizar/modificar 
--el esquema (nombre, campos, etc) al estar bloqueado con la vista
CREATE VIEW dbo.vw_ordenes_criticas WITH SCHEMABINDING AS
SELECT OP.op, OP.fechainicio, OP.estado 
FROM dbo.ordenproceso OP;
GO

--Vistas indexadas (agiliza al recorrer solo las tablas que necesita en vez de toda la DB)
CREATE VIEW dbo.vw_ordenes_pendientes_idx WITH SCHEMABINDING AS
SELECT op, proceso, modelo, empleado, fechainicio, estado FROM dbo.ordenproceso
WHERE estado = 'P';
GO

CREATE UNIQUE CLUSTERED INDEX IX_VwOrdenesPendientes
ON dbo.vw_ordenes_pendientes_idx (op, proceso); --Aca van las PK
GO

SELECT * FROM dbo.vw_ordenes_pendientes_idx;
GO

--Ejercicio 2
CREATE VIEW dbo.vw_resumen_clientes_presupuestos AS
SELECT C.nombre AS Nombre, C.cliente AS Codigo,
COUNT (PR.presupuesto) AS Cantidad_Presupuestos,
MAX (PR.fecha) AS Presupuesto_Reciente
FROM dbo.clientes C
JOIN dbo.presupuesto PR
ON C.cliente = PR.cliente
GROUP BY c.cliente, c.nombre;
GO

SELECT * FROM dbo.vw_resumen_clientes_presupuestos;
GO