USE Astilleros
GO

--LOGIN (Inicio de sesión) - Nivel de Servidor con Usuario y Contraseña (Guardada en BD Master)
	--La creacion esta en el otro SQLQ usando master
--USER (Usuario) - Nivel de Base de Datos
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'UsuOperador')
BEGIN
	CREATE USER UsuOperador
	FOR LOGIN OperadorAstillero;

	PRINT 'Usuario [UsuOperador] mapeado exitosamente en la base de datos Astilleros'
END
GO

--Ejercicio practica
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'UsuAuditor')
BEGIN
	CREATE USER UsuAuditor
	FOR LOGIN AuditorExterno;

	PRINT 'Usuario [UsuAuditor] mapeado exitosamente en Astilleros'
END
GO
