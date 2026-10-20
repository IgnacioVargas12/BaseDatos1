USE DB_Vargas
GO

--Creacion del operador
USE master;
GO
CREATE LOGIN Operador_Vargas
WITH PASSWORD = 'PasswordProyecto123!';
GO

--Creacion del usuario
USE DB_Vargas;
GO
CREATE USER UsuOperador_Vargas
FOR LOGIN Operador_Vargas;
GO

--Inserción masiva de datos 

-- =============================================
-- 1. INSERCIÓN EN TABLAS DE CATÁLOGO / MAESTRAS
-- =============================================

-- Autores
INSERT INTO Autores (nombre, nacionalidad) VALUES
('Gabriel García Márquez', 'Colombiana'),
('Jorge Luis Borges', 'Argentina'),
('Isabel Allende', 'Chilena'),
('Stephen King', 'Estadounidense'),
('J.K. Rowling', 'Británica'),
('Julio Cortázar', 'Argentina');
GO

-- Editoriales
INSERT INTO Editoriales (nombre) VALUES
('Sudamericana'),
('Penguin Random House'),
('Planeta'),
('Minotauro'),
('Alianza Editorial');
GO

-- Géneros
INSERT INTO Generos (nombre) VALUES
('Ficción'),
('Fantasía'),
('Terror'),
('Policial'),
('Poesía'),
('Ensayo');
GO

-- =============================================
-- 2. INSERCIÓN DE LIBROS (Incluye libros sin stock y precios variados)
-- =============================================
-- idAutor: 1 (García Márquez), 2 (Borges), 3 (Allende), 4 (King), 5 (Rowling), 6 (Cortázar)
-- idEditorial: 1 (Sudamericana), 2 (Penguin), 3 (Planeta), 4 (Minotauro), 5 (Alianza)
-- idGenero: 1 (Ficción), 2 (Fantasía), 3 (Terror), 4 (Policial), 5 (Poesía), 6 (Ensayo)

INSERT INTO Libros (titulo, idAutor, fecha, idEditorial, idGenero, cantidad, precio) VALUES
('Cien Años de Soledad', 1, '1967-05-30', 1, 1, 15, 12500.00),
('El Aleph', 2, '1949-06-15', 2, 1, 8, 9800.00),
('La Casa de los Espíritus', 3, '1982-10-01', 3, 1, 0, 11000.00), -- SIN STOCK
('It', 4, '1986-09-15', 2, 3, 5, 18500.00),
('Harry Potter y la Piedra Filosofal', 5, '1997-06-26', 4, 2, 20, 15000.00),
('Rayuela', 6, '1963-06-28', 1, 1, 12, 13200.00),
('Ficciones', 2, '1944-01-01', 5, 1, 0, 8900.00),  -- SIN STOCK
('El Resplandor', 4, '1977-01-28', 2, 3, 3, 16000.00),
('Cuentos de Eva Luna', 3, '1989-01-01', 3, 1, 10, 10500.00);
GO

SELECT * FROM Libros;
GO
-- =============================================
-- 3. INSERCIÓN DE PERSONAS (Clientes y Empleados)
-- =============================================

-- Clientes (Incluye un cliente que NUNCA compró nada para probar LEFT JOIN / EXCEPT)
INSERT INTO Clientes (Nombre) VALUES
('Juan Pérez'),
('María Gómez'),
('Carlos López'),
('Ana Torres'),
('Roberto Rossi'); -- Cliente sin compras asociadas
GO

-- Empleados
INSERT INTO Empleados (Nombre, cargo) VALUES
('Gonzalo Silva' , 'Vendedora'),
('Lucía Fernández', 'Vendedora'),
('Esteban Quito', 'Supervisora');
GO

SELECT * FROM Empleados;
GO
-- =============================================
-- 4. INSERCIÓN DE VENTAS (Cabecera)
-- =============================================
-- Fechas variadas para practicar filtrados y agrupamientos por mes/año

INSERT INTO Ventas (idEmpleado, idCliente, Fecha) VALUES
(1, 1, '2026-03-01'), -- Venta 1
(1, 2, '2026-03-02'), -- Venta 2
(2, 3, '2026-03-05'), -- Venta 3
(3, 1, '2026-03-10'), -- Venta 4
(2, 4, '2026-03-15'); -- Venta 5
GO

-- =============================================
-- 5. INSERCIÓN DE DETALLE DE VENTAS (Renglones/Ítems)
-- =============================================
-- Nota: idLibro se asocia con el precio del libro al momento de la venta

INSERT INTO DetalleVentas (idVenta, idLibro, Cantidad, PrecioUnitario) VALUES
-- Venta 1 (Juan Pérez compró 2 libros distintos)
(1, 1, 1, 12500.00), -- Cien Años de Soledad
(1, 2, 2, 9800.00),  -- El Aleph (2 unidades)

-- Venta 2 (María Gómez)
(2, 5, 1, 15000.00), -- Harry Potter

-- Venta 3 (Carlos López compró 2 unidades del mismo libro)
(3, 4, 2, 18500.00), -- It (2 unidades)

-- Venta 4 (Juan Pérez volvió a comprar)
(4, 6, 1, 13200.00), -- Rayuela

-- Venta 5 (Ana Torres compró 3 libros diferentes)
(5, 1, 1, 12500.00), -- Cien Años de Soledad
(5, 8, 1, 16000.00), -- El Resplandor
(5, 9, 1, 10500.00); -- Cuentos de Eva Luna
GO