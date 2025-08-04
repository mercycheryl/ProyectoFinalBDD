-- AUDITORIA
-- 1. Tabla log_acciones 
SELECT
    id_log,
    nombre_tabla,
    id_registro,
    tipo_accion,
    descripcion,
    fecha_accion,
    usuario_accion
FROM
    log_acciones
ORDER BY
    fecha_accion DESC; -- ordena desde la fecha mas reciente
GO
-- 2. Triggers conectados 
SELECT
    id_log,
    id_registro,
    tipo_accion,
    descripcion,
    fecha_accion,
    usuario_accion
FROM
    log_acciones
WHERE
    nombre_tabla = 'Plato' -- Filtrar la tabla por el nombre
ORDER BY
    fecha_accion DESC;
GO
-- 3. Reportes de Auditoría (SP para ver las acciones recientes)
CREATE PROCEDURE sp_ReporteAuditoria
    @fecha_inicio DATE = NULL,
    @fecha_fin DATE = NULL,
    @tipo_accion VARCHAR(10) = NULL,
    @nombre_tabla VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_log,
        nombre_tabla,
        id_registro,
        tipo_accion,
        descripcion,
        fecha_accion,
        usuario_accion
    FROM log_acciones
    WHERE
        (@fecha_inicio IS NULL OR fecha_accion >= @fecha_inicio) AND
        (@fecha_fin IS NULL OR fecha_accion <= @fecha_fin) AND
        (@tipo_accion IS NULL OR tipo_accion = @tipo_accion) AND
        (@nombre_tabla IS NULL OR nombre_tabla = @nombre_tabla)
    ORDER BY fecha_accion DESC;
END;

-- ver todos los registros de auditoria (sin filtros)
EXEC sp_ReporteAuditoria;
-- ver INSERT
EXEC sp_ReporteAuditoria @tipo_accion = 'INSERT';
-- ver todas las acciones en la tabla 'plato'
EXEC sp_ReporteAuditoria @nombre_tabla = 'Plato';