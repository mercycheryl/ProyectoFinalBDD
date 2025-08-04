-- PROCEDIMIENTOS ALMACENADOS

-- 1. SP para insertar un nuevo plato (con validación de categoría existente).
CREATE PROCEDURE sp_InsertarPlato
    @nombre_plato VARCHAR(50),
    @precio DECIMAL(10,2),
    @id_categoria INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Validar si la categoría existe
    IF NOT EXISTS (SELECT 1 FROM CategoriaPlato WHERE id_categoria = @id_categoria)
    BEGIN
        PRINT 'Error: La categoría especificada no existe.';
        RETURN -1; -- Retorna un código de error
    END

    INSERT INTO Plato (nombre_plato, precio, id_categoria)
    VALUES (@nombre_plato, @precio, @id_categoria);

    PRINT 'Plato insertado exitosamente.';
    RETURN SCOPE_IDENTITY(); -- Retorna el ID del nuevo plato
END;

-- 2. SP para actualizar el estado de una mesa (con validación de estado válido).
CREATE PROCEDURE sp_ActualizarEstadoMesa
    @id_mesa INT,
    @nuevo_estado VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    -- Validar si la mesa existe
    IF NOT EXISTS (SELECT 1 FROM Mesa WHERE id_mesa = @id_mesa)
    BEGIN
        PRINT 'Error: La mesa especificada no existe.';
        RETURN -1;
    END

    -- Validar que el nuevo estado sea uno permitido (ej: 'ocupada', 'libre', 'reservada')
    IF @nuevo_estado NOT IN ('ocupada', 'libre', 'reservada', 'mantenimiento')
    BEGIN
        PRINT 'Error: Estado de mesa no válido. Los estados permitidos son: ocupada, libre, reservada, mantenimiento.';
        RETURN -2;
    END

    UPDATE Mesa
    SET estado_mesa = @nuevo_estado
    WHERE id_mesa = @id_mesa;

    PRINT 'Estado de mesa actualizado exitosamente.';
    RETURN 0;
END;

-- 3. SP para generar un reporte de ventas por categoría de plato en un rango de fechas.
CREATE PROCEDURE sp_ReporteVentasPorCategoria
    @fecha_inicio DATE,
    @fecha_fin DATE
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        CP.tipo_categoria,
        SUM(DO.cantidad * P.precio) AS total_ventas
    FROM Orden AS O
    JOIN DetalleOrden AS DO ON O.id_orden = DO.id_orden
    JOIN Plato AS P ON DO.id_plato = P.id_plato
    JOIN CategoriaPlato AS CP ON P.id_categoria = CP.id_categoria
    WHERE O.fecha >= @fecha_inicio AND O.fecha <= @fecha_fin
    GROUP BY CP.tipo_categoria
    ORDER BY total_ventas DESC;
END;

-- 4. SP para registrar una nueva orden y sus detalles (con transacción).
-- Corregido para manejar el ID de orden cuando un trigger INSTEAD OF está activo.
CREATE PROCEDURE sp_CrearOrdenConDetalles
    @id_mesa INT,
    @id_empleado INT,
    @detalles_orden NVARCHAR(MAX) -- JSON o XML para los detalles: Ejemplo: '[{"id_plato":1, "cantidad":2}, {"id_plato":3, "cantidad":1}]'
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON; -- Abortar la transacción si ocurre un error

    DECLARE @orden_id_final INT; -- Declarada como variable escalar

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar existencia de mesa y empleado
        IF NOT EXISTS (SELECT 1 FROM Mesa WHERE id_mesa = @id_mesa)
        BEGIN
            RAISERROR('Error: La mesa especificada no existe.', 16, 1);
        END

        IF NOT EXISTS (SELECT 1 FROM Empleado WHERE id_empleado = @id_empleado)
        BEGIN
            RAISERROR('Error: El empleado especificado no existe.', 16, 1);
        END

        -- Insertar la orden (esto activará el trigger INSTEAD OF)
        -- Ya no usamos la cláusula OUTPUT INTO una variable de tabla aquí.
        INSERT INTO Orden (id_mesa, id_empleado, id_estado)
        VALUES (@id_mesa, @id_empleado, 1); -- Asume 1 como 'Pendiente' en EstadoPedido

        -- Capturamos el ID generado por la inserción del trigger usando SCOPE_IDENTITY()
        -- SCOPE_IDENTITY() es la forma más fiable de obtener el ID generado por una columna IDENTITY
        -- en el mismo ámbito, incluso si es a través de un trigger INSTEAD OF.
        SET @orden_id_final = SCOPE_IDENTITY();

        -- DEBUGGING: Imprimimos el valor de @orden_id_final para verificar
        PRINT 'DEBUG: @orden_id_final después de insertar Orden (vía trigger): ' + ISNULL(CAST(@orden_id_final AS VARCHAR), 'NULL');

        -- Validar que se haya obtenido un ID de orden válido
        IF @orden_id_final IS NULL OR @orden_id_final <= 0
        BEGIN
            RAISERROR('Error: No se pudo obtener un ID de orden válido después de la inserción.', 16, 1);
        END

        -- Insertar los detalles de la orden (ejemplo asumiendo JSON)
        INSERT INTO DetalleOrden (id_orden, id_plato, cantidad)
        SELECT
            @orden_id_final, -- Usamos el ID de orden capturado
            JSON_VALUE(value, '$.id_plato'),
            JSON_VALUE(value, '$.cantidad')
        FROM OPENJSON(@detalles_orden);

        COMMIT TRANSACTION;
        PRINT 'Orden creada exitosamente con ID: ' + CAST(@orden_id_final AS VARCHAR);
        RETURN @orden_id_final;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(MAX), @ErrorSeverity INT, @ErrorState INT;
        SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN -1;
    END CATCH;
END;

-- 5. SP para actualizar la cantidad de un ingrediente en el inventario.
CREATE PROCEDURE sp_ActualizarInventarioIngrediente
    @id_ingrediente INT,
    @cantidad_ajuste INT -- Puede ser positivo para añadir o negativo para restar
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar si el ingrediente existe
    IF NOT EXISTS (SELECT 1 FROM Ingrediente WHERE id_ingrediente = @id_ingrediente)
    BEGIN
        PRINT 'Error: El ingrediente especificado no existe.';
        RETURN -1;
    END

    UPDATE Inventario
    SET cantidad = cantidad + @cantidad_ajuste,
        fecha = GETDATE() -- Actualizar la fecha de la última modificación
    WHERE id_ingrediente = @id_ingrediente;

    -- Opcional: Actualizar la disponibilidad si la cantidad baja de cierto umbral
    DECLARE @cantidad_actual INT;
    SELECT @cantidad_actual = cantidad FROM Inventario WHERE id_ingrediente = @id_ingrediente;

    IF @cantidad_actual <= 0
    BEGIN
        UPDATE Inventario SET disponibilidad = 'Agotado' WHERE id_ingrediente = @id_ingrediente;
    END
    ELSE IF @cantidad_actual < 10 -- Umbral de baja disponibilidad
    BEGIN
        UPDATE Inventario SET disponibilidad = 'Bajo Stock' WHERE id_ingrediente = @id_ingrediente;
    END
    ELSE
    BEGIN
        UPDATE Inventario SET disponibilidad = 'Disponible' WHERE id_ingrediente = @id_ingrediente;
    END

    PRINT 'Inventario del ingrediente actualizado exitosamente.';
    RETURN 0;
END;