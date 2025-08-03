USE Restaurante;

-- Protección contra SQL Injection con Consultas Preparadas (sp_executesql)
-- 1. Escenario normal (entrada esperada)
DECLARE @nombre_buscado_seguro VARCHAR(100) = 'Juan García';
DECLARE @sql_seguro NVARCHAR(MAX);
DECLARE @parametros NVARCHAR(MAX);

-- Define la consulta SQL con un marcador de posición para el parámetro (@pNombre)
SET @sql_seguro = N'SELECT id_empleado, nombre_empleado, cedula FROM Empleado WHERE nombre_empleado = @pNombre;';

SET @parametros = N'@pNombre VARCHAR(100)'; -- Definir los parámetros para la consulta

PRINT 'Consulta segura (normal):';
PRINT @sql_seguro;
EXEC sp_executesql @sql_seguro, @parametros, @pNombre = @nombre_buscado_seguro; -- Ejecuta la consulta pasando el valor como un parámetro
PRINT CHAR(13) + CHAR(10) + 'Resultados de la consulta segura (normal):';

-- 2. Escenario de ATAQUE (entrada maliciosa)
-- Codigo malicioso ' OR 1=1 --
DECLARE @nombre_buscado_ataque_seguro VARCHAR(100) = ''' OR 1=1 --';
PRINT CHAR(13) + CHAR(10) + 'Consulta segura con INTENTO de ATAQUE:';
PRINT @sql_seguro;
-- Ejecuta la consulta pasando la entrada maliciosa como un parámetro
EXEC sp_executesql @sql_seguro, @parametros, @pNombre = @nombre_buscado_ataque_seguro;
PRINT CHAR(13) + CHAR(10) + 'Resultados de la consulta segura (con ataque):';
