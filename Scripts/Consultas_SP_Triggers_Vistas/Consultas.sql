-- CONSULTAS
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