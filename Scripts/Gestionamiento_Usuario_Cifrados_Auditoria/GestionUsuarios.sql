-- Gestión de usuarios

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