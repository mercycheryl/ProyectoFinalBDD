USE Restaurante;

-- Simulaci�n de una consulta VULNERABLE a SQL Injection

-- Escenario normal (entrada esperada)
DECLARE @nombre_buscado_normal VARCHAR(100) = 'Juan Garc�a';
DECLARE @sql_vulnerable_normal NVARCHAR(MAX);

SET @sql_vulnerable_normal = 'SELECT id_empleado, nombre_empleado, cedula FROM Empleado WHERE nombre_empleado = ''' + @nombre_buscado_normal + '''';

PRINT 'Consulta normal (vulnerable):';
PRINT @sql_vulnerable_normal;
-- prueba
EXEC sp_executesql @sql_vulnerable_normal; -- Si la ejecutaras, buscar�a 'Juan Garc�a'


-- Escenario de ATAQUE (entrada maliciosa)
DECLARE @nombre_buscado_ataque VARCHAR(100) = ''' OR 1=1 --'; -- la condici�n WHERE siempre ser� verdadera, devolviendo TODOS los empleados.
DECLARE @sql_vulnerable_ataque NVARCHAR(MAX);

SET @sql_vulnerable_ataque = 'SELECT id_empleado, nombre_empleado, cedula FROM Empleado WHERE nombre_empleado = ''' + @nombre_buscado_ataque + '''';

PRINT CHAR(13) + CHAR(10) + 'Consulta con INTENTO de ATAQUE (vulnerable):';
PRINT @sql_vulnerable_ataque;

EXEC sp_executesql @sql_vulnerable_ataque; -- codigo de ejecuci�n
