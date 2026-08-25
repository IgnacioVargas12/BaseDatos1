/*
CREATE DATABASE Astilleros ON PRIMARY
(
 NAME = 'AstillerosData',
 FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\Astilleros.mdf',
 SIZE = 10MB,
 MAXSIZE = 50MB,
 FILEGROWTH = 20%
)
LOG ON
(
 NAME = 'AstillerosLog',
 FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\Astilleros.ldf',
 SIZE = 3MB,
 MAXSIZE = 10MB,
 FILEGROWTH = 1MB 
);
GO */

--Codigo para utilizar la DB que yo quiera
/*
USE Astilleros; 
GO 
*/ 


-- Creación de la tabla Marcas 
CREATE TABLE Marcas ( 
 IdMarca INT IDENTITY(1,1) NOT NULL, 
 Nombre VARCHAR(50) NOT NULL, 
 Activo CHAR(1) DEFAULT 'S' NOT NULL, 
 CONSTRAINT PK_Marcas PRIMARY KEY (IdMarca) --El programa genera automaticamente la regla de PK, pero con un nombre aleatorio
); 
GO 
 
-- Creación de la tabla Rubros 
CREATE TABLE Rubros ( 
 IdRubro INT NOT NULL, 
 Descripcion VARCHAR(100) NOT NULL, 
 CONSTRAINT PK_Rubros PRIMARY KEY (IdRubro) 
); 
GO


-- 1. Modificamos la tabla Marcas para agregar el país de origen 
ALTER TABLE Marcas ADD PaisOrigen VARCHAR(50) NULL; 
GO 

-- 2. Modificamos la tabla Rubros para registrar en qué fecha se crearon 
ALTER TABLE Rubros ADD FechaCreacion DATETIME NULL; 
GO 

-- 3. Creamos una tabla de prueba rápida solo para ver cómo se destruye 
CREATE TABLE TablaDescartable ( 
 Id INT PRIMARY KEY, 
 Dato VARCHAR(10) 
); 
GO 

-- 4. Eliminación absoluta de la tabla que ya no sirve 
DROP TABLE TablaDescartable; 
GO

-- Inserción en la tabla Marcas (No pasamos IdMarca porque es IDENTITY) 
-- Aprovechamos para llenar la nueva columna PaisOrigen  
INSERT INTO Marcas (Nombre, Activo, PaisOrigen) 
VALUES ('Yamaha', 'S', 'Japón'); 

INSERT INTO Marcas (Nombre, Activo, PaisOrigen) 
VALUES ('Evinrude', 'S', 'Estados Unidos'); 
GO 

-- Inserción en la tabla Rubros (Aquí sí pasamos IdRubro porque no es automático) 
-- Hacemos un truco: GETDATE() inserta la fecha y hora actual del sistema 
INSERT INTO Rubros (IdRubro, Descripcion, FechaCreacion) 
VALUES (1, 'Motores Fuera de Borda', GETDATE()); 

-- También podemos pasar la fecha manualmente entre comillas simples ('YYYY-MM-DD')
INSERT INTO Rubros (IdRubro, Descripcion, FechaCreacion) 
VALUES (2, 'Repuestos Eléctricos', '20230820'); 
GO

-- 1. Consultar todo lo que hay dentro de la tabla Marcas 
SELECT * FROM Marcas; 
GO 

-- 2. Consultar todo lo que hay dentro de la tabla Rubros 
SELECT * FROM Rubros; 
GO

--Clase 5

-- 1. Creamos la tabla Clientes 
CREATE TABLE clientes ( 
 cliente INT NOT NULL, 
 nombre VARCHAR(50) NOT NULL, 
 direccion VARCHAR(50) NOT NULL, 
 localidad VARCHAR(50) NOT NULL, 
 cp INT NOT NULL, 
 cuit VARCHAR(13) NOT NULL, 
 ingbrutos VARCHAR(13) NOT NULL, 
 sitiva INT NOT NULL, 
 telefono VARCHAR(20) NOT NULL, 
 fax VARCHAR(20) NOT NULL, 
 contacto VARCHAR(50) NOT NULL, 
 email VARCHAR(50) NOT NULL, 
 estado CHAR(1) NOT NULL, 
  CONSTRAINT PK_clientes PRIMARY KEY (cliente)
 ); 
GO 
 
-- 2. Creamos la tabla Empleados (Ya incluye columnas especiales para hoy) 
CREATE TABLE empleados ( 
 empleado INT NOT NULL, 
 nombre VARCHAR(50) NOT NULL, 
 estadocivil CHAR(1) NOT NULL, 
 cuil VARCHAR(13) NOT NULL, 
 direccion VARCHAR(50) NOT NULL, 
 telefono VARCHAR(15) NOT NULL, 
 categoria INT NOT NULL, 
 estado CHAR(1) NOT NULL, 
 fechanacimiento DATETIME NULL, 
 EsSupervisadoPor INT NULL, 
CONSTRAINT PK_empleados PRIMARY KEY (empleado) 
);
 GO

-- 3. Creamos la tabla Proveedores 
CREATE TABLE proveedores ( 
 proveedor INT NOT NULL, 
 nombre VARCHAR(30) NOT NULL, 
 cuit VARCHAR(13) NOT NULL, 
 ingbrutos VARCHAR(13) NOT NULL, 
 domicilio VARCHAR(30) NOT NULL, 
 cp INT NOT NULL, 
 localidad VARCHAR(50) NOT NULL, 
 telefono VARCHAR(20) NOT NULL, 
 fax VARCHAR(20) NOT NULL, 
 contacto VARCHAR(50) NOT NULL, 
 email VARCHAR(50) NOT NULL, 
 fantasia VARCHAR(50) NOT NULL, 
 sitiva INT NOT NULL,
 retencionganancia CHAR(1) NOT NULL, 
 agenteretencion CHAR(1) NOT NULL, 
 provbdecambio CHAR(1) NOT NULL, 
 estado CHAR(1) NOT NULL, 
  CONSTRAINT PK_proveedores PRIMARY KEY (proveedor) 
); 
GO 

 
-- 4. Creamos la tabla OrdenProceso 
CREATE TABLE ordenproceso ( 
 op NUMERIC(18, 0) NOT NULL, 
 proceso INT NOT NULL, 
 modelo INT NOT NULL, 
 empleado INT NOT NULL, 
 fechainicio DATETIME NOT NULL, 
 fechafin DATETIME NOT NULL, 
 estado CHAR(1) NOT NULL, 
  CONSTRAINT PK_ordenproceso PRIMARY KEY (op, proceso)
 ); 
GO

ALTER TABLE clientes ADD CONSTRAINT DF_Contacto DEFAULT 'Desconocido' FOR contacto;
GO

ALTER TABLE empleados ADD CONSTRAINT CK_fechanacimiento CHECK (fechanacimiento > '01-01-1910' AND fechanacimiento < getdate());
GO

ALTER TABLE proveedores ADD CONSTRAINT U_NombreEmpresa UNIQUE (Nombre);
GO

ALTER TABLE ordenproceso ADD CONSTRAINT FK_Ordenes_Empleados 
FOREIGN KEY (empleado) REFERENCES empleados (empleado) ON DELETE CASCADE; 
GO

-- Intentamos cargar a un empleado nacido en el futuro (Año 2050) para comprobar los CONSTRAINT
INSERT INTO empleados (empleado, nombre, estadocivil, cuil, direccion, telefono, categoria, estado, fechanacimiento, EsSupervisadoPor)
VALUES (999, 'Marty McFly', 'S', '20-11111111-2', 'Calle Falsa 123', '555-1234', 1, 'A', '2060-01-01', NULL);
GO

-- Cargamos al primer proveedor. (Debe decir "1 fila afectada")
INSERT INTO proveedores (proveedor, nombre, cuit, ingbrutos, domicilio, cp, localidad, telefono, fax, contacto, email, fantasia, sitiva, retencionganancia, agenteretencion, provbdecambio, estado)
VALUES (1, 'Motores del Sur SA', '30-11111111-2', '123456', 'San Martin 100', 5000, 'Cordoba', '444-4444', '444-4444', 'Juan', 'juan@mail.com', 'Motores', 1, 'S', 'S', 'N', 'A');
GO

-- Cargamos un cliente rápido omitiendo a propósito la columna 'contacto'
INSERT INTO clientes (cliente, nombre, direccion, localidad, cp, cuit, ingbrutos, sitiva, telefono, fax, email, estado)
VALUES (1, 'Nautica Cordoba', 'Colon 4000', 'Cordoba', 5000, '30-99999999-9', '111111', 1, '433-3333', '433-3333', 'info@nautica.com', 'A');
GO

SELECT * FROM empleados;
GO

--Script para desconectar la base de datos y quitar los archivos
-- 1. Nos ubicamos en la base maestra 
USE master; 
GO 

-- 2. TRUCO DBA: Echamos a todos los usuarios y pestañas conectadas 
-- Ponemos la base en Modo de Usuario Único y cortamos conexiones al instante 
ALTER DATABASE Astilleros SET SINGLE_USER WITH ROLLBACK IMMEDIATE; 
GO 

-- 3. Ahora sí, la desconectamos con seguridad 
EXEC sp_detach_db 'Astilleros'; 
GO  
