-- TRIGGERS

CREATE TABLE log_acciones (
    id_log INT IDENTITY(1,1) PRIMARY KEY,
    nombre_tabla VARCHAR(50) NOT NULL,
    id_registro INT NOT NULL,
    tipo_accion VARCHAR(10) NOT NULL, -- INSERT, UPDATE, DELETE
    descripcion VARCHAR(255),
    fecha_accion DATETIME DEFAULT GETDATE(),
    usuario_accion VARCHAR(100) DEFAULT SUSER_SNAME()
);

-- 1. Trigger de Auditoría: Registra cambios en la tabla 'Plato'.
CREATE TRIGGER tr_AuditoriaPlato
ON Plato
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Para INSERT
    IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
    BEGIN
        INSERT INTO log_acciones (nombre_tabla, id_registro, tipo_accion, descripcion)
        SELECT 'Plato', id_plato, 'INSERT', 'Nuevo plato insertado: ' + nombre_plato
        FROM INSERTED;
    END
    -- Para UPDATE
    ELSE IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
    BEGIN
        INSERT INTO log_acciones (nombre_tabla, id_registro, tipo_accion, descripcion)
        SELECT 'Plato', I.id_plato, 'UPDATE', 'Plato actualizado: ' + I.nombre_plato + ' (Precio anterior: ' + CAST(D.precio AS VARCHAR) + ', Precio nuevo: ' + CAST(I.precio AS VARCHAR) + ')'
        FROM INSERTED AS I
        JOIN DELETED AS D ON I.id_plato = D.id_plato;
    END
    -- Para DELETE
    ELSE IF EXISTS (SELECT * FROM DELETED) AND NOT EXISTS (SELECT * FROM INSERTED)
    BEGIN
        INSERT INTO log_acciones (nombre_tabla, id_registro, tipo_accion, descripcion)
        SELECT 'Plato', id_plato, 'DELETE', 'Plato eliminado: ' + nombre_plato
        FROM DELETED;
    END
END;

-- 2. Trigger de Validación Automática: Evita la eliminación de un plato si está en alguna orden.
-- Este trigger se activa ANTES de que se intente eliminar un registro de la tabla Plato.
CREATE TRIGGER tr_ValidarEliminarPlato
ON Plato
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Declaramos una variable para almacenar el ID del plato que se intenta eliminar
    DECLARE @id_plato_a_eliminar INT;
    SELECT @id_plato_a_eliminar = id_plato FROM DELETED;

    -- Verificamos si el plato que se intenta eliminar existe en la tabla DetalleOrden
    IF EXISTS (SELECT 1 FROM DetalleOrden WHERE id_plato = @id_plato_a_eliminar)
    BEGIN
        -- Si el plato está en DetalleOrden, levantamos un error y no permitimos la eliminación
        RAISERROR('No se puede eliminar el plato con ID %d porque está asociado a una o más órdenes. Elimine primero los detalles de orden relacionados.', 16, 1, @id_plato_a_eliminar);
    END
    ELSE
    BEGIN
        -- Si el plato no está en ninguna DetalleOrden, permitimos la eliminación
        DELETE FROM Plato
        WHERE id_plato = @id_plato_a_eliminar;

        PRINT 'Plato con ID ' + CAST(@id_plato_a_eliminar AS VARCHAR) + ' eliminado exitosamente.';
    END
END;
GO


-- 3. Trigger de Simulación de Notificación: Cuando se actualiza el estado de un pedido a 'Completado', simula una notificación.
CREATE TRIGGER tr_NotificacionPedidoCompletado
ON Orden
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @old_estado INT;
    DECLARE @new_estado INT;
    DECLARE @id_orden INT;
    DECLARE @numero_mesa INT;

    SELECT @old_estado = D.id_estado, @new_estado = I.id_estado, @id_orden = I.id_orden
    FROM INSERTED AS I
    JOIN DELETED AS D ON I.id_orden = D.id_orden;

    SELECT @numero_mesa = M.numero_mesa
    FROM Orden AS O
    JOIN Mesa AS M ON O.id_mesa = M.id_mesa
    WHERE O.id_orden = @id_orden;

    -- Asumiendo que el id_estado para 'Completado' es 2 (deberías verificarlo en tu tabla EstadoPedido)
    IF @old_estado <> @new_estado AND @new_estado = (SELECT id_estado FROM EstadoPedido WHERE estado_pedido = 'Completado')
    BEGIN
        PRINT 'Notificación: ¡La Orden ' + CAST(@id_orden AS VARCHAR) + ' para la Mesa ' + CAST(@numero_mesa AS VARCHAR) + ' ha sido completada!';
        -- Aquí podrías añadir lógica para enviar un mensaje a una cola de mensajes, un correo, etc.
    END
END;