-- �ndices simples:
-- Mejoran el rendimiento de las consultas que buscan por estas columnas.
CREATE INDEX IX_Mesa_NumeroMesa ON Mesa (numero_mesa);
CREATE INDEX IX_Empleado_Cedula ON Empleado (cedula);
CREATE INDEX IX_Plato_NombrePlato ON Plato (nombre_plato);
CREATE INDEX IX_Ingrediente_Nombre ON Ingrediente (nombre);
CREATE INDEX IX_Orden_Fecha ON Orden (fecha);

-- �ndices compuestos:
-- �tiles para consultas que filtran y/o ordenan por m�ltiples columnas.
CREATE INDEX IX_Orden_EmpleadoMesa ON Orden (id_empleado, id_mesa);
CREATE INDEX IX_DetalleOrden_OrdenPlato ON DetalleOrden (id_orden, id_plato);
CREATE INDEX IX_Plato_CategoriaPrecio ON Plato (id_categoria, precio);