-- FUNCIONES

-- 1. Función para calcular el total de una orden.
CREATE FUNCTION fn_CalcularTotalOrden (@id_orden INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @total DECIMAL(10,2);

    SELECT @total = SUM(DO.cantidad * P.precio)
    FROM DetalleOrden AS DO
    JOIN Plato AS P ON DO.id_plato = P.id_plato
    WHERE DO.id_orden = @id_orden;

    RETURN ISNULL(@total, 0);
END;

-- 2. Función para obtener el número de platos en una categoría.
CREATE FUNCTION fn_ContarPlatosPorCategoria (@id_categoria INT)
RETURNS INT
AS
BEGIN
    DECLARE @conteo INT;

    SELECT @conteo = COUNT(id_plato)
    FROM Plato
    WHERE id_categoria = @id_categoria;

    RETURN ISNULL(@conteo, 0);
END;

-- 3. Función para determinar la duración de un turno en horas.
CREATE FUNCTION fn_CalcularDuracionTurnoHoras (@id_turno INT)
RETURNS DECIMAL(4,2)
AS
BEGIN
    DECLARE @duracion_horas DECIMAL(4,2);

    SELECT @duracion_horas = DATEDIFF(minute, hora_inicio, hora_fin) / 60.0
    FROM Turno
    WHERE id_turno = @id_turno;

    RETURN ISNULL(@duracion_horas, 0);
END;