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