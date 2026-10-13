CREATE DATABASE DB_Vargas;

USE DB_Vargas;
GO

CREATE TABLE Libros(
idLibro INT IDENTITY NOT NULL,
titulo VARCHAR (20) NOT NULL,
idAutor INT NOT NULL,
fecha DATE NOT NULL,
idEditorial INT NOT NULL,
idGenero INT NOT NULL,
cantidad INT NOT NULL,
precio DECIMAL (10,2) NOT NULL CONSTRAINT CH_Precio CHECK (precio >= 1000),
CONSTRAINT PK_Libros PRIMARY KEY (idLibro),
CONSTRAINT FK_Autor FOREIGN KEY (idAutor) REFERENCES Autores (idAutor),
CONSTRAINT FK_Editorial FOREIGN KEY (idEditorial) REFERENCES Editoriales (idEditorial),
CONSTRAINT FK_Genero FOREIGN KEY (idGenero) REFERENCES Generos (idGenero),
);
GO

CREATE TABLE Autores(
idAutor INT IDENTITY NOT NULL,
nombre VARCHAR (20) NOT NULL,
nacionalidad VARCHAR (20) NOT NULL,
CONSTRAINT PK_Autores PRIMARY KEY (idAutor),
);
GO

CREATE TABLE Editoriales(
idEditorial INT IDENTITY NOT NULL,
nombre VARCHAR (20) NOT NULL,
CONSTRAINT PK_Editoriales PRIMARY KEY (idEditorial),
);
GO

CREATE TABLE Generos(
idGenero INT IDENTITY NOT NULL,
nombre VARCHAR (20) NOT NULL,
CONSTRAINT PK_Generos PRIMARY KEY (idGenero)
);
GO

CREATE TABLE Ventas(
idVenta INT IDENTITY NOT NULL,
idEmpleado INT NOT NULL,
idCliente INT NOT NULL,
Fecha DATE NOT NULL,
CONSTRAINT PK_Ventas PRIMARY KEY (idVenta),
CONSTRAINT FK_Ventas_Empleados FOREIGN KEY (idEmpleado) REFERENCES Empleados(idEmpleado),
CONSTRAINT FK_Ventas_Clientes FOREIGN KEY (idCliente) REFERENCES Clientes(idCliente)
);
GO

CREATE TABLE DetalleVentas (
idDetalle INT IDENTITY NOT NULL,
idVenta INT NOT NULL,       -- Se conecta con la cabecera de la venta
idLibro INT NOT NULL,       -- Se conecta con el catálogo de libros
Cantidad INT NOT NULL,
PrecioUnitario DECIMAL(10,2) NOT NULL, -- El precio al que se vendió en ese momento
CONSTRAINT PK_DetalleVentas PRIMARY KEY (idDetalle),
CONSTRAINT FK_Detalle_Ventas FOREIGN KEY (idVenta) REFERENCES Ventas(idVenta) ON DELETE CASCADE,
CONSTRAINT FK_Detalle_Libros FOREIGN KEY (idLibro) REFERENCES Libros(idLibro)
);
GO

CREATE TABLE Clientes(
idCliente INT IDENTITY NOT NULL,
nombre VARCHAR(20) NOT NULL,
telefono VARCHAR(20) NULL,
email VARCHAR(20) NULL,
CONSTRAINT PK_Clientes PRIMARY KEY (idCliente)
);
GO

CREATE TABLE Empleados(
idEmpleado INT IDENTITY NOT NULL,
nombre VARCHAR(20) NOT NULL,
cargo VARCHAR(30) NOT NULL,
CONSTRAINT PK_Empleados PRIMARY KEY (idEmpleado)
);
GO