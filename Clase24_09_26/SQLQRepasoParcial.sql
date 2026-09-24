--Ejercicio 1
CREATE DATABASE PrimeraIEVargas
GO

USE PrimeraIEVargas;
GO

CREATE TABLE ClientesRepaso(
IdCliente INT NOT NULL,
Nombre VARCHAR(50) NOT NULL,
Ciudad VARCHAR(50) NOT NULL CONSTRAINT DF_Ciudad DEFAULT 'San Juan'
CONSTRAINT PK_ClientesRepaso PRIMARY KEY(IdCliente)
);
GO

CREATE TABLE PedidosRepaso(
IdPedido INT NOT NULL,
IdCliente INT NOT NULL,
Monto DECIMAL NOT NULL,
FechaPedido DATE NOT NULL
CONSTRAINT PK_PedidosRepaso PRIMARY KEY(IdPedido),
CONSTRAINT FK_IdCliente FOREIGN KEY (IdCliente) REFERENCES ClientesRepaso (IdCliente) ON DELETE CASCADE
);
GO

-- Inserción de datos estandarizados para los Ejercicios 2 y 3
INSERT INTO ClientesRepaso (IdCliente, Nombre, Ciudad) VALUES
(1, 'Juan Pérez', 'Córdoba'),
(2, 'María Gómez', 'Rosario'),
(3, 'Carlos López', 'Buenos Aires'),
(4, 'Ana Torres', 'Córdoba');
GO

INSERT INTO PedidosRepaso (IdPedido, IdCliente, Monto, FechaPedido) VALUES
(101, 1, 15000.00, '20260301'),
(102, 1, 25000.00, '20260305'),
(103, 2, 40000.00, '20260302'),
(104, 3, 12000.00, '20260306'),
(105, 4, 31000.00, '20260310');
GO

--Solo mostrar los pedidos con monto mayor a 20.000
SELECT IdPedido AS 'Numero Pedido', IdCliente AS 'ID cliente', Monto 
FROM PedidosRepaso
WHERE Monto > (20000);
GO

--Filtrar solo los clientes con un pedido con monto mayor a 20.000
SELECT CR.IdCliente AS Numero_Cliente, CR.Nombre, PR.IdPedido AS Numero_Pedido, PR.Monto
FROM dbo.ClientesRepaso AS CR
JOIN dbo.PedidosRepaso AS PR
ON CR.IdCliente = PR.IdCliente
WHERE Monto > (20000);
GO

--Filtrar con GROUP BY
SELECT CR.IdCliente AS Numero_Cliente, CR.Nombre, 
SUM(PR.Monto) AS Total_Monto
FROM dbo.ClientesRepaso AS CR
JOIN dbo.PedidosRepaso AS PR 
ON CR.IdCliente = PR.IdCliente
WHERE PR.Monto > 20000
GROUP BY CR.IdCliente, CR.Nombre;
GO