USE Astilleros;
GO

-- ==========================================
-- 1. CARGA DE EMPLEADOS
-- ==========================================
INSERT INTO empleados (empleado, nombre, estadocivil, cuil, direccion, telefono, categoria, estado, fechanacimiento, EsSupervisadoPor)
VALUES 
(1, 'SUAREZ PEDRO', 'S', '20-16786535-2', 'Lamarca 1234', '4756-4585', 3, 'A', '19800514', NULL),
(2, 'DAVOLIO NANCY', 'C', '27-22222222-3', 'Av. Colón 345', '4555-1234', 2, 'A', '19850820', 1),
(3, 'PEREZ MARGOT', 'S', '27-33333333-3', 'Jorge Newbery 88', '4333-9999', 1, 'A', '19901110', 1),
(5, 'FUNES LUIS', 'C', '20-44444444-2', 'Rosedal 456', '4222-8888', 4, 'A', '19750228', NULL),
(7, 'DOBSON JORGE', 'S', '20-55555555-2', 'San Martín 999', '4111-7777', 2, 'A', '19880715', 5);
GO

-- ==========================================
-- 2. CARGA DE CLIENTES (Optimizada para WHERE y LIKE)
-- ==========================================
INSERT INTO clientes (cliente, nombre, direccion, localidad, cp, cuit, ingbrutos, sitiva, telefono, fax, contacto, email, estado)
VALUES 
(100, 'NAUTICA CORDOBA', 'Av. Fuerza Aerea 2000', 'Cordoba', 5000, '30-11111111-9', '111', 1, '0351-444111', '0351-444111', 'Carlos', 'carlos@nauticacba.com', 'A'),
(101, 'VELAS Y VIENTOS', 'San Martin 456', 'Rosario', 2000, '30-22222222-9', '222', 1, '0341-555222', '0341-555222', 'Ana', 'ana@velas.com', 'A'),
(102, 'MAR ABIERTO SA', 'Colon 4000', 'Cordoba', 5000, '30-33333333-9', '333', 1, '0351-666333', '0351-666333', 'Roberto', 'roberto@marabierto.com', 'A'),
(103, 'EL NAVEGANTE', 'Belgrano 120', 'Carlos Paz', 5152, '30-44444444-9', '444', 2, '03541-777444', '03541-777444', 'Lucia', 'lucia@elnavegante.com', 'A'),
(104, 'MUNDO MARINO', 'Costanera 100', 'Buenos Aires', 1000, '30-55555555-9', '555', 1, '011-888555', '011-888555', 'Hugo', 'hugo@mundomarino.com', 'A'),
(105, 'ASTILLEROS CORDOBA', 'Recta Martinoli 7000', 'Cordoba', 5000, '30-66666666-9', '666', 1, '0351-999999', '0351-999999', 'Mario', 'mario@astilleroscba.com', 'I'); -- Cliente de Córdoba, pero INACTIVO ('I').
GO

-- ==========================================
-- 3. CARGA DE PROVEEDORES (Optimizada para DISTINCT)
-- ==========================================
INSERT INTO proveedores (proveedor, nombre, cuit, ingbrutos, domicilio, cp, localidad, telefono, fax, contacto, email, fantasia, sitiva, retencionganancia, agenteretencion, provbdecambio, estado)
VALUES 
(1254, 'CORDOBA GOMA', '30-51625452-8', '1244578589', 'La Rioja 501', 5000, 'Cordoba', '0351-4264588', '0351-4264589', 'Pedro', 'ventas@cbagoma.com', 'CORDOBA GOMA', 2, 'S', 'S', 'S', 'A'),
(1255, 'MOTORES DEL SUR', '30-99999999-9', '9876543210', 'Ovidio Lagos 300', 2000, 'Rosario', '0341-444555', '0341-444555', 'Juan', 'info@motores.com', 'MOTORES SUR', 1, 'N', 'N', 'N', 'A'),
(1256, 'FIBRAS ACUATICAS', '30-88888888-8', '5555555555', 'Rivadavia 90', 1000, 'Buenos Aires', '011-4333222', '011-4333222', 'Mario', 'mario@fibras.com', 'FIBRAS ACUATICAS', 1, 'S', 'N', 'N', 'A'),
(1257, 'PINTURAS NAUTICAS', '30-77777777-7', '77777777', 'Av. Recta Martinoli 5000', 5000, 'Cordoba', '0351-444444', '0351-444444', 'Luis', 'luis@nautica.com', 'NAUTICA', 1, 'N', 'N', 'N', 'A');
GO

-- ==========================================
-- 4. CARGA DE ORDENES DE PROCESO (Optimizada para BETWEEN y JOINs)
-- ==========================================
INSERT INTO ordenproceso (op, proceso, modelo, empleado, fechainicio, fechafin, estado)
VALUES 
(1001, 1, 10, 1, '20080115', '20080120', 'F'),
(1002, 2, 10, 2, '20080210', '20080218', 'F'),
(1003, 1, 12, 5, '20080305', '20080315', 'F'),
(1004, 3, 15, 7, '20080620', '20080625', 'F');
GO

PRINT '¡Datos cargados correctamente! La base está lista para la Clase 7 y 8.';
GO

SELECT * FROM ordenproceso
GO

--Creando ALIAS para un campo, modificando el nombre de una columna para que se vea de otra manera
SELECT proveedor, nombre AS Razon_Social, localidad FROM proveedores;
GO

--DISTINCT sirve para traer una tabla sin repeteciones en sus campos, trayendo solo los campos que existen
SELECT DISTINCT localidad FROM proveedores;
GO

--Filtrado de datos con WHERE
SELECT cliente, nombre, telefono, estado FROM clientes WHERE localidad = 'Cordoba' AND estado = 'I';
GO

SELECT nombre AS Proveedor, cuit, ingbrutos, localidad FROM proveedores;
GO

--Filtrado de datos con intervalos utilizando BETWEEN
SELECT op AS Numero_Operacion, proceso, empleado, fechainicio FROM ordenproceso WHERE fechainicio BETWEEN '20080101' AND '20080331';
GO

--Búsqueda por patrones de texto LIKE 
SELECT cliente, nombre, cuit FROM clientes WHERE nombre LIKE 'N%';
GO