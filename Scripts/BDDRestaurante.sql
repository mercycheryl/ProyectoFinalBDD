-- CREACION DE LA BASE DE DATOS
create database Restaurante;
use Restaurante;

-- CREACION DE LAS TABLAS
create table Mesa (id_mesa INT IDENTITY(1,1) NOT NULL,
	numero_mesa int not null unique,
	capacidad int null,
	estado_mesa varchar(10),
	constraint PK_Mesa primary key (id_mesa)
);
	
create table Turno (id_turno int identity(1,1) not null,
	hora_inicio time not null,
	hora_fin time not null,
	constraint PK_Turno primary key (id_turno)
);

create table EstadoPedido(id_estado int identity(1,1) not null,
	estado_pedido varchar(15),
	constraint PK_EstadoPedido primary key (id_estado));
	

create table CategoriaPlato(id_categoria int identity(1,1) not null,
	tipo_categoria varchar(50) not null unique,
	constraint PK_CategoriaPlato primary key (id_categoria));

create table Ingrediente(id_ingrediente int identity(1,1) not null,
	nombre varchar(30) not null unique,
	unidad int not null,
	medida varchar(5) not null,
	constraint PK_Ingrediente primary key(id_ingrediente));

create table Rol (id_rol int identity(1,1)not null,
	tipoRol varchar(30),
	constraint PK_Rol primary key (id_rol));
	
create table Plato(id_plato int identity (1,1) not null,
	nombre_plato varchar(50),
	precio decimal(10,2)not null,
	id_categoria int not null,
	constraint PK_Plato primary key(id_plato),
	foreign key(id_categoria) references CategoriaPlato (id_categoria));


create table Orden(id_orden int identity(1,1) not null,
	fecha datetime not null default getdate(),
	id_mesa int not null,
	id_empleado int not null,
	id_estado int not null,
	constraint PK_Orden primary key(id_orden),
	foreign key(id_mesa)references Mesa(id_mesa),
	foreign key(id_empleado)references Empleado (id_empleado),
	foreign key(id_estado)references EstadoPedido(id_estado));


create table DetalleOrden(id_detalle int identity(1,1)not null,
	cantidad  int not null,
	id_plato int not null,
	id_orden int not null,
	constraint PK_DetalleOrden primary key(id_detalle),
	foreign key(id_plato) references Plato (id_plato),
	foreign key(id_orden) references Orden (id_orden));

create table PlatoIngrediente(id_plato int not null,
	id_ingrediente int not null,
	cantidad int not null,
	foreign key(id_plato)references Plato(id_plato),
	foreign key(id_ingrediente)references Ingrediente(id_ingrediente));

create table Inventario(id_inventario int identity(1,1)not null,
	fecha date not null default getdate(),
	disponibilidad varchar(50) not null,
	cantidad int not null,
	id_ingrediente int not null,
	constraint PK_Inventario primary key (id_inventario),
	foreign key(id_ingrediente)references Ingrediente(id_ingrediente));

create table Empleado(id_empleado int identity(1,1) not null,
	nombre_empleado varchar(100) not null,
	cedula int not null unique,
	id_rol int not null,
	id_turno int not null,
	constraint PK_Empleado primary key(id_empleado),
	foreign key(id_rol)references Rol (id_rol),
	foreign key(id_turno)references Turno(id_turno));

-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.
-- 500 registros
use Restaurante;

USE Restaurante;

-- 1. Insertar datos en Turno (500 registros)
-- Genera horas de inicio y fin realistas para los turnos.
DECLARE @i INT = 1;
DECLARE @startTime TIME;
DECLARE @endTime TIME;
WHILE @i <= 500
BEGIN
    SET @startTime = DATEADD(minute, ROUND(RAND() * 1440, 0), '08:00:00'); -- Hora aleatoria dentro de un día
    SET @endTime = DATEADD(hour, ROUND(RAND() * 8, 0) + 4, @startTime); -- Turnos entre 4 y 12 horas
    IF @endTime < @startTime SET @endTime = DATEADD(hour, 24, @endTime); -- Manejar turnos que cruzan la medianoche

    INSERT INTO Turno (hora_inicio, hora_fin)
    VALUES (@startTime, @endTime);
    SET @i = @i + 1;
END;

-- 2. Insertar datos en Rol (500 registros - usando un conjunto más pequeño de roles únicos y repitiéndolos)
-- Crea roles comunes para empleados.
SET @i = 1;
DECLARE @roles TABLE (roleName VARCHAR(30));
INSERT INTO @roles (roleName) VALUES
('Mesero'), ('Cocinero'), ('Bartender'), ('Gerente'), ('Ayudante de Cocina'),
('Cajero'), ('Hostess'), ('Lavaplatos'), ('Supervisor');

WHILE @i <= 500
BEGIN
    INSERT INTO Rol (tipoRol)
    VALUES ( (SELECT TOP 1 roleName FROM @roles ORDER BY NEWID()) );
    SET @i = @i + 1;
END;


-- 3. Insertar datos en EstadoPedido (500 registros - usando un conjunto más pequeño de estados únicos y repitiéndolos)
-- Define los posibles estados de un pedido.
SET @i = 1;
DECLARE @estados TABLE (estado VARCHAR(15));
INSERT INTO @estados (estado) VALUES
('Pendiente'), ('Preparando'), ('Listo'), ('Servido'), ('Pagado'), ('Cancelado');

WHILE @i <= 500
BEGIN
    INSERT INTO EstadoPedido (estado_pedido)
    VALUES ( (SELECT TOP 1 estado FROM @estados ORDER BY NEWID()) );
    SET @i = @i + 1;
END;


-- 4. Insertar datos en CategoriaPlato (500 registros - usando un conjunto más pequeño de categorías únicas y repitiéndolas)
-- Lista varias categorías de alimentos.
SET @i = 1;
DECLARE @categorias TABLE (categoria VARCHAR(50));
INSERT INTO @categorias (categoria) VALUES
('Entradas'), ('Platos Fuertes'), ('Postres'), ('Bebidas Frías'), ('Bebidas Calientes'),
('Ensaladas'), ('Sopas'), ('Pastas'), ('Pizzas'), ('Mariscos'), ('Carnes');

WHILE @i <= 500
BEGIN
    INSERT INTO CategoriaPlato (tipo_categoria)
    VALUES ( (SELECT TOP 1 categoria FROM @categorias ORDER BY NEWID()) );
    SET @i = @i + 1;
END;


-- 5. Insertar datos en Mesa (500 registros)
-- Crea mesas con capacidades y estados variados.
SET @i = 1;
DECLARE @estados_mesa TABLE (estado VARCHAR(10));
INSERT INTO @estados_mesa (estado) VALUES ('Disponible'), ('Ocupada'), ('Limpieza');

WHILE @i <= 500
BEGIN
    INSERT INTO Mesa (numero_mesa, capacidad, estado_mesa)
    VALUES (@i, ROUND(RAND() * 9, 0) + 2, (SELECT TOP 1 estado FROM @estados_mesa ORDER BY NEWID())); -- Capacidad entre 2 y 11
    SET @i = @i + 1;
END;


-- 6. Insertar datos en Ingrediente (500 registros)
-- Rellena con ingredientes comunes, unidades y medidas.
SET @i = 1;
DECLARE @medidas TABLE (medida VARCHAR(5));
INSERT INTO @medidas (medida) VALUES ('gr'), ('ml'), ('unid'), ('kg'), ('lt');

DECLARE @ingredientes TABLE (nombre VARCHAR(30));
INSERT INTO @ingredientes (nombre) VALUES
('Tomate'), ('Lechuga'), ('Cebolla'), ('Pollo'), ('Carne de Res'), ('Pescado'),
('Arroz'), ('Papa'), ('Zanahoria'), ('Pimienta'), ('Sal'), ('Azúcar'), ('Harina'),
('Huevos'), ('Leche'), ('Mantequilla'), ('Aceite'), ('Ajo'), ('Perejil'), ('Cilantro'),
('Limón'), ('Naranja'), ('Manzana'), ('Plátano'), ('Fresa'), ('Chocolate'), ('Vainilla'),
('Pasta'), ('Queso'), ('Pan');

WHILE @i <= 500
BEGIN
    INSERT INTO Ingrediente (nombre, unidad, medida)
    VALUES (
        (SELECT TOP 1 nombre FROM @ingredientes ORDER BY NEWID()) + CAST(@i AS VARCHAR(10)), -- Asegura nombres únicos
        ROUND(RAND() * 1000, 0) + 1, -- Unidades entre 1 y 1000
        (SELECT TOP 1 medida FROM @medidas ORDER BY NEWID())
    );
    SET @i = @i + 1;
END;


-- 7. Insertar datos en Empleado (500 registros)
-- Genera nombres de empleados, cédulas únicas y los asigna a roles y turnos.
SET @i = 1;
DECLARE @firstNames TABLE (name VARCHAR(50));
INSERT INTO @firstNames (name) VALUES
('Juan'), ('María'), ('Pedro'), ('Ana'), ('Luis'), ('Sofía'), ('Carlos'), ('Laura'), ('Diego'), ('Valeria');

DECLARE @lastNames TABLE (name VARCHAR(50));
INSERT INTO @lastNames (name) VALUES
('García'), ('Rodríguez'), ('Martínez'), ('López'), ('González'), ('Pérez'), ('Sánchez'), ('Ramírez'), ('Torres'), ('Flores');

WHILE @i <= 500
BEGIN
    DECLARE @nombreEmpleado VARCHAR(100) = (SELECT TOP 1 name FROM @firstNames ORDER BY NEWID()) + ' ' + (SELECT TOP 1 name FROM @lastNames ORDER BY NEWID());
    DECLARE @cedula INT = 100000000 + @i; -- Asegura cédulas únicas

    INSERT INTO Empleado (nombre_empleado, cedula, id_rol, id_turno)
    VALUES (
        @nombreEmpleado,
        @cedula,
        (SELECT id_rol FROM Rol ORDER BY NEWID() OFFSET 0 ROWS FETCH NEXT 1 ROW ONLY),
        (SELECT id_turno FROM Turno ORDER BY NEWID() OFFSET 0 ROWS FETCH NEXT 1 ROW ONLY)
    );
    SET @i = @i + 1;
END;


-- 8. Insertar datos en Plato (500 registros)
-- Crea platos con nombres, precios y los asigna a categorías.
SET @i = 1;
DECLARE @platoNames TABLE (name VARCHAR(50));
INSERT INTO @platoNames (name) VALUES
('Ensalada César'), ('Lomo Saltado'), ('Pasta Alfredo'), ('Pizza Pepperoni'), ('Sopa de Tomate'),
('Salmón a la Plancha'), ('Hamburguesa Clásica'), ('Tarta de Chocolate'), ('Jugo de Naranja'), ('Café Expresso'),
('Ceviche Mixto'), ('Arroz con Pollo'), ('Tiramisú'), ('Mojito'), ('Tacos al Pastor');

WHILE @i <= 500
BEGIN
    INSERT INTO Plato (nombre_plato, precio, id_categoria)
    VALUES (
        (SELECT TOP 1 name FROM @platoNames ORDER BY NEWID()) + ' ' + CAST(@i AS VARCHAR(10)), -- Asegura nombres únicos
        ROUND(RAND() * 200, 2) + 5, -- Precio entre 5.00 y 205.00
        (SELECT id_categoria FROM CategoriaPlato ORDER BY NEWID() OFFSET 0 ROWS FETCH NEXT 1 ROW ONLY)
    );
    SET @i = @i + 1;
END;


-- 9. Insertar datos en Orden (500 registros)
-- Genera órdenes, vinculándolas a mesas, empleados y estados de pedido.
SET @i = 1;
WHILE @i <= 500
BEGIN
    INSERT INTO Orden (fecha, id_mesa, id_empleado, id_estado)
    VALUES (
        DATEADD(day, -ROUND(RAND() * 365, 0), GETDATE()), -- Fecha aleatoria dentro del último año
        (SELECT id_mesa FROM Mesa ORDER BY NEWID() OFFSET 0 ROWS FETCH NEXT 1 ROW ONLY),
        (SELECT id_empleado FROM Empleado ORDER BY NEWID() OFFSET 0 ROWS FETCH NEXT 1 ROW ONLY),
        (SELECT id_estado FROM EstadoPedido ORDER BY NEWID() OFFSET 0 ROWS FETCH NEXT 1 ROW ONLY)
    );
    SET @i = @i + 1;
END;


-- 10. Insertar datos en PlatoIngrediente (500 registros)
-- Vincula platos a ingredientes y especifica cantidades.
SET @i = 1;
WHILE @i <= 500
BEGIN
    INSERT INTO PlatoIngrediente (id_plato, id_ingrediente, cantidad)
    VALUES (
        (SELECT id_plato FROM Plato ORDER BY NEWID() OFFSET 0 ROWS FETCH NEXT 1 ROW ONLY),
        (SELECT id_ingrediente FROM Ingrediente ORDER BY NEWID() OFFSET 0 ROWS FETCH NEXT 1 ROW ONLY),
        ROUND(RAND() * 100, 0) + 1 -- Cantidad entre 1 y 100
    );
    SET @i = @i + 1;
END;

-- 11. Insertar datos en Inventario (500 registros)
-- Rastrea la disponibilidad y cantidad de los ingredientes.
SET @i = 1;
DECLARE @disponibilidad_estados TABLE (estado VARCHAR(50));
INSERT INTO @disponibilidad_estados (estado) VALUES ('En Stock'), ('Bajo Stock'), ('Agotado'), ('Pedido');

WHILE @i <= 500
BEGIN
    INSERT INTO Inventario (fecha, disponibilidad, cantidad, id_ingrediente)
    VALUES (
        DATEADD(day, -ROUND(RAND() * 30, 0), GETDATE()), -- Fecha aleatoria de los últimos 30 días
        (SELECT TOP 1 estado FROM @disponibilidad_estados ORDER BY NEWID()),
        ROUND(RAND() * 500, 0) + 1, -- Cantidad entre 1 y 500
        (SELECT id_ingrediente FROM Ingrediente ORDER BY NEWID() OFFSET 0 ROWS FETCH NEXT 1 ROW ONLY)
    );
    SET @i = @i + 1;
END;

-- 12. Insertar datos en DetalleOrden (500 registros)
-- Especifica las cantidades de cada plato en una orden.
SET @i = 1;
WHILE @i <= 500
BEGIN
    INSERT INTO DetalleOrden (cantidad, id_plato, id_orden)
    VALUES (
        ROUND(RAND() * 5, 0) + 1, -- Cantidad de platos entre 1 y 6
        (SELECT id_plato FROM Plato ORDER BY NEWID() OFFSET 0 ROWS FETCH NEXT 1 ROW ONLY),
        (SELECT id_orden FROM Orden ORDER BY NEWID() OFFSET 0 ROWS FETCH NEXT 1 ROW ONLY)
    );
    SET @i = @i + 1;
END;

select * from Orden;


-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


-- 1. Obtener todas las órdenes con el nombre del empleado que la tomó y el estado del pedido.
SELECT
    O.id_orden,
    O.fecha,
    M.numero_mesa,
    E.nombre_empleado,
    EP.estado_pedido
FROM Orden AS O
JOIN Mesa AS M ON O.id_mesa = M.id_mesa
JOIN Empleado AS E ON O.id_empleado = E.id_empleado
JOIN EstadoPedido AS EP ON O.id_estado = EP.id_estado;

-- 2. Listar los platos y su categoría.
SELECT
    P.nombre_plato,
    CP.tipo_categoria
FROM Plato AS P
JOIN CategoriaPlato AS CP ON P.id_categoria = CP.id_categoria;

-- 3. Ver el detalle de una orden específica, incluyendo los nombres de los platos y sus cantidades.
SELECT
    O.id_orden,
    P.nombre_plato,
    DO.cantidad
FROM DetalleOrden AS DO
JOIN Plato AS P ON DO.id_plato = P.id_plato
JOIN Orden AS O ON DO.id_orden = O.id_orden
WHERE O.id_orden = 211; --- colocar el id que se quiere consultar



-- 4. Obtener el inventario actual de los ingredientes, incluyendo el nombre del ingrediente.
SELECT
    I.nombre AS nombre_ingrediente,
    IV.cantidad,
    IV.disponibilidad,
    IV.fecha
FROM Inventario AS IV
JOIN Ingrediente AS I ON IV.id_ingrediente = I.id_ingrediente;

-- 5. Mostrar los empleados y el rol que desempeñan, junto con su horario de turno.
SELECT
    E.nombre_empleado,
    R.tipoRol,
    T.hora_inicio,
    T.hora_fin
FROM Empleado AS E
JOIN Rol AS R ON E.id_rol = R.id_rol
JOIN Turno AS T ON E.id_turno = T.id_turno;

-- ::::::::::::::::::::::::::
-- SP
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

-- ::::::::::::::::::::::::::::::....
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

-- ::::::::::::::::::::.. triggers ::::::::::::::::::::::::::
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


-- ::::::::::::::........
-- Índices simples:
-- Mejoran el rendimiento de las consultas que buscan por estas columnas.
CREATE INDEX IX_Mesa_NumeroMesa ON Mesa (numero_mesa);
CREATE INDEX IX_Empleado_Cedula ON Empleado (cedula);
CREATE INDEX IX_Plato_NombrePlato ON Plato (nombre_plato);
CREATE INDEX IX_Ingrediente_Nombre ON Ingrediente (nombre);
CREATE INDEX IX_Orden_Fecha ON Orden (fecha);

-- Índices compuestos:
-- Útiles para consultas que filtran y/o ordenan por múltiples columnas.
CREATE INDEX IX_Orden_EmpleadoMesa ON Orden (id_empleado, id_mesa);
CREATE INDEX IX_DetalleOrden_OrdenPlato ON DetalleOrden (id_orden, id_plato);
CREATE INDEX IX_Plato_CategoriaPrecio ON Plato (id_categoria, precio);

-- :::::::::::::::::::::::
-- Análisis de rendimiento (Ejemplo de uso de EXPLAIN PLAN en SQL Server)
-- No se ejecuta, solo muestra cómo se analizaría:
-- SELECT * FROM sys.dm_exec_query_stats;
-- DBCC SHOW_STATISTICS ('Mesa', 'IX_Mesa_NumeroMesa');
-- Para ver el plan de ejecución de una consulta, puedes usar:
-- SET SHOWPLAN_ALL ON;
-- GO
-- SELECT O.id_orden, E.nombre_empleado FROM Orden AS O JOIN Empleado AS E ON O.id_empleado = E.id_empleado;
-- GO
-- SET SHOWPLAN_ALL OFF;
-- GO
-- ::::::::::::::::::::::::::::::::

-- 1. Creación de Roles de Base de Datos
CREATE ROLE RolCajero;
CREATE ROLE RolChef;
CREATE ROLE RolAdminRestaurante;

-- 2. Asignación de Privilegios a Roles
-- RolCajero: Puede ver mesas, órdenes, detalles de orden, empleados. Puede crear y actualizar órdenes.
GRANT SELECT ON Mesa TO RolCajero;
GRANT SELECT ON Orden TO RolCajero;
GRANT INSERT, UPDATE ON Orden TO RolCajero;
GRANT SELECT ON DetalleOrden TO RolCajero;
GRANT INSERT ON DetalleOrden TO RolCajero;
GRANT SELECT ON Plato TO RolCajero;
GRANT SELECT ON Empleado TO RolCajero;
GRANT EXECUTE ON sp_CrearOrdenConDetalles TO RolCajero;
GRANT EXECUTE ON sp_ActualizarEstadoMesa TO RolCajero; -- Para marcar mesa como libre/ocupada

-- RolChef: Puede ver platos, ingredientes, inventario, estados de pedido, y actualizar estados de pedido.
GRANT SELECT ON Plato TO RolChef;
GRANT SELECT ON Ingrediente TO RolChef;
GRANT SELECT ON Inventario TO RolChef;
GRANT UPDATE ON Inventario TO RolChef;
GRANT SELECT ON EstadoPedido TO RolChef;
GRANT SELECT ON Orden TO RolChef; -- Para ver qué pedidos hay
GRANT UPDATE ON Orden TO RolChef; -- Para cambiar el estado del pedido (ej. a "Preparado", "Completado")
GRANT EXECUTE ON sp_ActualizarInventarioIngrediente TO RolChef;

-- RolAdminRestaurante: Control total (puede ser sysadmin o db_owner, pero mejor crear un rol específico con control granular)
-- Por simplicidad, aquí se le otorgan permisos más amplios sobre las tablas clave.
GRANT SELECT, INSERT, UPDATE, DELETE ON Mesa TO RolAdminRestaurante;
GRANT SELECT, INSERT, UPDATE, DELETE ON Turno TO RolAdminRestaurante;
GRANT SELECT, INSERT, UPDATE, DELETE ON EstadoPedido TO RolAdminRestaurante;
GRANT SELECT, INSERT, UPDATE, DELETE ON CategoriaPlato TO RolAdminRestaurante;
GRANT SELECT, INSERT, UPDATE, DELETE ON Ingrediente TO RolAdminRestaurante;
GRANT SELECT, INSERT, UPDATE, DELETE ON Rol TO RolAdminRestaurante;
GRANT SELECT, INSERT, UPDATE, DELETE ON Plato TO RolAdminRestaurante;
GRANT SELECT, INSERT, UPDATE, DELETE ON Orden TO RolAdminRestaurante;
GRANT SELECT, INSERT, UPDATE, DELETE ON DetalleOrden TO RolAdminRestaurante;
GRANT SELECT, INSERT, UPDATE, DELETE ON PlatoIngrediente TO RolAdminRestaurante;
GRANT SELECT, INSERT, UPDATE, DELETE ON Inventario TO RolAdminRestaurante;
GRANT SELECT, INSERT, UPDATE, DELETE ON Empleado TO RolAdminRestaurante;
GRANT EXECUTE TO RolAdminRestaurante; -- Permitir ejecutar todos los SPs y funciones.

-- 3. Creación de Usuarios y Asignación a Roles 
-- usuario cajero --------------------------------------------
CREATE LOGIN usuario_cajero WITH PASSWORD = '123', CHECK_POLICY = ON;
CREATE USER usuario_cajero FOR LOGIN usuario_cajero;
ALTER ROLE RolCajero ADD MEMBER usuario_cajero;

--  verificar el login
SELECT name, type_desc, is_disabled 
FROM sys.server_principals 
WHERE name = 'usuario_cajero';

-- verificar el usuario
SELECT name, type_desc 
FROM sys.database_principals 
WHERE name = 'usuario_cajero';

-- verificar si el usuario está en rol
SELECT r.name AS Rol, m.name AS Miembro
FROM sys.database_role_members rm
JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
WHERE r.name = 'RolCajero' AND m.name = 'usuario_cajero';

-- usuario_chef ----------------------------------------------------
create login usuario_chef with password='123', CHECK_POLICY=ON;
create user usuario_chef for login usuario_chef;
alter role RolChef add member usuario_chef;
--  verificar el login
SELECT name, type_desc, is_disabled 
FROM sys.server_principals 
WHERE name = 'usuario_chef';
-- verificar el usuario
SELECT name, type_desc 
FROM sys.database_principals 
WHERE name = 'usuario_chef';
-- verificar si el usuario está en rol
SELECT r.name AS Rol, m.name AS Miembro
FROM sys.database_role_members rm
JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
WHERE r.name = 'RolChef' AND m.name = 'usuario_chef';


-- usuario_admin ------------------------------------------------
create login usuario_admin with password='123', check_policy=on;
create user usuario_admin for login usuario_admin;
alter role RolAdminRestaurante add member usuario_admin;
--  verificar el login
SELECT name, type_desc, is_disabled 
FROM sys.server_principals 
WHERE name = 'usuario_admin';
-- verificar el usuario
SELECT name, type_desc 
FROM sys.database_principals 
WHERE name = 'usuario_admin';
-- verificar si el usuario está en rol
SELECT r.name AS Rol, m.name AS Miembro
FROM sys.database_role_members rm
JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
WHERE r.name = 'RolAdminRestaurante' AND m.name = 'usuario_admin';

-- :::::::::::::::::::::::::::::::::::::::::::.

-- 4. Encriptación (Ejemplo de Always Encrypted para datos sensibles como la cédula del empleado) ::::::::::::
-- NOTA: Always Encrypted requiere configuración adicional fuera de este script (Keys, Column Encryption Wizard).
-- Esto es solo una simulación del DDL para una columna encriptada.


--ALTER TABLE Empleado
--ALTER COLUMN cedula
--VARBINARY(256) ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY = [CEK_Auto1],
--ENCRYPTION_TYPE = DETERMINISTIC, ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA256');

-- 5. Validaciones (Manejadas por SPs y Triggers)
-- a) Probar la validación de estado de mesa en tr ValidarMesaOrden
-- Insertar un plato de prueba
EXEC sp_InsertarPlato
    @nombre_plato = 'Plato de Prueba',
    @precio = 10.00,
    @id_categoria = 1;

-- buscar el plato
select id_plato from Plato where nombre_plato= 'Plato de Prueba';
--eliminar
DELETE FROM Plato WHERE id_plato = 509;

-- probar con un plato que se encuentre en una orden
select * from DetalleOrden;
-- eliminar
DELETE FROM Plato WHERE id_plato = 434;
-- verificar si el plato todavía existe
SELECT id_plato, nombre_plato, precio FROM Plato WHERE id_plato = 434;
GO


--  b) Probar la Validación del SP sp_InsertarPlato
SELECT TOP 1 id_categoria, tipo_categoria FROM CategoriaPlato;

-- resultado exitoso
EXEC sp_InsertarPlato
    @nombre_plato = 'Limonada Rosa con hierba buena',
    @precio = 15.75,
    @id_categoria = 2; 

-- resultado fallido
EXEC sp_InsertarPlato
    @nombre_plato = 'Postre Exótico',
    @precio = 22.50,
    @id_categoria = 9999; -- id inexistente


-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.
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

-- 4. Bitácora Centralizada (El log_acciones actúa como una bitácora centralizada para la aplicación)
-- Todas las acciones importantes (INSERT/UPDATE/DELETE en tablas críticas, intentos de acceso fallidos si se implementan triggers a nivel de servidor, etc.)
-- pueden ser registradas en esta tabla para un seguimiento unificado.
-- Consulta para ver todos los registros en tu bitácora centralizada
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
    fecha_accion DESC; 
GO
