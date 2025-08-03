-- Restauración Completa desde un Backup en Caliente

USE master; 

-- Cerrar todas las conexiones existentes a la base de datos 'Restaurante'
ALTER DATABASE Restaurante
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

-- Realiza la restauración completa
RESTORE DATABASE Restaurante
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\MSSQL\Backup\Restaurante03082025.bak' 
WITH REPLACE,    
RECOVERY;       

-- VOLVER A multi_user
ALTER DATABASE Restaurante
SET MULTI_USER;