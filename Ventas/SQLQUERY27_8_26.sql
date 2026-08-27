CREATE DATABASE Ventas;
GO

USE Ventas;
GO

CREATE TABLE sucursales (
Sucursal INT NOT NULL,
Denomincacion VARCHAR (50) NOT NULL, 
Direccion VARCHAR (100) NOT NULL,
CONSTRAINT PK_Sursales PRIMARY KEY (Sucursal)
);
GO

CREATE TABLE Vendedores (
Vendedor INT NOT NULL,
Nombre VARCHAR (50) NOT NULL,
Sucursal INT NOT NULL,
DNI VARCHAR (15)  NOT NULL, 
Comision DECIMAL (4,2) NULL,
CONSTRAINT PK_Vendedores PRIMARY KEY (Vendedor)
);
GO

CREATE TABLE Clientes (
Cliente INT NOT NULL,
Nombre VARCHAR (50) NOT NULL,
Cuit VARCHAR (13) NULL,
CONSTRAINT PK_Clientes PRIMARY KEY (Cliente)
);
GO

--Alteraciones y reglas
ALTER TABLE sucursales ADD Telefono VARCHAR (20) NULL;
GO

ALTER TABLE vendedores ADD fechanacimiento DATETIME NULL; 
ALTER TABLE vendedores ADD fechaingreso DATETIME NULL; 
GO 

ALTER TABLE Vendedores ADD CONSTRAINT CK_Comision CHECK (Comision <= 0.10);
GO

--3. Limpieza de datos (Borramos vendedores según la condición) 
DELETE FROM vendedores WHERE Comision > 0.075; 
GO

