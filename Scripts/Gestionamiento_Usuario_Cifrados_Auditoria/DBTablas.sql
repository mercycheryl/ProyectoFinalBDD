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