USE Restaurante;

-- Anonimización de Datos con Dynamic Data Masking (DDM)
-- Añadir una máscara a la columna 'nombre_empleado' para ocultar parcialmente
-- La función 'default()' oculta el nombre completo para VARCHAR/NVARCHAR.
ALTER TABLE Empleado
ALTER COLUMN nombre_empleado ADD MASKED WITH (FUNCTION = 'default()');

-- Crear un usuario de prueba para la demostracion
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'UsuarioPrueba')
BEGIN
    CREATE USER UsuarioPrueba WITHOUT LOGIN;
END
GRANT SELECT ON Empleado TO UsuarioPrueba; -- otorgar permisos

-- Demostrar el enmascaramiento:
-- Para ver los datos enmascarados, ejecuta las siguientes líneas en SSMS
-- (asegúrate de que tu usuario actual tenga permisos para ejecutar AS).
PRINT 'Consulta como UsuarioPrueba';
EXECUTE AS USER = 'UsuarioPrueba';
SELECT id_empleado, nombre_empleado, cedula FROM Empleado;
REVERT; 
PRINT 'Consulta como usuario original '; -- se podrá visualizar el nombre completo, sin ningún enmascaramiento
SELECT id_empleado, nombre_empleado, cedula FROM Empleado;




