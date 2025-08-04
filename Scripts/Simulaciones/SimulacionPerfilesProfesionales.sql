USE master;

-- 1. Crear Logins de SQL Server para cada perfil

-- Login para Administrador de Base de Datos
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'AdminDBUser')
BEGIN
    CREATE LOGIN AdminDBUser WITH PASSWORD = '123', CHECK_EXPIRATION = OFF, CHECK_POLICY = OFF;
END

-- Login para Arquitecto de Base de Datos
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'ArquitectoDBUser')
BEGIN
    CREATE LOGIN ArquitectoDBUser WITH PASSWORD = 'PasswordArquitecto123', CHECK_EXPIRATION = OFF, CHECK_POLICY = OFF;
END

-- Login para Oficial de Seguridad de Base de Datos
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'OficialSeguridadDBUser')
BEGIN
    CREATE LOGIN OficialSeguridadDBUser WITH PASSWORD = 'PasswordSeguridad123', CHECK_EXPIRATION = OFF, CHECK_POLICY = OFF;
END

-- Login para Desarrollador de Aplicaciones (acceso a DB de desarrollo, no producción)
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'DesarrolladorAppUser')
BEGIN
    CREATE LOGIN DesarrolladorAppUser WITH PASSWORD = 'PasswordDesarrollador123', CHECK_EXPIRATION = OFF, CHECK_POLICY = OFF;
END

-- usuario final: usuario_cajero (ya creado)

-- ::::::::::::::: Crear Usuarios de Base de Datos y Asignar Roles/Permisos :::::::::::::::::::::::::::::::::::

-- Usuario de base de datos para Administrador 
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'AdminDBUser')
BEGIN
    CREATE USER AdminDBUser FOR LOGIN AdminDBUser;
    ALTER ROLE db_owner ADD MEMBER AdminDBUser;
END

-- Usuario de base de datos para Arquitecto: puede ver la estructura, crear objetos, pero no eliminar la DB.
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'ArquitectoDBUser')
BEGIN
    CREATE USER ArquitectoDBUser FOR LOGIN ArquitectoDBUser;
    ALTER ROLE db_ddladmin ADD MEMBER ArquitectoDBUser; -- Puede crear, modificar, eliminar objetos
    ALTER ROLE db_datareader ADD MEMBER ArquitectoDBUser; -- Puede leer datos
    ALTER ROLE db_datawriter ADD MEMBER ArquitectoDBUser; -- Puede escribir datos
END

-- Usuario de base de datos para Oficial de Seguridad: puede ver configuraciones de seguridad, logs, pero no modificar datos o estructura.
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'OficialSeguridadDBUser')
BEGIN
    CREATE USER OficialSeguridadDBUser FOR LOGIN OficialSeguridadDBUser;
    -- Permisos específicos para seguridad y auditoría
    GRANT VIEW SERVER STATE TO OficialSeguridadDBUser;
    GRANT VIEW ANY DATABASE TO OficialSeguridadDBUser;
    GRANT VIEW DEFINITION TO OficialSeguridadDBUser;
    GRANT SELECT ON sys.server_principals TO OficialSeguridadDBUser;
    GRANT SELECT ON sys.database_principals TO OficialSeguridadDBUser;
    GRANT SELECT ON sys.dm_exec_sessions TO OficialSeguridadDBUser;
    GRANT SELECT ON sys.dm_exec_connections TO OficialSeguridadDBUser;
    -- Puede ver datos enmascarados si es necesario para auditoría de privacidad
    GRANT UNMASK TO OficialSeguridadDBUser;
END

-- Usuario de base de datos para Desarrollador
-- Acceso completo a una base de datos de DESARROLLO, no a la de producción, permisos de lector/escritor en Restaurante.
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'DesarrolladorAppUser')
BEGIN
    CREATE USER DesarrolladorAppUser FOR LOGIN DesarrolladorAppUser;
    ALTER ROLE db_datareader ADD MEMBER DesarrolladorAppUser;
    ALTER ROLE db_datawriter ADD MEMBER DesarrolladorAppUser;
    -- Podría tener permisos para ejecutar SPs específicos
    GRANT EXECUTE ON OBJECT::sp_CrearOrdenConDetalles TO DesarrolladorAppUser;
END

-- Usuario de base de datos para Usuario Final (usuario_cajero)
IF EXISTS (SELECT name FROM sys.database_principals WHERE name = 'usuario_cajero')
BEGIN
    -- ejecutar los SPs de la aplicación
    GRANT EXECUTE ON OBJECT::sp_CrearOrdenConDetalles TO usuario_cajero;
    GRANT EXECUTE ON OBJECT::sp_ActualizarEstadoMesa TO usuario_cajero;
    GRANT EXECUTE ON OBJECT::sp_ActualizarInventarioIngrediente TO usuario_cajero;
    -- permisos para SELECT en tablas que necesite leer para la UI
    GRANT SELECT ON Plato TO usuario_cajero;
    GRANT SELECT ON CategoriaPlato TO usuario_cajero;
    GRANT SELECT ON Mesa TO usuario_cajero;
    GRANT SELECT ON Empleado TO usuario_cajero; -- Si necesita ver empleados (enmascarado por DDM)
END

-- :::::::::::::.. verificación ::::::::::::::::::::::::..
PRINT ' Verificacion Logins de Servidor ';

-- Verificar Login 
SELECT name, type_desc, is_disabled
FROM sys.server_principals
WHERE name = 'ArquitectoDBUser'; -- cambiar el nombre del que se desea verificar
