USE Astilleros;
GO

--Índices No Agrupados (Non-Clustered Index): Se usa para Alta Selectividad
CREATE NONCLUSTERED INDEX IX_Clientes_Localidad
ON clientes (localidad);
GO

--Ctlr + L indica como se realiza una consulta
--Consulta
SELECT cliente, nombre, localidad FROM clientes
WHERE localidad = 'Cordoba';
GO

--Actividad 1: Utiliza el CLUSTERED INDEX
SELECT cliente, presupuesto, fecha FROM dbo.presupuesto;
GO

--Actividad 2
CREATE NONCLUSTERED INDEX IX_Presupuesto_Fecha
ON presupuesto (fecha);
GO

--Actividad 3
SELECT cliente, presupuesto, fecha FROM dbo.presupuesto
WHERE fecha >= '20260201' AND fecha < '20260301';
GO