-- =====================================================================
-- BASE DE DATOS: FREXCO
-- Comercializadora de frutas y verduras - Facatativá, Cundinamarca
-- Motor: MySQL 8.x / SQLyog
-- Fuente estructural: Bussiness Frexco.xlsx
-- =====================================================================

DROP DATABASE IF EXISTS frexco;
CREATE DATABASE frexco CHARACTER SET utf8 COLLATE utf8_spanish_ci;
USE frexco;

SET FOREIGN_KEY_CHECKS = 0;

-- =====================================================================
-- 1. TABLAS MAESTRAS
-- =====================================================================

CREATE TABLE categoria (
    ID_Categoria INT PRIMARY KEY,
    Nombre_Categoria VARCHAR(50) NOT NULL,
    Descripcion VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE cliente (
    ID_Cliente INT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Cedula VARCHAR(20),
    Telefono VARCHAR(20),
    Correo VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE empleado (
    ID_Empleado INT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Cedula VARCHAR(20),
    Telefono VARCHAR(20),
    Correo VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE proveedor (
    ID_Proveedor INT PRIMARY KEY,
    Nombre_Proveedor VARCHAR(120) NOT NULL,
    Telefono VARCHAR(20),
    Direccion VARCHAR(150),
    Email VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE producto (
    ID_Producto INT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Unidad_Medida VARCHAR(20),
    Durabilidad_Dias INT,
    ID_Categoria INT NOT NULL,
    CONSTRAINT fk_producto_categoria
        FOREIGN KEY (ID_Categoria) REFERENCES categoria(ID_Categoria)
) ENGINE=InnoDB;

-- =====================================================================
-- 2. VENTAS
-- =====================================================================

CREATE TABLE venta (
    ID_Venta INT PRIMARY KEY,
    Fecha_Venta DATE NOT NULL,
    Total_Venta DECIMAL(14,2) NOT NULL,
    Dia_Semana VARCHAR(15),
    Metodo_Pago VARCHAR(30),
    ID_Cliente INT NOT NULL,
    ID_Empleado INT NOT NULL,
    CONSTRAINT fk_venta_cliente
        FOREIGN KEY (ID_Cliente) REFERENCES cliente(ID_Cliente),
    CONSTRAINT fk_venta_empleado
        FOREIGN KEY (ID_Empleado) REFERENCES empleado(ID_Empleado),
    INDEX idx_venta_fecha (Fecha_Venta),
    INDEX idx_venta_cliente (ID_Cliente),
    INDEX idx_venta_empleado (ID_Empleado),
    INDEX idx_venta_pago (Metodo_Pago)
) ENGINE=InnoDB;

CREATE TABLE detalle_venta (
    ID_DetalleVenta INT PRIMARY KEY,
    Cantidad INT NOT NULL,
    Precio_Unitario DECIMAL(14,2) NOT NULL,
    Subtotal DECIMAL(16,2) NOT NULL,
    ID_Venta INT NOT NULL,
    ID_Producto INT NOT NULL,
    CONSTRAINT fk_detventa_venta
        FOREIGN KEY (ID_Venta) REFERENCES venta(ID_Venta),
    CONSTRAINT fk_detventa_producto
        FOREIGN KEY (ID_Producto) REFERENCES producto(ID_Producto),
    INDEX idx_detventa_venta (ID_Venta),
    INDEX idx_detventa_producto (ID_Producto)
) ENGINE=InnoDB;

-- =====================================================================
-- 3. ABASTECIMIENTO / PROVEEDORES
-- =====================================================================

CREATE TABLE detalle_proveedor (
    ID_DetalleProveedor INT PRIMARY KEY,
    Fecha_Ingreso DATE NOT NULL,
    Cantidad_Recibida INT NOT NULL,
    Precio_Compra DECIMAL(14,2) NOT NULL,
    Fecha_Vencimiento DATE,
    ID_Proveedor INT NOT NULL,
    ID_Producto INT NOT NULL,
    CONSTRAINT fk_detprov_proveedor
        FOREIGN KEY (ID_Proveedor) REFERENCES proveedor(ID_Proveedor),
    CONSTRAINT fk_detprov_producto
        FOREIGN KEY (ID_Producto) REFERENCES producto(ID_Producto),
    INDEX idx_detprov_fecha (Fecha_Ingreso),
    INDEX idx_detprov_proveedor (ID_Proveedor),
    INDEX idx_detprov_producto (ID_Producto)
) ENGINE=InnoDB;

-- =====================================================================
-- 4. DESPERDICIO
-- Nueva estructura:
-- desperdicio = encabezado/registro del evento
-- detalle_desperdicio = productos y cantidades afectadas
-- Relación 1:N entre ambas tablas
-- =====================================================================

CREATE TABLE desperdicio (
    ID_Desperdicio INT PRIMARY KEY,
    Fecha_Registro DATE NOT NULL,
    Dia_Semana VARCHAR(15),
    Total_Desperdicio INT NOT NULL,
    INDEX idx_desperdicio_fecha (Fecha_Registro)
) ENGINE=InnoDB;

CREATE TABLE detalle_desperdicio (
    ID_DetalleDesperdicio INT PRIMARY KEY,
    Cantidad INT NOT NULL,
    Motivo VARCHAR(100) NOT NULL,
    ID_Desperdicio INT NOT NULL,
    ID_Producto INT NOT NULL,
    CONSTRAINT fk_detdesp_desperdicio
        FOREIGN KEY (ID_Desperdicio) REFERENCES desperdicio(ID_Desperdicio),
    CONSTRAINT fk_detdesp_producto
        FOREIGN KEY (ID_Producto) REFERENCES producto(ID_Producto),
    INDEX idx_detdesp_evento (ID_Desperdicio),
    INDEX idx_detdesp_producto (ID_Producto),
    INDEX idx_detdesp_motivo (Motivo)
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;


-- 5. CARGA DE DATOS
-- =====================================================================


-- Datos: categoria (12 registros)
INSERT INTO categoria (`ID_Categoria`, `Nombre_Categoria`, `Descripcion`) VALUES
(1, 'Frutas', 'Frutas frescas de temporada'),
(2, 'Verduras', 'Verduras frescas para consumo diario'),
(3, 'Tuberculos', 'Papa, yuca y similares'),
(4, 'Hierbas', 'Hierbas aromaticas y condimentarias'),
(5, 'Citricos', 'Frutas citricas'),
(6, 'Organicos', 'Productos cultivados sin agroquimicos'),
(7, 'Hortalizas', 'Hortalizas frescas'),
(8, 'Granos', 'Legumbres y granos'),
(9, 'Frutos Secos', 'Nueces y semillas'),
(10, 'Abarrotes', 'Productos complementarios'),
(11, 'Lacteos', 'Lacteos refrigerados'),
(12, 'Bebidas', 'Jugos y bebidas naturales');

-- Datos: cliente (40 registros)
INSERT INTO cliente (`ID_Cliente`, `Nombre`, `Cedula`, `Telefono`, `Correo`) VALUES
(1, 'Camila Gomez', 1099529223, 3073827621, 'camila.gomez@hotmail.com'),
(2, 'Ricardo Garcia', 1098847493, 3027513338, 'ricardo.garcia@gmail.com'),
(3, 'Gloria Alvarez', 1004265799, 3007998630, 'gloria.alvarez@gmail.com'),
(4, 'Sandra Ramirez', 1067827638, 3161603172, 'sandra.ramirez@gmail.com'),
(5, 'Marcela Sanchez', 1096102525, 3174452024, 'marcela.sanchez@yahoo.com'),
(6, 'Ricardo Romero', 1079089901, 3074676249, 'ricardo.romero@gmail.com'),
(7, 'Felipe Silva', 1056722344, 3091335303, 'felipe.silva@outlook.com'),
(8, 'Laura Sanchez', 1045176955, 3027436862, 'laura.sanchez@gmail.com'),
(9, 'David Lopez', 1048181396, 3092329911, 'david.lopez@outlook.com'),
(10, 'Luis Cruz', 1061662963, 3143942632, 'luis.cruz@gmail.com'),
(11, 'David Martinez', 1074093639, 3078699444, 'david.martinez@outlook.com'),
(12, 'Ivan Sanchez', 1094566031, 3018671069, 'ivan.sanchez@gmail.com'),
(13, 'Ricardo Reyes', 1038840994, 3021418995, 'ricardo.reyes@hotmail.com'),
(14, 'Andres Ruiz', 1037308985, 3121711401, 'andres.ruiz@outlook.com'),
(15, 'Felipe Castro', 1047683626, 3056239114, 'felipe.castro@outlook.com'),
(16, 'Ana Herrera', 1085225343, 3045939680, 'ana.herrera@hotmail.com'),
(17, 'Felipe Romero', 1050929647, 3072463567, 'felipe.romero@hotmail.com'),
(18, 'Fernando Castillo', 1007507864, 3061484623, 'fernando.castillo@gmail.com'),
(19, 'Fernando Ruiz', 1035935572, 3017767368, 'fernando.ruiz@hotmail.com'),
(20, 'Ivan Mendoza', 1096356822, 3084470701, 'ivan.mendoza@hotmail.com'),
(21, 'Liliana Ruiz', 1086282117, 3123172106, 'liliana.ruiz@hotmail.com'),
(22, 'Oscar Garcia', 1033101783, 3199981457, 'oscar.garcia@outlook.com'),
(23, 'Gloria Alvarez', 1078320463, 3107213257, 'gloria.alvarez@outlook.com'),
(24, 'Ricardo Garcia', 1068387461, 3132477149, 'ricardo.garcia@gmail.com'),
(25, 'Carlos Gutierrez', 1014716857, 3041028029, 'carlos.gutierrez@hotmail.com'),
(26, 'Carolina Herrera', 1008526544, 3103285188, 'carolina.herrera@yahoo.com'),
(27, 'Freddy Romero', 1071016525, 3067488462, 'freddy.romero@gmail.com'),
(28, 'Camila Ortiz', 1072070937, 3201562225, 'camila.ortiz@outlook.com'),
(29, 'Patricia Lopez', 1039392920, 3116706409, 'patricia.lopez@hotmail.com'),
(30, 'Diana Gomez', 1096917555, 3193187808, 'diana.gomez@outlook.com'),
(31, 'Cristian Reyes', 1023978249, 3136279761, 'cristian.reyes@gmail.com'),
(32, 'Viviana Castillo', 1085758349, 3136274717, 'viviana.castillo@hotmail.com'),
(33, 'Laura Castro', 1021682744, 3144788454, 'laura.castro@gmail.com'),
(34, 'Freddy Vargas', 1065579548, 3005228248, 'freddy.vargas@gmail.com'),
(35, 'Monica Mendoza', 1041273847, 3064277491, 'monica.mendoza@gmail.com'),
(36, 'Natalia Mendoza', 1076149359, 3021141184, 'natalia.mendoza@gmail.com'),
(37, 'Liliana Castillo', 1009289546, 3204172588, 'liliana.castillo@hotmail.com'),
(38, 'Sergio Ortiz', 1063791320, 3147586779, 'sergio.ortiz@hotmail.com'),
(39, 'Oscar Rojas', 1081415657, 3113585225, 'oscar.rojas@hotmail.com'),
(40, 'Hector Reyes', 1097969689, 3185184933, 'hector.reyes@hotmail.com');

-- Datos: empleado (6 registros)
INSERT INTO empleado (`ID_Empleado`, `Nombre`, `Cedula`, `Telefono`, `Correo`) VALUES
(1, 'Viviana Ruiz', 1090152297, 3174450312, 'viviana.ruiz@outlook.com'),
(2, 'Wilson Mendoza', 1069467853, 3121194888, 'wilson.mendoza@gmail.com'),
(3, 'Natalia Ramirez', 1008593410, 3090754153, 'natalia.ramirez@gmail.com'),
(4, 'Gloria Moreno', 1030885476, 3157958191, 'gloria.moreno@hotmail.com'),
(5, 'Maria Martinez', 1095004803, 3169410411, 'maria.martinez@gmail.com'),
(6, 'Ricardo Martinez', 1004216175, 3088698723, 'ricardo.martinez@gmail.com');

-- Datos: proveedor (10 registros)
INSERT INTO proveedor (`ID_Proveedor`, `Nombre_Proveedor`, `Telefono`, `Direccion`, `Email`) VALUES
(1, 'Agro San Vicente', 3172337491, 'Cra. 5 #7-15, Facatativá', 'contacto@agrosanvicente.com'),
(2, 'Aggrofresco', 3105481700, 'Km 2 vía Cartagenita, Facatativá', 'ventas@aggrofresco.com'),
(3, 'Tienda La Placita', 'No encontrado', 'Cra. 1, Facatativá', 'info@laplacita.com'),
(4, 'Fitoplants Natural S.A.S.', 3108547905, 'Cra. 2 Sur #12-57, Facatativá', 'comercial@fitoplantsnatural.com'),
(5, 'Fruitsfull Company S.A.S.', 3103224748, 'Carrera 3 #15-14, Facatativá', 'contacto@fruitsfull.com'),
(6, 'Canasta Fresh S.A.S.', 3208135356, 'Carrera 10 #12-03, Facatativá', 'ventas@canastafresh.com'),
(7, 'Macay Distribuciones S.A.S.', 3223515344, 'Calle 2 #1-61, Facatativá', 'comercial@macay.com'),
(8, 'Comercializadora JR Ramos S.A.S.', 3196128587, 'Facatativá, Cundinamarca', 'ventas@jrramos.com'),
(9, 'AGRODANILO S.A.S.', 3117116379, 'Facatativá, Cundinamarca', 'contacto@agrodanilo.com'),
(10, 'Agroinsumos San Miguel S.A.S.', 3142475368, 'Carrera 1 #8-52, Facatativá', 'servicio@sanmiguelsas.com');

-- Datos: producto (20 registros)
INSERT INTO producto (`ID_Producto`, `Nombre`, `Unidad_Medida`, `Durabilidad_Dias`, `ID_Categoria`) VALUES
(1, 'Banano', 'Libra', 17, 7),
(2, 'Manzana Roja', 'Kg', 9, 9),
(3, 'Pera', 'Kg', 24, 12),
(4, 'Naranja', 'Unidad', 14, 4),
(5, 'Mandarina', 'Atado', 9, 9),
(6, 'Mango', 'Libra', 10, 12),
(7, 'Papaya', 'Libra', 8, 12),
(8, 'Piña', 'Unidad', 25, 7),
(9, 'Fresa', 'Unidad', 14, 2),
(10, 'Uva', 'Kg', 13, 3),
(11, 'Tomate', 'Libra', 30, 7),
(12, 'Cebolla', 'Atado', 27, 8),
(13, 'Papa', 'Kg', 27, 5),
(14, 'Yuca', 'Libra', 26, 6),
(15, 'Zanahoria', 'Libra', 11, 1),
(16, 'Lechuga', 'Libra', 16, 5),
(17, 'Espinaca', 'Kg', 15, 10),
(18, 'Cilantro', 'Unidad', 18, 7),
(19, 'Pimenton', 'Unidad', 14, 6),
(20, 'Pepino', 'Atado', 6, 5);

-- Datos: venta (200 registros)
INSERT INTO venta (`ID_Venta`, `Fecha_Venta`, `Total_Venta`, `Dia_Semana`, `Metodo_Pago`, `ID_Cliente`, `ID_Empleado`) VALUES
(1, '2026-01-08', 65900, 'Domingo', 'Daviplata/Nequi', 39, 6),
(2, '2026-09-01', 192878, 'Viernes', 'Daviplata/Nequi', 33, 3),
(3, '2026-08-29', 230886, 'Martes', 'Daviplata/Nequi', 8, 6),
(4, '2026-05-29', 47225, 'Sábado', 'Efectivo', 24, 2),
(5, '2026-03-24', 59038, 'Martes', 'Tarjeta Crédito', 32, 4),
(6, '2026-02-17', 234270, 'Sábado', 'Efectivo', 26, 1),
(7, '2026-03-27', 98718, 'Domingo', 'Tarjeta Crédito', 11, 1),
(8, '2026-08-02', 40408, 'Lunes', 'Efectivo', 32, 6),
(9, '2026-08-01', 38653, 'Viernes', 'Tarjeta Crédito', 29, 4),
(10, '2026-01-23', 202944, 'Domingo', 'Daviplata/Nequi', 20, 6),
(11, '2026-08-29', 159875, 'Viernes', 'Tarjeta Crédito', 10, 4),
(12, '2026-07-08', 276529, 'Miércoles', 'Daviplata/Nequi', 23, 4),
(13, '2026-05-12', 121409, 'Viernes', 'Efectivo', 21, 1),
(14, '2026-08-22', 155016, 'Sábado', 'Daviplata/Nequi', 22, 1),
(15, '2026-07-16', 90801, 'Lunes', 'Tarjeta Débito', 21, 3),
(16, '2026-07-13', 143234, 'Miércoles', 'Efectivo', 26, 1),
(17, '2026-02-11', 125778, 'Sábado', 'Tarjeta Débito', 13, 6),
(18, '2026-04-23', 103063, 'Sábado', 'Efectivo', 1, 6),
(19, '2026-03-08', 159147, 'Domingo', 'Efectivo', 19, 3),
(20, '2026-09-18', 108922, 'Lunes', 'Tarjeta Débito', 24, 1),
(21, '2026-03-01', 237183, 'Miércoles', 'Efectivo', 26, 4),
(22, '2026-02-04', 84675, 'Domingo', 'Efectivo', 38, 1),
(23, '2026-03-30', 114096, 'Lunes', 'Efectivo', 24, 4),
(24, '2026-04-23', 135699, 'Domingo', 'Efectivo', 18, 1),
(25, '2026-06-03', 252851, 'Viernes', 'Daviplata/Nequi', 18, 1),
(26, '2026-08-02', 136484, 'Jueves', 'Efectivo', 4, 6),
(27, '2026-04-28', 69853, 'Jueves', 'Efectivo', 19, 6),
(28, '2026-05-17', 213509, 'Lunes', 'Daviplata/Nequi', 10, 2),
(29, '2026-02-11', 86784, 'Martes', 'Daviplata/Nequi', 18, 4),
(30, '2026-06-26', 191041, 'Sábado', 'Efectivo', 33, 3),
(31, '2026-04-03', 215973, 'Domingo', 'Daviplata/Nequi', 13, 3),
(32, '2026-07-04', 31210, 'Jueves', 'Tarjeta Crédito', 28, 1),
(33, '2026-06-27', 157800, 'Viernes', 'Efectivo', 26, 5),
(34, '2026-02-21', 269111, 'Domingo', 'Tarjeta Crédito', 36, 2),
(35, '2026-04-04', 236304, 'Domingo', 'Tarjeta Crédito', 6, 1),
(36, '2026-03-03', 167543, 'Miércoles', 'Daviplata/Nequi', 27, 4),
(37, '2026-06-29', 96291, 'Miércoles', 'Tarjeta Débito', 40, 2),
(38, '2026-07-24', 250392, 'Lunes', 'Tarjeta Crédito', 19, 4),
(39, '2026-08-14', 183663, 'Sábado', 'Tarjeta Crédito', 4, 5),
(40, '2026-07-13', 235086, 'Jueves', 'Tarjeta Crédito', 9, 2),
(41, '2026-04-10', 53956, 'Lunes', 'Efectivo', 31, 4),
(42, '2026-03-25', 107796, 'Martes', 'Efectivo', 22, 3),
(43, '2026-08-01', 135937, 'Sábado', 'Tarjeta Crédito', 20, 3),
(44, '2026-09-07', 177057, 'Lunes', 'Tarjeta Crédito', 17, 4),
(45, '2026-04-20', 139035, 'Domingo', 'Efectivo', 16, 3),
(46, '2026-01-01', 155573, 'Lunes', 'Tarjeta Crédito', 31, 5),
(47, '2026-06-26', 96140, 'Domingo', 'Daviplata/Nequi', 26, 1),
(48, '2026-04-05', 227310, 'Sábado', 'Efectivo', 11, 6),
(49, '2026-08-25', 174035, 'Domingo', 'Tarjeta Crédito', 11, 1),
(50, '2026-02-20', 49310, 'Viernes', 'Tarjeta Crédito', 14, 5),
(51, '2026-06-12', 110911, 'Lunes', 'Tarjeta Crédito', 32, 5),
(52, '2026-08-01', 113643, 'Sábado', 'Tarjeta Crédito', 15, 4),
(53, '2026-02-24', 210889, 'Miércoles', 'Efectivo', 22, 4),
(54, '2026-03-02', 63528, 'Sábado', 'Efectivo', 28, 2),
(55, '2026-03-02', 177287, 'Lunes', 'Tarjeta Débito', 36, 2),
(56, '2026-03-04', 189075, 'Sábado', 'Daviplata/Nequi', 16, 1),
(57, '2026-01-18', 96757, 'Sábado', 'Daviplata/Nequi', 12, 3),
(58, '2026-08-30', 163837, 'Domingo', 'Tarjeta Débito', 36, 1),
(59, '2026-07-19', 36393, 'Domingo', 'Daviplata/Nequi', 21, 2),
(60, '2026-08-21', 142796, 'Domingo', 'Tarjeta Débito', 24, 3),
(61, '2026-01-04', 84458, 'Sábado', 'Efectivo', 37, 2),
(62, '2026-07-06', 160869, 'Sábado', 'Tarjeta Débito', 2, 6),
(63, '2026-01-02', 172945, 'Lunes', 'Efectivo', 27, 4),
(64, '2026-07-19', 184913, 'Miércoles', 'Efectivo', 27, 6),
(65, '2026-02-25', 106414, 'Martes', 'Efectivo', 34, 2),
(66, '2026-01-11', 179616, 'Jueves', 'Efectivo', 25, 3),
(67, '2026-05-01', 167521, 'Lunes', 'Efectivo', 22, 1),
(68, '2026-05-19', 198489, 'Martes', 'Tarjeta Débito', 32, 3),
(69, '2026-01-09', 157662, 'Sábado', 'Efectivo', 37, 3),
(70, '2026-01-07', 279011, 'Sábado', 'Efectivo', 9, 6),
(71, '2026-06-17', 249848, 'Viernes', 'Tarjeta Crédito', 33, 5),
(72, '2026-03-03', 28319, 'Jueves', 'Tarjeta Crédito', 14, 1),
(73, '2026-03-07', 180474, 'Miércoles', 'Efectivo', 18, 2),
(74, '2026-04-18', 245986, 'Domingo', 'Tarjeta Débito', 25, 4),
(75, '2026-05-24', 18634, 'Lunes', 'Efectivo', 29, 4),
(76, '2026-04-29', 49510, 'Sábado', 'Tarjeta Débito', 20, 1),
(77, '2026-04-24', 207394, 'Jueves', 'Tarjeta Débito', 9, 1),
(78, '2026-08-05', 118455, 'Viernes', 'Efectivo', 28, 6),
(79, '2026-06-21', 53385, 'Martes', 'Tarjeta Débito', 31, 5),
(80, '2026-09-05', 270346, 'Martes', 'Efectivo', 32, 1),
(81, '2026-01-20', 114388, 'Viernes', 'Tarjeta Crédito', 5, 4),
(82, '2026-04-15', 267172, 'Jueves', 'Daviplata/Nequi', 34, 4),
(83, '2026-08-13', 62214, 'Sábado', 'Tarjeta Crédito', 29, 2),
(84, '2026-01-14', 178307, 'Sábado', 'Efectivo', 7, 2),
(85, '2026-06-12', 192664, 'Sábado', 'Daviplata/Nequi', 10, 2),
(86, '2026-07-14', 78021, 'Lunes', 'Tarjeta Débito', 34, 6),
(87, '2026-01-20', 122133, 'Domingo', 'Efectivo', 7, 6),
(88, '2026-06-15', 42299, 'Domingo', 'Tarjeta Débito', 30, 1),
(89, '2026-09-02', 76172, 'Martes', 'Tarjeta Crédito', 36, 1),
(90, '2026-01-13', 257880, 'Domingo', 'Efectivo', 1, 2),
(91, '2026-02-02', 139456, 'Jueves', 'Efectivo', 15, 5),
(92, '2026-01-20', 172095, 'Sábado', 'Efectivo', 3, 6),
(93, '2026-05-02', 117286, 'Viernes', 'Efectivo', 20, 2),
(94, '2026-03-20', 103400, 'Viernes', 'Tarjeta Crédito', 17, 5),
(95, '2026-09-01', 231239, 'Jueves', 'Efectivo', 28, 6),
(96, '2026-01-03', 104960, 'Lunes', 'Tarjeta Débito', 8, 1),
(97, '2026-03-31', 183353, 'Viernes', 'Efectivo', 5, 3),
(98, '2026-08-10', 101428, 'Viernes', 'Tarjeta Crédito', 34, 5),
(99, '2026-03-08', 210220, 'Miércoles', 'Efectivo', 13, 4),
(100, '2026-03-27', 210214, 'Domingo', 'Tarjeta Débito', 17, 2);
INSERT INTO venta (`ID_Venta`, `Fecha_Venta`, `Total_Venta`, `Dia_Semana`, `Metodo_Pago`, `ID_Cliente`, `ID_Empleado`) VALUES
(101, '2026-04-06', 121547, 'Martes', 'Efectivo', 39, 1),
(102, '2026-07-13', 129854, 'Viernes', 'Tarjeta Débito', 1, 5),
(103, '2026-04-22', 232472, 'Jueves', 'Tarjeta Crédito', 20, 4),
(104, '2026-08-05', 167462, 'Lunes', 'Tarjeta Débito', 18, 3),
(105, '2026-08-15', 20886, 'Viernes', 'Tarjeta Crédito', 16, 4),
(106, '2026-06-01', 25611, 'Lunes', 'Tarjeta Crédito', 34, 2),
(107, '2026-09-14', 70512, 'Viernes', 'Efectivo', 36, 2),
(108, '2026-05-03', 147170, 'Domingo', 'Efectivo', 2, 4),
(109, '2026-02-07', 232839, 'Lunes', 'Efectivo', 20, 1),
(110, '2026-04-25', 77132, 'Miércoles', 'Efectivo', 2, 2),
(111, '2026-01-01', 183986, 'Martes', 'Efectivo', 32, 6),
(112, '2026-02-23', 168265, 'Viernes', 'Efectivo', 27, 1),
(113, '2026-02-10', 57779, 'Jueves', 'Tarjeta Débito', 17, 2),
(114, '2026-02-14', 197710, 'Viernes', 'Efectivo', 28, 3),
(115, '2026-08-01', 258037, 'Sábado', 'Efectivo', 15, 4),
(116, '2026-07-13', 47550, 'Sábado', 'Efectivo', 3, 6),
(117, '2026-08-18', 254353, 'Viernes', 'Efectivo', 22, 6),
(118, '2026-01-07', 160382, 'Viernes', 'Tarjeta Crédito', 27, 3),
(119, '2026-04-02', 219671, 'Martes', 'Tarjeta Débito', 26, 2),
(120, '2026-07-19', 225577, 'Sábado', 'Efectivo', 1, 3),
(121, '2026-06-22', 279720, 'Martes', 'Efectivo', 33, 1),
(122, '2026-02-03', 20968, 'Miércoles', 'Efectivo', 14, 4),
(123, '2026-09-09', 98613, 'Martes', 'Efectivo', 13, 3),
(124, '2026-04-15', 151988, 'Miércoles', 'Efectivo', 13, 2),
(125, '2026-08-02', 216404, 'Domingo', 'Tarjeta Débito', 30, 2),
(126, '2026-01-22', 95088, 'Domingo', 'Daviplata/Nequi', 17, 3),
(127, '2026-05-13', 67819, 'Viernes', 'Daviplata/Nequi', 7, 5),
(128, '2026-01-19', 61465, 'Jueves', 'Efectivo', 32, 5),
(129, '2026-05-02', 251459, 'Martes', 'Efectivo', 12, 2),
(130, '2026-05-03', 151525, 'Jueves', 'Daviplata/Nequi', 32, 4),
(131, '2026-03-22', 251539, 'Domingo', 'Tarjeta Débito', 4, 5),
(132, '2026-07-25', 245416, 'Domingo', 'Daviplata/Nequi', 10, 4),
(133, '2026-07-04', 121411, 'Domingo', 'Tarjeta Débito', 4, 2),
(134, '2026-04-02', 75783, 'Domingo', 'Daviplata/Nequi', 2, 5),
(135, '2026-01-12', 140072, 'Miércoles', 'Efectivo', 10, 4),
(136, '2026-06-14', 43725, 'Lunes', 'Efectivo', 4, 6),
(137, '2026-09-05', 169025, 'Viernes', 'Efectivo', 4, 2),
(138, '2026-05-02', 255078, 'Viernes', 'Daviplata/Nequi', 26, 4),
(139, '2026-02-16', 149735, 'Viernes', 'Efectivo', 21, 6),
(140, '2026-01-31', 276367, 'Martes', 'Tarjeta Débito', 8, 1),
(141, '2026-07-14', 105057, 'Jueves', 'Efectivo', 11, 3),
(142, '2026-08-14', 85973, 'Miércoles', 'Daviplata/Nequi', 13, 2),
(143, '2026-06-15', 90878, 'Martes', 'Daviplata/Nequi', 34, 6),
(144, '2026-08-03', 35040, 'Sábado', 'Efectivo', 30, 1),
(145, '2026-02-25', 198708, 'Jueves', 'Efectivo', 20, 6),
(146, '2026-03-16', 113405, 'Viernes', 'Efectivo', 25, 3),
(147, '2026-04-15', 271761, 'Viernes', 'Efectivo', 22, 4),
(148, '2026-05-04', 175671, 'Domingo', 'Daviplata/Nequi', 11, 1),
(149, '2026-04-26', 279871, 'Miércoles', 'Efectivo', 1, 1),
(150, '2026-03-21', 182728, 'Domingo', 'Tarjeta Crédito', 18, 1),
(151, '2026-06-08', 96007, 'Viernes', 'Daviplata/Nequi', 23, 4),
(152, '2026-04-02', 174350, 'Miércoles', 'Efectivo', 8, 5),
(153, '2026-07-01', 124125, 'Jueves', 'Efectivo', 14, 4),
(154, '2026-09-10', 87370, 'Domingo', 'Efectivo', 23, 3),
(155, '2026-02-18', 29548, 'Martes', 'Tarjeta Débito', 28, 1),
(156, '2026-06-09', 32035, 'Sábado', 'Tarjeta Crédito', 4, 6),
(157, '2026-06-09', 264190, 'Domingo', 'Efectivo', 31, 2),
(158, '2026-03-02', 135855, 'Viernes', 'Efectivo', 24, 5),
(159, '2026-05-21', 267048, 'Domingo', 'Efectivo', 29, 2),
(160, '2026-03-24', 163518, 'Jueves', 'Tarjeta Débito', 21, 3),
(161, '2026-05-01', 213138, 'Jueves', 'Efectivo', 31, 1),
(162, '2026-08-28', 200048, 'Lunes', 'Daviplata/Nequi', 27, 2),
(163, '2026-02-04', 243132, 'Sábado', 'Daviplata/Nequi', 26, 1),
(164, '2026-03-29', 231887, 'Miércoles', 'Efectivo', 25, 1),
(165, '2026-06-15', 105968, 'Miércoles', 'Efectivo', 30, 1),
(166, '2026-03-22', 30006, 'Viernes', 'Tarjeta Crédito', 4, 3),
(167, '2026-06-10', 189095, 'Domingo', 'Efectivo', 13, 6),
(168, '2026-02-04', 209106, 'Sábado', 'Efectivo', 5, 5),
(169, '2026-04-03', 22675, 'Domingo', 'Efectivo', 22, 3),
(170, '2026-09-09', 204618, 'Sábado', 'Tarjeta Débito', 18, 3),
(171, '2026-07-16', 99810, 'Viernes', 'Tarjeta Crédito', 40, 1),
(172, '2026-06-14', 143817, 'Miércoles', 'Tarjeta Crédito', 17, 6),
(173, '2026-09-13', 38299, 'Sábado', 'Efectivo', 21, 3),
(174, '2026-02-03', 177487, 'Martes', 'Efectivo', 20, 1),
(175, '2026-04-29', 86696, 'Viernes', 'Daviplata/Nequi', 39, 6),
(176, '2026-01-12', 85957, 'Martes', 'Tarjeta Débito', 5, 1),
(177, '2026-04-30', 37617, 'Lunes', 'Efectivo', 15, 1),
(178, '2026-09-14', 272768, 'Miércoles', 'Daviplata/Nequi', 31, 6),
(179, '2026-06-22', 47962, 'Jueves', 'Efectivo', 30, 4),
(180, '2026-07-22', 207808, 'Jueves', 'Tarjeta Débito', 17, 4),
(181, '2026-07-29', 47740, 'Martes', 'Efectivo', 32, 2),
(182, '2026-06-23', 197605, 'Lunes', 'Tarjeta Débito', 32, 2),
(183, '2026-03-12', 85782, 'Jueves', 'Tarjeta Débito', 1, 6),
(184, '2026-01-06', 29856, 'Lunes', 'Tarjeta Débito', 20, 6),
(185, '2026-07-12', 279378, 'Sábado', 'Tarjeta Crédito', 10, 5),
(186, '2026-07-10', 81268, 'Lunes', 'Efectivo', 16, 3),
(187, '2026-09-04', 64484, 'Lunes', 'Tarjeta Crédito', 21, 4),
(188, '2026-06-21', 264008, 'Martes', 'Daviplata/Nequi', 24, 5),
(189, '2026-08-26', 57457, 'Jueves', 'Tarjeta Débito', 6, 5),
(190, '2026-05-14', 71266, 'Lunes', 'Tarjeta Débito', 13, 4),
(191, '2026-02-28', 114750, 'Lunes', 'Tarjeta Débito', 11, 2),
(192, '2026-09-11', 67488, 'Martes', 'Tarjeta Crédito', 27, 1),
(193, '2026-03-02', 161606, 'Lunes', 'Efectivo', 3, 4),
(194, '2026-07-31', 136414, 'Sábado', 'Daviplata/Nequi', 36, 5),
(195, '2026-08-14', 18115, 'Sábado', 'Efectivo', 21, 2),
(196, '2026-01-10', 45248, 'Martes', 'Daviplata/Nequi', 28, 1),
(197, '2026-01-01', 203544, 'Martes', 'Efectivo', 5, 3),
(198, '2026-02-07', 139437, 'Martes', 'Efectivo', 40, 1),
(199, '2026-02-06', 39886, 'Domingo', 'Daviplata/Nequi', 14, 1),
(200, '2026-07-20', 258934, 'Miércoles', 'Efectivo', 27, 4);

-- Datos: detalle_venta (309 registros) -- CORREGIDO: cobertura 100% de ventas, subtotales cuadrados
INSERT INTO detalle_venta (`ID_DetalleVenta`, `Cantidad`, `Precio_Unitario`, `Subtotal`, `ID_Venta`, `ID_Producto`) VALUES
(1, 10, 6590, 65900, 1, 7),
(2, 2, 96439, 192878, 2, 8),
(3, 1, 65838, 65838, 3, 13),
(4, 13, 12696, 165048, 3, 17),
(5, 1, 47225, 47225, 4, 20),
(6, 2, 25832, 51664, 5, 12),
(7, 2, 3687, 7374, 5, 13),
(8, 19, 12330, 234270, 6, 6),
(9, 1, 98718, 98718, 7, 17),
(10, 1, 40408, 40408, 8, 13),
(11, 1, 38653, 38653, 9, 1),
(12, 2, 101472, 202944, 10, 18),
(13, 5, 31975, 159875, 11, 7),
(14, 9, 7523, 67707, 12, 7),
(15, 2, 59870, 119740, 12, 6),
(16, 3, 29694, 89082, 12, 15),
(17, 1, 121409, 121409, 13, 1),
(18, 2, 77508, 155016, 14, 14),
(19, 5, 2255, 11275, 15, 5),
(20, 5, 14313, 71565, 15, 10),
(21, 1, 7961, 7961, 15, 1),
(22, 1, 143234, 143234, 16, 7),
(23, 6, 9677, 58062, 17, 9),
(24, 3, 22572, 67716, 17, 18),
(25, 1, 103063, 103063, 18, 16),
(26, 9, 17683, 159147, 19, 20),
(27, 1, 108922, 108922, 20, 14),
(28, 3, 79061, 237183, 21, 5),
(29, 15, 5645, 84675, 22, 6),
(30, 8, 14262, 114096, 23, 7),
(31, 2, 30659, 61318, 24, 9),
(32, 1, 74381, 74381, 24, 4),
(33, 4, 32849, 131396, 25, 10),
(34, 1, 121455, 121455, 25, 1),
(35, 2, 68242, 136484, 26, 13),
(36, 7, 9979, 69853, 27, 13),
(37, 1, 213509, 213509, 28, 12),
(38, 8, 10848, 86784, 29, 2),
(39, 2, 52243, 104486, 30, 15),
(40, 7, 12365, 86555, 30, 8),
(41, 1, 215973, 215973, 31, 10),
(42, 19, 1243, 23617, 32, 11),
(43, 1, 7593, 7593, 32, 7),
(44, 2, 78900, 157800, 33, 15),
(45, 1, 220783, 220783, 34, 9),
(46, 14, 3452, 48328, 34, 3),
(47, 1, 206623, 206623, 35, 16),
(48, 1, 29681, 29681, 35, 18),
(49, 1, 167543, 167543, 36, 10),
(50, 2, 10448, 20896, 37, 10),
(51, 5, 11838, 59190, 37, 13),
(52, 5, 3241, 16205, 37, 15),
(53, 20, 4527, 90540, 38, 1),
(54, 6, 26642, 159852, 38, 12),
(55, 1, 50667, 50667, 39, 6),
(56, 11, 11242, 123662, 39, 9),
(57, 2, 4667, 9334, 39, 14),
(58, 1, 949, 949, 40, 4),
(59, 1, 234137, 234137, 40, 17),
(60, 14, 3854, 53956, 41, 6),
(61, 9, 6468, 58212, 42, 7),
(62, 16, 3099, 49584, 42, 9),
(63, 1, 75368, 75368, 43, 7),
(64, 1, 60569, 60569, 43, 1),
(65, 1, 177057, 177057, 44, 2),
(66, 15, 9269, 139035, 45, 12),
(67, 2, 77072, 154144, 46, 19),
(68, 1, 1429, 1429, 46, 10),
(69, 5, 10346, 51730, 47, 6),
(70, 2, 248, 496, 47, 9),
(71, 2, 21957, 43914, 47, 15),
(72, 19, 9584, 182096, 48, 13),
(73, 3, 13595, 40785, 48, 14),
(74, 1, 4429, 4429, 48, 18),
(75, 5, 34807, 174035, 49, 9),
(76, 11, 4169, 45859, 50, 13),
(77, 17, 203, 3451, 50, 6),
(78, 1, 62437, 62437, 51, 6),
(79, 6, 8079, 48474, 51, 3),
(80, 3, 37881, 113643, 52, 4),
(81, 1, 18913, 18913, 53, 11),
(82, 1, 191976, 191976, 53, 1),
(83, 2, 13564, 27128, 54, 9),
(84, 16, 2275, 36400, 54, 6),
(85, 1, 9475, 9475, 55, 2),
(86, 11, 8606, 94666, 55, 11),
(87, 2, 36573, 73146, 55, 17),
(88, 1, 15076, 15076, 56, 14),
(89, 1, 173999, 173999, 56, 8),
(90, 1, 96757, 96757, 57, 9),
(91, 20, 926, 18520, 58, 18),
(92, 1, 145317, 145317, 58, 7),
(93, 1, 35059, 35059, 59, 3),
(94, 1, 1334, 1334, 59, 4),
(95, 1, 142796, 142796, 60, 3),
(96, 1, 49709, 49709, 61, 6),
(97, 13, 2673, 34749, 61, 12),
(98, 1, 160193, 160193, 62, 6),
(99, 4, 169, 676, 62, 11),
(100, 1, 114331, 114331, 63, 7);
INSERT INTO detalle_venta (`ID_DetalleVenta`, `Cantidad`, `Precio_Unitario`, `Subtotal`, `ID_Venta`, `ID_Producto`) VALUES
(101, 1, 58614, 58614, 63, 10),
(102, 1, 184913, 184913, 64, 17),
(103, 2, 53207, 106414, 65, 4),
(104, 1, 157931, 157931, 66, 3),
(105, 5, 4337, 21685, 66, 6),
(106, 1, 167521, 167521, 67, 11),
(107, 1, 5343, 5343, 68, 10),
(108, 1, 193146, 193146, 68, 6),
(109, 1, 145753, 145753, 69, 10),
(110, 1, 11909, 11909, 69, 20),
(111, 1, 279011, 279011, 70, 3),
(112, 4, 62462, 249848, 71, 20),
(113, 2, 10879, 21758, 72, 11),
(114, 3, 2187, 6561, 72, 2),
(115, 9, 15961, 143649, 73, 5),
(116, 15, 2455, 36825, 73, 1),
(117, 1, 245986, 245986, 74, 8),
(118, 2, 9317, 18634, 75, 2),
(119, 2, 24755, 49510, 76, 9),
(120, 1, 24631, 24631, 77, 14),
(121, 3, 60921, 182763, 77, 1),
(122, 5, 23691, 118455, 78, 6),
(123, 3, 17795, 53385, 79, 9),
(124, 18, 12543, 225774, 80, 5),
(125, 1, 44572, 44572, 80, 1),
(126, 1, 114388, 114388, 81, 15),
(127, 4, 66793, 267172, 82, 8),
(128, 1, 62214, 62214, 83, 16),
(129, 1, 178307, 178307, 84, 6),
(130, 2, 63523, 127046, 85, 7),
(131, 2, 32809, 65618, 85, 4),
(132, 5, 3529, 17645, 86, 16),
(133, 1, 5107, 5107, 86, 8),
(134, 9, 6141, 55269, 86, 6),
(135, 11, 11103, 122133, 87, 17),
(136, 1, 42299, 42299, 88, 8),
(137, 1, 55181, 55181, 89, 13),
(138, 1, 20991, 20991, 89, 17),
(139, 6, 42980, 257880, 90, 19),
(140, 1, 139456, 139456, 91, 4),
(141, 2, 8147, 16294, 92, 11),
(142, 2, 49100, 98200, 92, 7),
(143, 1, 57601, 57601, 92, 2),
(144, 1, 33413, 33413, 93, 1),
(145, 2, 27325, 54650, 93, 19),
(146, 9, 3247, 29223, 93, 17),
(147, 11, 9400, 103400, 94, 12),
(148, 1, 231239, 231239, 95, 10),
(149, 1, 104960, 104960, 96, 2),
(150, 1, 183353, 183353, 97, 5),
(151, 2, 24877, 49754, 98, 1),
(152, 14, 3691, 51674, 98, 12),
(153, 1, 210220, 210220, 99, 5),
(154, 1, 210214, 210214, 100, 6),
(155, 1, 121547, 121547, 101, 20),
(156, 1, 9236, 9236, 102, 1),
(157, 18, 6701, 120618, 102, 14),
(158, 8, 29059, 232472, 103, 12),
(159, 2, 83731, 167462, 104, 13),
(160, 1, 20886, 20886, 105, 12),
(161, 1, 25611, 25611, 106, 8),
(162, 7, 4114, 28798, 107, 11),
(163, 1, 6207, 6207, 107, 4),
(164, 1, 35507, 35507, 107, 9),
(165, 1, 147170, 147170, 108, 15),
(166, 1, 68662, 68662, 109, 3),
(167, 1, 164177, 164177, 109, 13),
(168, 11, 7012, 77132, 110, 15),
(169, 1, 84122, 84122, 111, 17),
(170, 6, 16644, 99864, 111, 8),
(171, 1, 168265, 168265, 112, 7),
(172, 8, 2292, 18336, 113, 15),
(173, 1, 39443, 39443, 113, 16),
(174, 13, 959, 12467, 114, 19),
(175, 1, 185243, 185243, 114, 3),
(176, 6, 8405, 50430, 115, 14),
(177, 1, 207607, 207607, 115, 19),
(178, 2, 23775, 47550, 116, 11),
(179, 1, 254353, 254353, 117, 4),
(180, 2, 24007, 48014, 118, 5),
(181, 1, 27191, 27191, 118, 10),
(182, 19, 4483, 85177, 118, 6),
(183, 1, 197069, 197069, 119, 14),
(184, 1, 22602, 22602, 119, 13),
(185, 11, 20507, 225577, 120, 17),
(186, 15, 18648, 279720, 121, 6),
(187, 1, 20968, 20968, 122, 4),
(188, 2, 4577, 9154, 123, 9),
(189, 1, 89459, 89459, 123, 16),
(190, 5, 25394, 126970, 124, 7),
(191, 14, 1787, 25018, 124, 17),
(192, 4, 54101, 216404, 125, 9),
(193, 3, 31696, 95088, 126, 10),
(194, 1, 67819, 67819, 127, 17),
(195, 1, 15071, 15071, 128, 20),
(196, 1, 46394, 46394, 128, 12),
(197, 1, 204828, 204828, 129, 5),
(198, 13, 3587, 46631, 129, 19),
(199, 1, 104740, 104740, 130, 19),
(200, 15, 3119, 46785, 130, 3);
INSERT INTO detalle_venta (`ID_DetalleVenta`, `Cantidad`, `Precio_Unitario`, `Subtotal`, `ID_Venta`, `ID_Producto`) VALUES
(201, 1, 251539, 251539, 131, 15),
(202, 1, 245416, 245416, 132, 7),
(203, 1, 39154, 39154, 133, 7),
(204, 7, 11751, 82257, 133, 4),
(205, 1, 75783, 75783, 134, 10),
(206, 9, 5533, 49797, 135, 3),
(207, 1, 90275, 90275, 135, 4),
(208, 1, 14288, 14288, 136, 13),
(209, 1, 5227, 5227, 136, 11),
(210, 6, 4035, 24210, 136, 17),
(211, 5, 33805, 169025, 137, 20),
(212, 1, 255078, 255078, 138, 5),
(213, 8, 18131, 145048, 139, 8),
(214, 1, 4687, 4687, 139, 7),
(215, 1, 92613, 92613, 140, 17),
(216, 1, 89604, 89604, 140, 18),
(217, 10, 9415, 94150, 140, 10),
(218, 1, 20031, 20031, 141, 5),
(219, 1, 85026, 85026, 141, 14),
(220, 1, 85973, 85973, 142, 18),
(221, 1, 22674, 22674, 143, 18),
(222, 4, 17051, 68204, 143, 11),
(223, 8, 4380, 35040, 144, 11),
(224, 1, 198708, 198708, 145, 6),
(225, 5, 22681, 113405, 146, 3),
(226, 7, 38823, 271761, 147, 18),
(227, 9, 19519, 175671, 148, 19),
(228, 2, 98915, 197830, 149, 9),
(229, 3, 27347, 82041, 149, 4),
(230, 13, 14056, 182728, 150, 9),
(231, 19, 5053, 96007, 151, 1),
(232, 2, 87175, 174350, 152, 19),
(233, 13, 6094, 79222, 153, 10),
(234, 1, 44903, 44903, 153, 9),
(235, 5, 17474, 87370, 154, 5),
(236, 4, 5419, 21676, 155, 1),
(237, 13, 307, 3991, 155, 18),
(238, 1, 3881, 3881, 155, 17),
(239, 1, 32035, 32035, 156, 17),
(240, 10, 26419, 264190, 157, 14),
(241, 1, 135855, 135855, 158, 12),
(242, 2, 59893, 119786, 159, 16),
(243, 2, 73631, 147262, 159, 3),
(244, 1, 163518, 163518, 160, 17),
(245, 3, 71046, 213138, 161, 3),
(246, 1, 33807, 33807, 162, 12),
(247, 1, 166241, 166241, 162, 18),
(248, 12, 20261, 243132, 163, 7),
(249, 3, 1363, 4089, 164, 15),
(250, 2, 113899, 227798, 164, 7),
(251, 2, 205, 410, 165, 7),
(252, 2, 52779, 105558, 165, 2),
(253, 5, 1209, 6045, 166, 5),
(254, 14, 578, 8092, 166, 18),
(255, 1, 15869, 15869, 166, 15),
(256, 1, 8552, 8552, 167, 10),
(257, 11, 16413, 180543, 167, 2),
(258, 3, 69702, 209106, 168, 13),
(259, 1, 4463, 4463, 169, 10),
(260, 1, 11865, 11865, 169, 19),
(261, 11, 577, 6347, 169, 12),
(262, 1, 97753, 97753, 170, 18),
(263, 11, 9715, 106865, 170, 7),
(264, 6, 16635, 99810, 171, 17),
(265, 3, 47939, 143817, 172, 3),
(266, 1, 17057, 17057, 173, 20),
(267, 1, 21242, 21242, 173, 10),
(268, 1, 7949, 7949, 174, 9),
(269, 1, 169538, 169538, 174, 8),
(270, 4, 21674, 86696, 175, 8),
(271, 1, 85957, 85957, 176, 13),
(272, 3, 12539, 37617, 177, 9),
(273, 3, 1057, 3171, 178, 5),
(274, 1, 269597, 269597, 178, 18),
(275, 2, 23981, 47962, 179, 16),
(276, 2, 23245, 46490, 180, 11),
(277, 1, 161318, 161318, 180, 19),
(278, 4, 11935, 47740, 181, 18),
(279, 1, 122446, 122446, 182, 7),
(280, 9, 8351, 75159, 182, 17),
(281, 1, 55513, 55513, 183, 11),
(282, 1, 14214, 14214, 183, 20),
(283, 5, 3211, 16055, 183, 7),
(284, 14, 579, 8106, 184, 13),
(285, 3, 5587, 16761, 184, 6),
(286, 1, 4989, 4989, 184, 8),
(287, 1, 279378, 279378, 185, 6),
(288, 1, 11293, 11293, 186, 16),
(289, 5, 13995, 69975, 186, 13),
(290, 1, 64484, 64484, 187, 17),
(291, 10, 22474, 224740, 188, 11),
(292, 1, 3093, 3093, 188, 9),
(293, 5, 7235, 36175, 188, 6),
(294, 1, 45293, 45293, 189, 5),
(295, 2, 6082, 12164, 189, 16),
(296, 2, 35633, 71266, 190, 17),
(297, 15, 2621, 39315, 191, 18),
(298, 1, 75435, 75435, 191, 15),
(299, 4, 16872, 67488, 192, 15),
(300, 1, 161606, 161606, 193, 16);
INSERT INTO detalle_venta (`ID_DetalleVenta`, `Cantidad`, `Precio_Unitario`, `Subtotal`, `ID_Venta`, `ID_Producto`) VALUES
(301, 1, 136414, 136414, 194, 11),
(302, 2, 2071, 4142, 195, 4),
(303, 1, 13973, 13973, 195, 18),
(304, 14, 3232, 45248, 196, 19),
(305, 6, 33924, 203544, 197, 8),
(306, 1, 139437, 139437, 198, 2),
(307, 7, 365, 2555, 199, 7),
(308, 1, 37331, 37331, 199, 8),
(309, 1, 258934, 258934, 200, 1);

-- Datos: detalle_proveedor (100 registros)
INSERT INTO detalle_proveedor (`ID_DetalleProveedor`, `Fecha_Ingreso`, `Cantidad_Recibida`, `Precio_Compra`, `Fecha_Vencimiento`, `ID_Proveedor`, `ID_Producto`) VALUES
(1, '2026-04-27', 342, 351855, '2026-05-08', 6, 5),
(2, '2026-05-05', 348, 1182783, '2026-06-06', 7, 2),
(3, '2026-03-03', 277, 75686, '2026-03-31', 2, 18),
(4, '2026-02-28', 184, 877769, '2026-03-24', 2, 12),
(5, '2026-04-07', 284, 1074151, '2026-05-12', 10, 2),
(6, '2026-05-01', 378, 732352, '2026-05-25', 9, 7),
(7, '2026-04-09', 189, 312078, '2026-05-02', 1, 3),
(8, '2026-03-27', 391, 990006, '2026-04-17', 7, 14),
(9, '2026-06-22', 263, 749264, '2026-07-26', 2, 8),
(10, '2026-01-11', 422, 146385, '2026-01-25', 2, 18),
(11, '2026-03-15', 256, 382797, '2026-03-26', 7, 2),
(12, '2026-03-29', 154, 462578, '2026-04-27', 10, 4),
(13, '2026-08-16', 114, 718366, '2026-09-22', 4, 19),
(14, '2026-04-04', 238, 878600, '2026-04-21', 1, 19),
(15, '2026-06-23', 323, 275451, '2026-06-30', 10, 13),
(16, '2026-03-25', 403, 282932, '2026-04-25', 1, 8),
(17, '2026-01-04', 312, 1035916, '2026-01-20', 1, 18),
(18, '2026-07-15', 394, 339343, '2026-07-23', 3, 10),
(19, '2026-02-09', 373, 1094114, '2026-03-13', 7, 5),
(20, '2026-08-23', 373, 365178, '2026-09-22', 9, 4),
(21, '2026-06-11', 328, 52066, '2026-06-26', 10, 10),
(22, '2026-02-03', 28, 469645, '2026-02-18', 9, 6),
(23, '2026-02-21', 490, 867450, '2026-03-13', 2, 19),
(24, '2026-05-19', 73, 372736, '2026-05-31', 10, 7),
(25, '2026-07-28', 110, 1050387, '2026-09-05', 6, 4),
(26, '2026-01-20', 65, 1077791, '2026-02-17', 9, 3),
(27, '2026-07-09', 211, 550891, '2026-08-02', 10, 2),
(28, '2026-03-22', 280, 609978, '2026-04-21', 10, 7),
(29, '2026-01-09', 112, 450288, '2026-02-02', 8, 18),
(30, '2026-03-06', 60, 524913, '2026-03-15', 7, 11),
(31, '2026-08-04', 98, 975043, '2026-08-25', 8, 19),
(32, '2026-01-15', 30, 912170, '2026-02-20', 8, 12),
(33, '2026-01-25', 445, 805393, '2026-02-11', 5, 8),
(34, '2026-01-18', 266, 949288, '2026-02-23', 3, 8),
(35, '2026-04-10', 70, 166308, '2026-04-27', 2, 19),
(36, '2026-05-01', 406, 205043, '2026-05-30', 5, 17),
(37, '2026-03-18', 431, 867494, '2026-03-29', 8, 11),
(38, '2026-06-03', 84, 1017693, '2026-06-16', 8, 10),
(39, '2026-01-24', 262, 229403, '2026-03-05', 10, 3),
(40, '2026-08-26', 464, 1149605, '2026-09-16', 2, 17),
(41, '2026-06-22', 173, 203718, '2026-07-13', 7, 6),
(42, '2026-03-01', 355, 808752, '2026-03-28', 6, 5),
(43, '2026-06-05', 199, 135400, '2026-06-13', 8, 14),
(44, '2026-08-21', 216, 633125, '2026-09-17', 1, 3),
(45, '2026-02-03', 76, 338795, '2026-03-08', 9, 19),
(46, '2026-02-11', 370, 94855, '2026-02-18', 6, 11),
(47, '2026-01-15', 275, 1007128, '2026-01-23', 6, 20),
(48, '2026-03-23', 325, 1197968, '2026-04-24', 8, 19),
(49, '2026-05-30', 365, 246020, '2026-06-21', 8, 3),
(50, '2026-07-06', 394, 1182912, '2026-08-06', 2, 9),
(51, '2026-06-28', 323, 1021865, '2026-08-02', 8, 3),
(52, '2026-02-07', 143, 632183, '2026-02-15', 1, 10),
(53, '2026-03-28', 401, 1089179, '2026-04-22', 10, 15),
(54, '2026-05-10', 398, 281986, '2026-06-18', 5, 13),
(55, '2026-02-13', 226, 272879, '2026-02-26', 6, 1),
(56, '2026-04-14', 255, 302547, '2026-04-29', 8, 12),
(57, '2026-02-07', 365, 507127, '2026-02-20', 3, 20),
(58, '2026-06-03', 61, 235978, '2026-06-19', 2, 16),
(59, '2026-04-23', 339, 956242, '2026-05-23', 1, 7),
(60, '2026-01-08', 213, 1149025, '2026-02-10', 5, 5),
(61, '2026-07-31', 215, 272912, '2026-08-19', 4, 13),
(62, '2026-06-13', 327, 401187, '2026-07-14', 7, 16),
(63, '2026-01-19', 24, 1092901, '2026-01-27', 2, 6),
(64, '2026-06-02', 236, 73365, '2026-06-19', 8, 13),
(65, '2026-07-06', 496, 525338, '2026-07-27', 9, 9),
(66, '2026-04-07', 267, 1075428, '2026-05-17', 3, 14),
(67, '2026-08-20', 216, 778149, '2026-09-17', 9, 9),
(68, '2026-08-06', 282, 613888, '2026-08-17', 7, 12),
(69, '2026-04-24', 84, 151439, '2026-06-02', 7, 8),
(70, '2026-02-09', 154, 831624, '2026-03-08', 3, 3),
(71, '2026-03-19', 165, 750383, '2026-04-01', 3, 5),
(72, '2026-08-24', 230, 871792, '2026-09-22', 4, 8),
(73, '2026-04-18', 485, 915203, '2026-05-03', 1, 16),
(74, '2026-07-16', 264, 450170, '2026-07-26', 10, 6),
(75, '2026-01-23', 179, 923952, '2026-03-02', 5, 10),
(76, '2026-06-06', 63, 892447, '2026-07-08', 1, 5),
(77, '2026-07-01', 176, 1157535, '2026-07-23', 7, 18),
(78, '2026-05-19', 306, 156167, '2026-06-17', 6, 20),
(79, '2026-03-21', 432, 221408, '2026-04-07', 10, 11),
(80, '2026-03-07', 69, 1036580, '2026-03-17', 3, 17),
(81, '2026-01-08', 390, 201810, '2026-02-12', 10, 2),
(82, '2026-07-08', 448, 825037, '2026-08-17', 8, 18),
(83, '2026-04-02', 348, 475936, '2026-05-05', 7, 13),
(84, '2026-05-08', 196, 1033310, '2026-06-10', 7, 13),
(85, '2026-02-19', 81, 112212, '2026-03-21', 2, 16),
(86, '2026-05-11', 424, 716101, '2026-05-27', 7, 2),
(87, '2026-06-26', 113, 885798, '2026-07-09', 4, 3),
(88, '2026-08-27', 20, 394481, '2026-09-26', 4, 15),
(89, '2026-02-07', 209, 978124, '2026-02-20', 3, 4),
(90, '2026-04-23', 286, 71311, '2026-05-09', 6, 20),
(91, '2026-01-01', 81, 221106, '2026-01-11', 1, 4),
(92, '2026-04-25', 476, 730022, '2026-05-08', 1, 19),
(93, '2026-04-06', 403, 690257, '2026-05-06', 3, 18),
(94, '2026-05-08', 247, 581286, '2026-05-20', 2, 12),
(95, '2026-08-03', 434, 357591, '2026-09-02', 10, 1),
(96, '2026-04-01', 64, 314707, '2026-05-07', 2, 7),
(97, '2026-03-14', 59, 105836, '2026-04-14', 10, 13),
(98, '2026-07-07', 56, 1188474, '2026-07-31', 3, 9),
(99, '2026-05-14', 64, 774330, '2026-06-19', 6, 20),
(100, '2026-03-02', 262, 804024, '2026-03-18', 6, 16);

-- Datos: desperdicio (93 registros)
INSERT INTO desperdicio (`ID_Desperdicio`, `Fecha_Registro`, `Dia_Semana`, `Total_Desperdicio`) VALUES
(1, '2026-01-01', 'Jueves', 17),
(2, '2026-01-02', 'Viernes', 18),
(3, '2026-01-04', 'Domingo', 23),
(4, '2026-01-06', 'Martes', 14),
(5, '2026-01-08', 'Jueves', 25),
(6, '2026-01-09', 'Viernes', 2),
(7, '2026-01-12', 'Lunes', 19),
(8, '2026-01-17', 'Sábado', 8),
(9, '2026-01-18', 'Domingo', 46),
(10, '2026-01-22', 'Jueves', 10),
(11, '2026-01-24', 'Sábado', 19),
(12, '2026-01-25', 'Domingo', 17),
(13, '2026-01-26', 'Lunes', 10),
(14, '2026-01-29', 'Jueves', 24),
(15, '2026-01-31', 'Sábado', 2),
(16, '2026-02-06', 'Viernes', 15),
(17, '2026-02-07', 'Sábado', 8),
(18, '2026-02-08', 'Domingo', 11),
(19, '2026-02-09', 'Lunes', 23),
(20, '2026-02-10', 'Martes', 22),
(21, '2026-02-12', 'Jueves', 31),
(22, '2026-02-14', 'Sábado', 22),
(23, '2026-02-17', 'Martes', 20),
(24, '2026-02-18', 'Miércoles', 1),
(25, '2026-02-23', 'Lunes', 8),
(26, '2026-02-25', 'Miércoles', 42),
(27, '2026-02-26', 'Jueves', 9),
(28, '2026-02-27', 'Viernes', 2),
(29, '2026-03-01', 'Domingo', 16),
(30, '2026-03-02', 'Lunes', 20),
(31, '2026-03-09', 'Lunes', 20),
(32, '2026-03-10', 'Martes', 18),
(33, '2026-03-12', 'Jueves', 18),
(34, '2026-03-16', 'Lunes', 14),
(35, '2026-03-23', 'Lunes', 9),
(36, '2026-03-29', 'Domingo', 11),
(37, '2026-03-30', 'Lunes', 21),
(38, '2026-04-09', 'Jueves', 21),
(39, '2026-04-11', 'Sábado', 9),
(40, '2026-04-20', 'Lunes', 9),
(41, '2026-04-21', 'Martes', 24),
(42, '2026-04-24', 'Viernes', 15),
(43, '2026-04-28', 'Martes', 18),
(44, '2026-04-30', 'Jueves', 32),
(45, '2026-05-06', 'Miércoles', 20),
(46, '2026-05-07', 'Jueves', 11),
(47, '2026-05-11', 'Lunes', 60),
(48, '2026-05-14', 'Jueves', 27),
(49, '2026-05-15', 'Viernes', 2),
(50, '2026-05-19', 'Martes', 4),
(51, '2026-05-23', 'Sábado', 16),
(52, '2026-05-26', 'Martes', 23),
(53, '2026-05-27', 'Miércoles', 13),
(54, '2026-05-28', 'Jueves', 5),
(55, '2026-05-31', 'Domingo', 11),
(56, '2026-06-02', 'Martes', 3),
(57, '2026-06-03', 'Miércoles', 18),
(58, '2026-06-05', 'Viernes', 11),
(59, '2026-06-06', 'Sábado', 24),
(60, '2026-06-10', 'Miércoles', 20),
(61, '2026-06-11', 'Jueves', 16),
(62, '2026-06-14', 'Domingo', 14),
(63, '2026-06-15', 'Lunes', 3),
(64, '2026-06-16', 'Martes', 19),
(65, '2026-07-02', 'Jueves', 21),
(66, '2026-07-04', 'Sábado', 22),
(67, '2026-07-07', 'Martes', 20),
(68, '2026-07-11', 'Sábado', 20),
(69, '2026-07-12', 'Domingo', 24),
(70, '2026-07-15', 'Miércoles', 15),
(71, '2026-07-17', 'Viernes', 13),
(72, '2026-07-19', 'Domingo', 19),
(73, '2026-07-20', 'Lunes', 14),
(74, '2026-07-21', 'Martes', 1),
(75, '2026-07-24', 'Viernes', 10),
(76, '2026-08-04', 'Martes', 12),
(77, '2026-08-07', 'Viernes', 37),
(78, '2026-08-10', 'Lunes', 17),
(79, '2026-08-12', 'Miércoles', 8),
(80, '2026-08-14', 'Viernes', 12),
(81, '2026-08-17', 'Lunes', 19),
(82, '2026-08-19', 'Miércoles', 17),
(83, '2026-08-21', 'Viernes', 9),
(84, '2026-08-26', 'Miércoles', 9),
(85, '2026-08-29', 'Sábado', 33),
(86, '2026-08-31', 'Lunes', 24),
(87, '2026-09-05', 'Sábado', 6),
(88, '2026-09-11', 'Viernes', 5),
(89, '2026-09-12', 'Sábado', 21),
(90, '2026-09-15', 'Martes', 32),
(91, '2026-09-16', 'Miércoles', 26),
(92, '2026-09-17', 'Jueves', 1),
(93, '2026-09-18', 'Viernes', 7);

-- Datos: detalle_desperdicio (119 registros)
INSERT INTO detalle_desperdicio (`ID_DetalleDesperdicio`, `Cantidad`, `Motivo`, `ID_Desperdicio`, `ID_Producto`) VALUES
(1, 24, 'Maduracion excesiva', 69, 3),
(2, 6, 'Golpe durante transporte', 41, 5),
(3, 23, 'Manipulacion inadecuada', 3, 13),
(4, 15, 'Deterioro por humedad', 85, 19),
(5, 2, 'Manipulacion inadecuada', 15, 2),
(6, 10, 'Maduracion excesiva', 13, 13),
(7, 24, 'Golpe durante transporte', 59, 1),
(8, 9, 'Maduracion excesiva', 27, 10),
(9, 21, 'Maduracion excesiva', 89, 10),
(10, 17, 'Vencimiento', 78, 8),
(11, 16, 'Manipulacion inadecuada', 91, 3),
(12, 9, 'Golpe durante transporte', 83, 19),
(13, 16, 'Vencimiento', 61, 17),
(14, 5, 'Vencimiento', 53, 5),
(15, 20, 'Vencimiento', 21, 20),
(16, 1, 'Maduracion excesiva', 41, 13),
(17, 18, 'Golpe durante transporte', 2, 11),
(18, 24, 'Golpe durante transporte', 77, 16),
(19, 4, 'Golpe durante transporte', 50, 5),
(20, 14, 'Vencimiento', 34, 10),
(21, 12, 'Deterioro por humedad', 80, 20),
(22, 18, 'Manipulacion inadecuada', 9, 5),
(23, 10, 'Vencimiento', 91, 2),
(24, 14, 'Golpe durante transporte', 38, 17),
(25, 12, 'Deterioro por humedad', 68, 14),
(26, 1, 'Golpe durante transporte', 74, 17),
(27, 5, 'Deterioro por humedad', 8, 5),
(28, 5, 'Maduracion excesiva', 54, 17),
(29, 20, 'Manipulacion inadecuada', 45, 17),
(30, 13, 'Deterioro por humedad', 47, 19),
(31, 1, 'Vencimiento', 67, 1),
(32, 16, 'Vencimiento', 29, 19),
(33, 11, 'Maduracion excesiva', 16, 8),
(34, 12, 'Manipulacion inadecuada', 76, 3),
(35, 21, 'Maduracion excesiva', 90, 1),
(36, 12, 'Golpe durante transporte', 32, 2),
(37, 20, 'Maduracion excesiva', 23, 5),
(38, 9, 'Manipulacion inadecuada', 10, 12),
(39, 8, 'Manipulacion inadecuada', 68, 4),
(40, 7, 'Maduracion excesiva', 38, 13),
(41, 1, 'Manipulacion inadecuada', 92, 15),
(42, 8, 'Deterioro por humedad', 17, 18),
(43, 6, 'Vencimiento', 32, 2),
(44, 11, 'Deterioro por humedad', 36, 1),
(45, 18, 'Vencimiento', 26, 18),
(46, 15, 'Golpe durante transporte', 9, 8),
(47, 23, 'Golpe durante transporte', 47, 16),
(48, 22, 'Manipulacion inadecuada', 66, 9),
(49, 21, 'Vencimiento', 37, 1),
(50, 20, 'Deterioro por humedad', 31, 15),
(51, 13, 'Golpe durante transporte', 9, 3),
(52, 9, 'Deterioro por humedad', 84, 17),
(53, 1, 'Vencimiento', 10, 18),
(54, 3, 'Deterioro por humedad', 8, 3),
(55, 11, 'Deterioro por humedad', 55, 17),
(56, 17, 'Vencimiento', 1, 3),
(57, 7, 'Vencimiento', 41, 16),
(58, 17, 'Vencimiento', 82, 9),
(59, 8, 'Maduracion excesiva', 53, 3),
(60, 21, 'Maduracion excesiva', 65, 9),
(61, 20, 'Maduracion excesiva', 60, 8),
(62, 2, 'Maduracion excesiva', 28, 7),
(63, 19, 'Vencimiento', 11, 8),
(64, 18, 'Deterioro por humedad', 57, 15),
(65, 18, 'Vencimiento', 33, 16),
(66, 2, 'Golpe durante transporte', 48, 13),
(67, 3, 'Vencimiento', 56, 3),
(68, 19, 'Golpe durante transporte', 72, 16),
(69, 10, 'Deterioro por humedad', 41, 10),
(70, 15, 'Vencimiento', 42, 2),
(71, 12, 'Golpe durante transporte', 47, 20),
(72, 11, 'Manipulacion inadecuada', 58, 7),
(73, 9, 'Deterioro por humedad', 40, 3),
(74, 22, 'Golpe durante transporte', 20, 20),
(75, 2, 'Maduracion excesiva', 49, 5),
(76, 9, 'Maduracion excesiva', 35, 11),
(77, 18, 'Golpe durante transporte', 85, 9),
(78, 4, 'Maduracion excesiva', 62, 10),
(79, 8, 'Manipulacion inadecuada', 79, 20),
(80, 19, 'Deterioro por humedad', 7, 19),
(81, 20, 'Golpe durante transporte', 30, 5),
(82, 23, 'Maduracion excesiva', 19, 1),
(83, 22, 'Golpe durante transporte', 22, 16),
(84, 11, 'Manipulacion inadecuada', 18, 2),
(85, 14, 'Golpe durante transporte', 4, 16),
(86, 2, 'Maduracion excesiva', 6, 9),
(87, 19, 'Vencimiento', 67, 4),
(88, 1, 'Golpe durante transporte', 44, 7),
(89, 4, 'Golpe durante transporte', 16, 16),
(90, 23, 'Vencimiento', 52, 10),
(91, 19, 'Vencimiento', 64, 17),
(92, 13, 'Manipulacion inadecuada', 77, 10),
(93, 12, 'Golpe durante transporte', 47, 15),
(94, 8, 'Maduracion excesiva', 25, 15),
(95, 9, 'Vencimiento', 39, 15),
(96, 25, 'Manipulacion inadecuada', 48, 4),
(97, 7, 'Vencimiento', 93, 18),
(98, 6, 'Golpe durante transporte', 87, 7),
(99, 10, 'Vencimiento', 62, 10),
(100, 1, 'Deterioro por humedad', 24, 3);
INSERT INTO detalle_desperdicio (`ID_DetalleDesperdicio`, `Cantidad`, `Motivo`, `ID_Desperdicio`, `ID_Producto`) VALUES
(101, 25, 'Deterioro por humedad', 5, 16),
(102, 15, 'Golpe durante transporte', 70, 1),
(103, 24, 'Golpe durante transporte', 14, 10),
(104, 16, 'Manipulacion inadecuada', 51, 15),
(105, 11, 'Maduracion excesiva', 21, 3),
(106, 14, 'Maduracion excesiva', 73, 17),
(107, 19, 'Maduracion excesiva', 81, 15),
(108, 10, 'Golpe durante transporte', 75, 9),
(109, 11, 'Deterioro por humedad', 46, 13),
(110, 17, 'Maduracion excesiva', 44, 7),
(111, 3, 'Deterioro por humedad', 63, 7),
(112, 5, 'Deterioro por humedad', 88, 3),
(113, 13, 'Manipulacion inadecuada', 71, 19),
(114, 24, 'Deterioro por humedad', 26, 3),
(115, 24, 'Maduracion excesiva', 86, 5),
(116, 17, 'Golpe durante transporte', 12, 17),
(117, 14, 'Manipulacion inadecuada', 44, 9),
(118, 18, 'Manipulacion inadecuada', 43, 12),
(119, 11, 'Vencimiento', 90, 5);

-- =====================================================================
-- 6. VISTAS DE APOYO PARA ANALISIS
-- =====================================================================

CREATE OR REPLACE VIEW vw_ventas_detalladas AS
SELECT
    v.ID_Venta,
    v.Fecha_Venta,
    YEAR(v.Fecha_Venta) AS Anio,
    MONTH(v.Fecha_Venta) AS Mes,
    v.Dia_Semana,
    v.Metodo_Pago,
    c.ID_Cliente,
    c.Nombre AS Cliente,
    e.ID_Empleado,
    e.Nombre AS Empleado,
    dv.ID_DetalleVenta,
    p.ID_Producto,
    p.Nombre AS Producto,
    cat.ID_Categoria,
    cat.Nombre_Categoria AS Categoria,
    dv.Cantidad,
    dv.Precio_Unitario,
    dv.Subtotal
FROM venta v
JOIN cliente c ON c.ID_Cliente = v.ID_Cliente
JOIN empleado e ON e.ID_Empleado = v.ID_Empleado
JOIN detalle_venta dv ON dv.ID_Venta = v.ID_Venta
JOIN producto p ON p.ID_Producto = dv.ID_Producto
JOIN categoria cat ON cat.ID_Categoria = p.ID_Categoria;

CREATE OR REPLACE VIEW vw_desperdicio_detallado AS
SELECT
    d.ID_Desperdicio,
    d.Fecha_Registro,
    YEAR(d.Fecha_Registro) AS Anio,
    MONTH(d.Fecha_Registro) AS Mes,
    d.Dia_Semana,
    d.Total_Desperdicio,
    dd.ID_DetalleDesperdicio,
    dd.Cantidad,
    dd.Motivo,
    p.ID_Producto,
    p.Nombre AS Producto,
    cat.ID_Categoria,
    cat.Nombre_Categoria AS Categoria
FROM desperdicio d
JOIN detalle_desperdicio dd ON dd.ID_Desperdicio = d.ID_Desperdicio
JOIN producto p ON p.ID_Producto = dd.ID_Producto
JOIN categoria cat ON cat.ID_Categoria = p.ID_Categoria;

-- =====================================================================
-- 7. CONSULTAS DE ANALISIS DE NEGOCIO
-- =====================================================================

-- 1. Ventas totales, promedio por venta y número de transacciones.
SELECT
    COUNT(*) AS Numero_Ventas,
    SUM(Total_Venta) AS Ventas_Totales,
    AVG(Total_Venta) AS Ticket_Promedio,
    MIN(Total_Venta) AS Venta_Minima,
    MAX(Total_Venta) AS Venta_Maxima
FROM venta;

-- 2. Ventas por mes.
SELECT
    YEAR(Fecha_Venta) AS Anio,
    MONTH(Fecha_Venta) AS Mes,
    COUNT(*) AS Numero_Ventas,
    SUM(Total_Venta) AS Ventas_Totales,
    AVG(Total_Venta) AS Ticket_Promedio
FROM venta
GROUP BY YEAR(Fecha_Venta), MONTH(Fecha_Venta)
ORDER BY Anio, Mes;

-- 3. Ventas por metodo de pago.
SELECT
    Metodo_Pago,
    COUNT(*) AS Numero_Ventas,
    SUM(Total_Venta) AS Ventas_Totales,
    AVG(Total_Venta) AS Ticket_Promedio,
    ROUND(100 * SUM(Total_Venta) / (SELECT SUM(Total_Venta) FROM venta), 2) AS Porcentaje_Ventas
FROM venta
GROUP BY Metodo_Pago
ORDER BY Ventas_Totales DESC;

-- 4. Ventas por cliente.
SELECT
    c.ID_Cliente,
    c.Nombre,
    COUNT(v.ID_Venta) AS Numero_Compras,
    SUM(v.Total_Venta) AS Valor_Compras,
    AVG(v.Total_Venta) AS Ticket_Promedio
FROM cliente c
LEFT JOIN venta v ON v.ID_Cliente = c.ID_Cliente
GROUP BY c.ID_Cliente, c.Nombre
ORDER BY Valor_Compras DESC;

-- 5. Clientes que no han realizado compras.
SELECT
    c.ID_Cliente,
    c.Nombre,
    c.Correo
FROM cliente c
LEFT JOIN venta v ON v.ID_Cliente = c.ID_Cliente
WHERE v.ID_Venta IS NULL;

-- 6. Ventas atendidas por empleado.
SELECT
    e.ID_Empleado,
    e.Nombre,
    COUNT(v.ID_Venta) AS Numero_Ventas,
    SUM(v.Total_Venta) AS Ventas_Generadas,
    AVG(v.Total_Venta) AS Ticket_Promedio
FROM empleado e
LEFT JOIN venta v ON v.ID_Empleado = e.ID_Empleado
GROUP BY e.ID_Empleado, e.Nombre
ORDER BY Ventas_Generadas DESC;

-- 7. Ventas por dia de la semana registrado.
SELECT
    Dia_Semana,
    COUNT(*) AS Numero_Ventas,
    SUM(Total_Venta) AS Ventas_Totales,
    AVG(Total_Venta) AS Ticket_Promedio
FROM venta
GROUP BY Dia_Semana
ORDER BY Ventas_Totales DESC;

-- 8. Productos mas vendidos por cantidad.
SELECT
    p.ID_Producto,
    p.Nombre AS Producto,
    cat.Nombre_Categoria AS Categoria,
    SUM(dv.Cantidad) AS Unidades_Vendidas,
    SUM(dv.Subtotal) AS Venta_Detallada
FROM detalle_venta dv
JOIN producto p ON p.ID_Producto = dv.ID_Producto
JOIN categoria cat ON cat.ID_Categoria = p.ID_Categoria
GROUP BY p.ID_Producto, p.Nombre, cat.Nombre_Categoria
ORDER BY Unidades_Vendidas DESC;

-- 9. Categorias con mayor volumen de ventas.
SELECT
    cat.ID_Categoria,
    cat.Nombre_Categoria,
    SUM(dv.Cantidad) AS Unidades_Vendidas,
    SUM(dv.Subtotal) AS Ventas_Detalladas
FROM detalle_venta dv
JOIN producto p ON p.ID_Producto = dv.ID_Producto
JOIN categoria cat ON cat.ID_Categoria = p.ID_Categoria
GROUP BY cat.ID_Categoria, cat.Nombre_Categoria
ORDER BY Ventas_Detalladas DESC;

-- 10. Productos que no registran ventas.
SELECT
    p.ID_Producto,
    p.Nombre,
    cat.Nombre_Categoria AS Categoria
FROM producto p
JOIN categoria cat ON cat.ID_Categoria = p.ID_Categoria
LEFT JOIN detalle_venta dv ON dv.ID_Producto = p.ID_Producto
WHERE dv.ID_DetalleVenta IS NULL;

-- 11. Compras/abastecimiento por proveedor.
SELECT
    pr.ID_Proveedor,
    pr.Nombre_Proveedor,
    COUNT(dp.ID_DetalleProveedor) AS Recepciones,
    SUM(dp.Cantidad_Recibida) AS Unidades_Recibidas,
    SUM(dp.Precio_Compra) AS Valor_Compras_Registrado,
    AVG(dp.Precio_Compra) AS Compra_Promedio
FROM proveedor pr
LEFT JOIN detalle_proveedor dp ON dp.ID_Proveedor = pr.ID_Proveedor
GROUP BY pr.ID_Proveedor, pr.Nombre_Proveedor
ORDER BY Valor_Compras_Registrado DESC;

-- 12. Productos con mayor cantidad recibida de proveedores.
SELECT
    p.ID_Producto,
    p.Nombre AS Producto,
    SUM(dp.Cantidad_Recibida) AS Cantidad_Recibida,
    AVG(dp.Precio_Compra) AS Precio_Compra_Promedio
FROM detalle_proveedor dp
JOIN producto p ON p.ID_Producto = dp.ID_Producto
GROUP BY p.ID_Producto, p.Nombre
ORDER BY Cantidad_Recibida DESC;

-- 13. Registros de abastecimiento próximos a vencer (30 dias desde una fecha de referencia).
SELECT
    dp.ID_DetalleProveedor,
    p.Nombre AS Producto,
    pr.Nombre_Proveedor,
    dp.Cantidad_Recibida,
    dp.Fecha_Ingreso,
    dp.Fecha_Vencimiento,
    DATEDIFF(dp.Fecha_Vencimiento, dp.Fecha_Ingreso) AS Dias_De_Vida_Registrados
FROM detalle_proveedor dp
JOIN producto p ON p.ID_Producto = dp.ID_Producto
JOIN proveedor pr ON pr.ID_Proveedor = dp.ID_Proveedor
WHERE dp.Fecha_Vencimiento IS NOT NULL
ORDER BY dp.Fecha_Vencimiento ASC;

-- 14. Desperdicio total por producto.
SELECT
    p.ID_Producto,
    p.Nombre AS Producto,
    SUM(dd.Cantidad) AS Unidades_Desperdiciadas,
    COUNT(DISTINCT dd.ID_Desperdicio) AS Eventos_Desperdicio
FROM detalle_desperdicio dd
JOIN producto p ON p.ID_Producto = dd.ID_Producto
GROUP BY p.ID_Producto, p.Nombre
ORDER BY Unidades_Desperdiciadas DESC;

-- 15. Desperdicio por motivo.
SELECT
    Motivo,
    COUNT(*) AS Registros,
    SUM(Cantidad) AS Cantidad_Desperdiciada,
    ROUND(100 * SUM(Cantidad) /
          (SELECT SUM(Cantidad) FROM detalle_desperdicio), 2) AS Porcentaje
FROM detalle_desperdicio
GROUP BY Motivo
ORDER BY Cantidad_Desperdiciada DESC;

-- 16. Desperdicio por categoria.
SELECT
    cat.Nombre_Categoria AS Categoria,
    SUM(dd.Cantidad) AS Cantidad_Desperdiciada,
    COUNT(DISTINCT dd.ID_Desperdicio) AS Eventos
FROM detalle_desperdicio dd
JOIN producto p ON p.ID_Producto = dd.ID_Producto
JOIN categoria cat ON cat.ID_Categoria = p.ID_Categoria
GROUP BY cat.Nombre_Categoria
ORDER BY Cantidad_Desperdiciada DESC;

-- 17. Desperdicio por mes.
SELECT
    YEAR(d.Fecha_Registro) AS Anio,
    MONTH(d.Fecha_Registro) AS Mes,
    SUM(dd.Cantidad) AS Cantidad_Desperdiciada,
    COUNT(DISTINCT d.ID_Desperdicio) AS Eventos
FROM desperdicio d
JOIN detalle_desperdicio dd ON dd.ID_Desperdicio = d.ID_Desperdicio
GROUP BY YEAR(d.Fecha_Registro), MONTH(d.Fecha_Registro)
ORDER BY Anio, Mes;

-- 18. Relacion entre ventas y desperdicio por mes.
SELECT
    x.Anio,
    x.Mes,
    x.Ventas_Totales,
    COALESCE(y.Desperdicio_Unidades, 0) AS Desperdicio_Unidades
FROM (
    SELECT YEAR(Fecha_Venta) AS Anio, MONTH(Fecha_Venta) AS Mes,
           SUM(Total_Venta) AS Ventas_Totales
    FROM venta
    GROUP BY YEAR(Fecha_Venta), MONTH(Fecha_Venta)
) x
LEFT JOIN (
    SELECT YEAR(d.Fecha_Registro) AS Anio, MONTH(d.Fecha_Registro) AS Mes,
           SUM(dd.Cantidad) AS Desperdicio_Unidades
    FROM desperdicio d
    JOIN detalle_desperdicio dd ON dd.ID_Desperdicio = d.ID_Desperdicio
    GROUP BY YEAR(d.Fecha_Registro), MONTH(d.Fecha_Registro)
) y ON y.Anio = x.Anio AND y.Mes = x.Mes
ORDER BY x.Anio, x.Mes;

-- 19. Productos con alta venta y alto desperdicio.
SELECT
    p.ID_Producto,
    p.Nombre,
    COALESCE(v.Unidades_Vendidas,0) AS Unidades_Vendidas,
    COALESCE(w.Unidades_Desperdiciadas,0) AS Unidades_Desperdiciadas,
    CASE
        WHEN COALESCE(v.Unidades_Vendidas,0) > 0
        THEN ROUND(100 * COALESCE(w.Unidades_Desperdiciadas,0) /
                   v.Unidades_Vendidas, 2)
        ELSE NULL
    END AS Desperdicio_Sobre_Ventas_Porcentaje
FROM producto p
LEFT JOIN (
    SELECT ID_Producto, SUM(Cantidad) AS Unidades_Vendidas
    FROM detalle_venta
    GROUP BY ID_Producto
) v ON v.ID_Producto = p.ID_Producto
LEFT JOIN (
    SELECT ID_Producto, SUM(Cantidad) AS Unidades_Desperdiciadas
    FROM detalle_desperdicio
    GROUP BY ID_Producto
) w ON w.ID_Producto = p.ID_Producto
ORDER BY Desperdicio_Sobre_Ventas_Porcentaje DESC;

-- 20. Motivos de desperdicio por producto.
SELECT
    p.Nombre AS Producto,
    dd.Motivo,
    SUM(dd.Cantidad) AS Cantidad_Desperdiciada
FROM detalle_desperdicio dd
JOIN producto p ON p.ID_Producto = dd.ID_Producto
GROUP BY p.Nombre, dd.Motivo
ORDER BY p.Nombre, Cantidad_Desperdiciada DESC;

-- 21. Productos cuya durabilidad es corta (<= 10 dias).
SELECT
    p.ID_Producto,
    p.Nombre,
    p.Durabilidad_Dias,
    cat.Nombre_Categoria AS Categoria
FROM producto p
JOIN categoria cat ON cat.ID_Categoria = p.ID_Categoria
WHERE p.Durabilidad_Dias <= 10
ORDER BY p.Durabilidad_Dias ASC;

-- 22. Indicador de desperdicio por cada 100 unidades vendidas.
SELECT
    p.ID_Producto,
    p.Nombre,
    COALESCE(v.Vendidas,0) AS Unidades_Vendidas,
    COALESCE(w.Desperdiciadas,0) AS Unidades_Desperdiciadas,
    CASE
        WHEN COALESCE(v.Vendidas,0) > 0
        THEN ROUND(100 * COALESCE(w.Desperdiciadas,0) / v.Vendidas, 2)
        ELSE NULL
    END AS Desperdicio_Por_100_Vendidas
FROM producto p
LEFT JOIN (
    SELECT ID_Producto, SUM(Cantidad) AS Vendidas
    FROM detalle_venta
    GROUP BY ID_Producto
) v ON v.ID_Producto = p.ID_Producto
LEFT JOIN (
    SELECT ID_Producto, SUM(Cantidad) AS Desperdiciadas
    FROM detalle_desperdicio
    GROUP BY ID_Producto
) w ON w.ID_Producto = p.ID_Producto
ORDER BY Desperdicio_Por_100_Vendidas DESC;

-- 23. Control de calidad: validar que cada total de desperdicio
-- coincida con la suma de sus detalles.
SELECT
    d.ID_Desperdicio,
    d.Total_Desperdicio,
    COALESCE(SUM(dd.Cantidad),0) AS Suma_Detalles,
    CASE
        WHEN d.Total_Desperdicio = COALESCE(SUM(dd.Cantidad),0)
        THEN 'OK'
        ELSE 'REVISAR'
    END AS Estado
FROM desperdicio d
LEFT JOIN detalle_desperdicio dd
    ON dd.ID_Desperdicio = d.ID_Desperdicio
GROUP BY d.ID_Desperdicio, d.Total_Desperdicio
ORDER BY Estado DESC, d.ID_Desperdicio;

-- 24. Control de calidad: validar subtotal de detalle de venta.
SELECT
    ID_DetalleVenta,
    ID_Venta,
    Cantidad,
    Precio_Unitario,
    Subtotal,
    (Cantidad * Precio_Unitario) AS Subtotal_Calculado,
    CASE
        WHEN Subtotal = Cantidad * Precio_Unitario THEN 'OK'
        ELSE 'REVISAR'
    END AS Estado
FROM detalle_venta
WHERE Subtotal <> Cantidad * Precio_Unitario;

-- 25. Control de calidad: comparar total de venta con sus detalles.
SELECT
    v.ID_Venta,
    v.Total_Venta,
    COALESCE(SUM(dv.Subtotal),0) AS Total_Detalles,
    v.Total_Venta - COALESCE(SUM(dv.Subtotal),0) AS Diferencia,
    CASE
        WHEN v.Total_Venta = COALESCE(SUM(dv.Subtotal),0)
        THEN 'OK'
        ELSE 'REVISAR'
    END AS Estado
FROM venta v
LEFT JOIN detalle_venta dv ON dv.ID_Venta = v.ID_Venta
GROUP BY v.ID_Venta, v.Total_Venta
HAVING v.Total_Venta <> COALESCE(SUM(dv.Subtotal),0)
ORDER BY ABS(v.Total_Venta - COALESCE(SUM(dv.Subtotal),0)) DESC;

-- 26. Deteccion de ventas sin detalle.
SELECT
    v.ID_Venta,
    v.Fecha_Venta,
    v.Total_Venta,
    v.ID_Cliente,
    v.ID_Empleado
FROM venta v
LEFT JOIN detalle_venta dv ON dv.ID_Venta = v.ID_Venta
WHERE dv.ID_DetalleVenta IS NULL;

-- =====================================================================
-- 8. CONSULTAS ADICIONALES PRIORIZADAS (KPIs ejecutivos)
-- =====================================================================

-- 27. Clientes VIP: ranking con % acumulado de ingresos (regla 80/20).
-- (usa subconsulta correlacionada en lugar de funcion de ventana: compatible con MySQL 5.x/MariaDB)
SELECT
    t1.ID_Cliente,
    t1.Nombre,
    t1.Valor_Compras,
    ROUND(100 * t1.Valor_Compras / (SELECT SUM(Total_Venta) FROM venta), 2) AS Pct_Ingresos,
    ROUND(100 * (
        SELECT SUM(t2.Valor_Compras)
        FROM (
            SELECT c2.ID_Cliente, SUM(v2.Total_Venta) AS Valor_Compras
            FROM cliente c2
            JOIN venta v2 ON v2.ID_Cliente = c2.ID_Cliente
            GROUP BY c2.ID_Cliente
        ) t2
        WHERE t2.Valor_Compras >= t1.Valor_Compras
    ) / (SELECT SUM(Total_Venta) FROM venta), 2) AS Pct_Acumulado
FROM (
    SELECT c.ID_Cliente, c.Nombre, SUM(v.Total_Venta) AS Valor_Compras
    FROM cliente c
    JOIN venta v ON v.ID_Cliente = c.ID_Cliente
    GROUP BY c.ID_Cliente, c.Nombre
) t1
ORDER BY t1.Valor_Compras DESC;

-- 28. Clientes recurrentes: tasa dentro del periodo analizado, con su rango de fechas.
-- 28a. Resumen con el rango de fechas que cubre el analisis.
SELECT
    (SELECT MIN(Fecha_Venta) FROM venta) AS Periodo_Desde,
    (SELECT MAX(Fecha_Venta) FROM venta) AS Periodo_Hasta,
    COUNT(*) AS Clientes_Activos,
    SUM(CASE WHEN Numero_Compras > 1 THEN 1 ELSE 0 END) AS Clientes_Recurrentes,
    ROUND(100 * SUM(CASE WHEN Numero_Compras > 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS Pct_Clientes_Recurrentes
FROM (
    SELECT ID_Cliente, COUNT(*) AS Numero_Compras
    FROM venta
    GROUP BY ID_Cliente
) t;

-- 28b. Detalle de clientes recurrentes, con fecha de su primera y su ultima compra.
SELECT
    c.ID_Cliente,
    c.Nombre,
    COUNT(v.ID_Venta) AS Numero_Compras,
    MIN(v.Fecha_Venta) AS Primera_Compra,
    MAX(v.Fecha_Venta) AS Ultima_Compra,
    DATEDIFF(MAX(v.Fecha_Venta), MIN(v.Fecha_Venta)) AS Dias_Entre_Primera_Y_Ultima_Compra
FROM cliente c
JOIN venta v ON v.ID_Cliente = c.ID_Cliente
GROUP BY c.ID_Cliente, c.Nombre
HAVING COUNT(v.ID_Venta) > 1
ORDER BY Numero_Compras DESC, Dias_Entre_Primera_Y_Ultima_Compra DESC;

-- 29. Merma como % de la mercancia recibida, por producto (indicador de shrinkage).
SELECT
    p.ID_Producto,
    p.Nombre,
    COALESCE(rec.Cantidad_Recibida, 0) AS Unidades_Recibidas,
    COALESCE(des.Cantidad_Desperdiciada, 0) AS Unidades_Desperdiciadas,
    CASE WHEN COALESCE(rec.Cantidad_Recibida,0) > 0
         THEN ROUND(100 * COALESCE(des.Cantidad_Desperdiciada,0) / rec.Cantidad_Recibida, 2)
         ELSE NULL END AS Pct_Merma_Sobre_Recibido
FROM producto p
LEFT JOIN (
    SELECT ID_Producto, SUM(Cantidad_Recibida) AS Cantidad_Recibida
    FROM detalle_proveedor GROUP BY ID_Producto
) rec ON rec.ID_Producto = p.ID_Producto
LEFT JOIN (
    SELECT ID_Producto, SUM(Cantidad) AS Cantidad_Desperdiciada
    FROM detalle_desperdicio GROUP BY ID_Producto
) des ON des.ID_Producto = p.ID_Producto
ORDER BY Pct_Merma_Sobre_Recibido DESC;

-- 30. Tendencia mensual de ventas con variacion % respecto al mes anterior.
-- (usa auto-JOIN por periodo en lugar de LAG: compatible con MySQL 5.x/MariaDB)
SELECT
    cur.Anio,
    cur.Mes,
    cur.Ventas_Totales,
    prev.Ventas_Totales AS Ventas_Mes_Anterior,
    CASE
        WHEN prev.Ventas_Totales IS NULL OR prev.Ventas_Totales = 0 THEN NULL
        ELSE ROUND(100 * (cur.Ventas_Totales - prev.Ventas_Totales) / prev.Ventas_Totales, 2)
    END AS Variacion_Pct
FROM (
    SELECT YEAR(Fecha_Venta) AS Anio, MONTH(Fecha_Venta) AS Mes,
           SUM(Total_Venta) AS Ventas_Totales,
           DATE_FORMAT(Fecha_Venta, '%Y-%m-01') AS Periodo
    FROM venta
    GROUP BY YEAR(Fecha_Venta), MONTH(Fecha_Venta), DATE_FORMAT(Fecha_Venta, '%Y-%m-01')
) cur
LEFT JOIN (
    SELECT DATE_FORMAT(Fecha_Venta, '%Y-%m-01') AS Periodo,
           SUM(Total_Venta) AS Ventas_Totales
    FROM venta
    GROUP BY DATE_FORMAT(Fecha_Venta, '%Y-%m-01')
) prev ON prev.Periodo = DATE_SUB(cur.Periodo, INTERVAL 1 MONTH)
ORDER BY cur.Anio, cur.Mes;

-- 31. Top 5 productos por ingreso generado (para priorizar reabastecimiento).
SELECT
    p.ID_Producto, p.Nombre, cat.Nombre_Categoria AS Categoria,
    SUM(dv.Subtotal) AS Ingreso_Generado,
    SUM(dv.Cantidad) AS Unidades_Vendidas
FROM detalle_venta dv
JOIN producto p ON p.ID_Producto = dv.ID_Producto
JOIN categoria cat ON cat.ID_Categoria = p.ID_Categoria
GROUP BY p.ID_Producto, p.Nombre, cat.Nombre_Categoria
ORDER BY Ingreso_Generado DESC
LIMIT 5;

-- 32. Margen de ganancia por producto y margen global del negocio.
-- Costo_Unitario_Promedio se deriva de detalle_proveedor (Precio_Compra / Cantidad_Recibida).
-- 32a. Margen por producto.
SELECT
    p.ID_Producto,
    p.Nombre,
    ROUND(AVG(dv.Precio_Unitario), 2) AS Precio_Venta_Promedio,
    ROUND(costo.Costo_Unitario_Promedio, 2) AS Costo_Unitario_Promedio,
    ROUND(AVG(dv.Precio_Unitario) - costo.Costo_Unitario_Promedio, 2) AS Margen_Absoluto,
    ROUND(100 * (AVG(dv.Precio_Unitario) - costo.Costo_Unitario_Promedio) / AVG(dv.Precio_Unitario), 2) AS Margen_Porcentual
FROM producto p
JOIN detalle_venta dv ON dv.ID_Producto = p.ID_Producto
JOIN (
    SELECT ID_Producto, AVG(Precio_Compra / Cantidad_Recibida) AS Costo_Unitario_Promedio
    FROM detalle_proveedor
    GROUP BY ID_Producto
) costo ON costo.ID_Producto = p.ID_Producto
GROUP BY p.ID_Producto, p.Nombre, costo.Costo_Unitario_Promedio
ORDER BY Margen_Porcentual DESC;

-- 32b. Margen global estimado del negocio (ingresos vs costo estimado de lo vendido).
SELECT
    SUM(dv.Subtotal) AS Ingresos_Totales,
    ROUND(SUM(dv.Cantidad * costo.Costo_Unitario_Promedio), 2) AS Costo_Estimado_Total,
    ROUND(SUM(dv.Subtotal) - SUM(dv.Cantidad * costo.Costo_Unitario_Promedio), 2) AS Margen_Absoluto_Global,
    ROUND(100 * (SUM(dv.Subtotal) - SUM(dv.Cantidad * costo.Costo_Unitario_Promedio)) / SUM(dv.Subtotal), 2) AS Margen_Porcentual_Global
FROM detalle_venta dv
JOIN (
    SELECT ID_Producto, AVG(Precio_Compra / Cantidad_Recibida) AS Costo_Unitario_Promedio
    FROM detalle_proveedor
    GROUP BY ID_Producto
) costo ON costo.ID_Producto = dv.ID_Producto;

-- 33. Porcentaje de perdida (desperdicio) estimado por proveedor y producto.
-- NOTA / SUPUESTO: el modelo no registra de que proveedor/lote proviene cada unidad desperdiciada
-- (detalle_desperdicio solo se relaciona con producto). Por eso la perdida de cada producto se
-- distribuye proporcionalmente entre sus proveedores, segun la participacion de cada uno en el
-- total de unidades que ese proveedor suministro de ese producto.
SELECT
    pr.ID_Proveedor,
    pr.Nombre_Proveedor,
    p.ID_Producto,
    p.Nombre AS Producto,
    dpp.Cantidad_Recibida AS Cantidad_Suministrada_Por_Proveedor,
    tot.Total_Recibido_Producto,
    COALESCE(totd.Total_Desperdicio_Producto, 0) AS Total_Desperdicio_Producto,
    ROUND(dpp.Cantidad_Recibida / tot.Total_Recibido_Producto * COALESCE(totd.Total_Desperdicio_Producto, 0), 2) AS Perdida_Atribuida_Estimada,
    ROUND(100 * (dpp.Cantidad_Recibida / tot.Total_Recibido_Producto * COALESCE(totd.Total_Desperdicio_Producto, 0)) / dpp.Cantidad_Recibida, 2) AS Pct_Perdida_Sobre_Lo_Suministrado
FROM (
    SELECT ID_Proveedor, ID_Producto, SUM(Cantidad_Recibida) AS Cantidad_Recibida
    FROM detalle_proveedor
    GROUP BY ID_Proveedor, ID_Producto
) dpp
JOIN proveedor pr ON pr.ID_Proveedor = dpp.ID_Proveedor
JOIN producto p ON p.ID_Producto = dpp.ID_Producto
JOIN (
    SELECT ID_Producto, SUM(Cantidad_Recibida) AS Total_Recibido_Producto
    FROM detalle_proveedor
    GROUP BY ID_Producto
) tot ON tot.ID_Producto = dpp.ID_Producto
LEFT JOIN (
    SELECT ID_Producto, SUM(Cantidad) AS Total_Desperdicio_Producto
    FROM detalle_desperdicio
    GROUP BY ID_Producto
) totd ON totd.ID_Producto = dpp.ID_Producto
ORDER BY Pct_Perdida_Sobre_Lo_Suministrado DESC;

-- 34. Serie semanal de demanda (lunes a domingo) para el analisis predictivo en Python.
SELECT
    DATE_SUB(v.Fecha_Venta, INTERVAL WEEKDAY(v.Fecha_Venta) DAY) AS Semana_Inicio,
    SUM(dv.Cantidad) AS Unidades_Vendidas,
    SUM(dv.Subtotal) AS Ingresos,
    COUNT(DISTINCT v.ID_Venta) AS Numero_Ventas,
    COUNT(DISTINCT v.Fecha_Venta) AS Dias_Con_Venta
FROM venta v
JOIN detalle_venta dv ON dv.ID_Venta = v.ID_Venta
GROUP BY DATE_SUB(v.Fecha_Venta, INTERVAL WEEKDAY(v.Fecha_Venta) DAY)
ORDER BY Semana_Inicio;

-- =====================================================================
-- FIN DEL SCRIPT
-- =====================================================================
