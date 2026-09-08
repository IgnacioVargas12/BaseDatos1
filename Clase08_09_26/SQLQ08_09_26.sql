USE Astilleros;
GO

SELECT COUNT (*) AS 'Total Ordenes' FROM ordenproceso; --Dentro del parentesis determino que columnas quiero mostrar
GO

SELECT empleado, COUNT (op) AS 'Cantidad de órdenes' FROM ordenproceso GROUP BY empleado;
GO

-- 1. Crear la tabla de procesos si no fue creada previamente
CREATE TABLE [dbo].[procesos] (
    [proceso] [int] NOT NULL,
    [nombre] [char] (30) COLLATE Modern_Spanish_CI_AS NOT NULL,
    CONSTRAINT [PK_procesos] PRIMARY KEY CLUSTERED ([proceso] ASC)
) ON [PRIMARY];
GO

-- 2. Insertar los datos de las etapas productivas
INSERT INTO [dbo].[procesos] ([proceso], [nombre]) VALUES 
(1, 'LAMINADO'),
(2, 'ARMADO'),
(3, 'PINTURA');
GO

-- 3. Ampliar un par de órdenes de proceso para vincularlas a estos procesos
INSERT INTO ordenproceso (op, proceso, modelo, empleado, fechainicio, fechafin, estado) VALUES 
(104, 1, 1, 2, '20260306', '20260310', 'P'),
(105, 2, 1, 3, '20260307', '20260312', 'P'),
(106, 3, 2, 2, '20260308', '20260315', 'P');
GO

-- Ampliar la nómina de empleados con nombres y apellidos
INSERT INTO empleados (empleado, nombre, estadocivil, cuil, direccion, telefono, categoria, estado) VALUES 
(8, 'GIMENEZ ALBERTO', 'C', '20-28456123-4', 'RIVADAVIA 450', '3514221122', 2, 'A'),
(9, 'PEREZ CLAUDIA', 'S', '27-32111444-8', 'SAN MARTIN 890', '3514998877', 3, 'A'),
(10, 'BENITEZ JORGE', 'C', '20-25789456-1', 'BELGRANO 120', '3514332211', 1, 'A');
GO

SELECT pr.nombre AS 'Nombre Proceso', COUNT (op.op) AS 'Total ordenes' 
FROM procesos AS pr
INNER JOIN ordenproceso AS op 
ON pr.proceso = pr.proceso 
GROUP BY pr.nombre;
GO

--Muestra los empleados que tenga más de una orden
SELECT e.nombre, COUNT (o.op) AS 'Total ordenes' FROM empleados e 
INNER JOIN ordenproceso o ON 
e.empleado = e.empleado 
GROUP BY e.nombre
HAVING COUNT (o.op) > 1;
GO