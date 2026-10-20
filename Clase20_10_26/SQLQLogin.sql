USE master
GO

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'OperadorAstillero')
BEGIN
	CREATE LOGIN OperadorAstillero
	WITH PASSWORD = 'PasswordSeguro123',
		CHECK_POLICY = ON; -- Obliga a cumplir políticas de complejidad de contraseñas

	PRINT 'Login [OperadorAstillero] creado exitosamente a nivel servidor'
END
GO

--Ejercicio practica
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'AuditorExterno')
BEGIN
	CREATE LOGIN AuditorExterno
	WITH PASSWORD = 'ContraSegura123',
		CHECK_POLICY = ON; -- Obliga a cumplir políticas de complejidad de contraseñas

	PRINT 'Login [AuditorExterno] creado exitosamente a nivel servidor'
END
GO