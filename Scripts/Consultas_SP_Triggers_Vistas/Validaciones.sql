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