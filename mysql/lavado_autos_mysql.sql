-- ===========================================================================
--  Base de datos `lavado_autos` para MySQL 8.0+
--  Equivalente al esquema `lavado_autos` de PostgreSQL/Supabase.
--
--  Cómo usarlo en MySQL Workbench:
--    1. Abre Workbench y conéctate a tu servidor local (root o un usuario
--       con permiso CREATE DATABASE).
--    2. File > Open SQL Script... y elige este archivo.
--    3. Pulsa el rayo con el mundo: "Execute SQL Script" (Ctrl+Shift+Enter).
--    4. Actualiza el panel SCHEMAS (F5) y aparecerá `lavado_autos`.
--
--  Es idempotente: se puede ejecutar varias veces sin duplicar datos.
--  Para reiniciar desde cero, descomenta la línea DROP de abajo.
-- ===========================================================================

-- DROP DATABASE IF EXISTS lavado_autos;

CREATE DATABASE IF NOT EXISTS lavado_autos
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE lavado_autos;

SET NAMES utf8mb4;

-- ---------------------------------------------------------------------------
-- Catálogos
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS clientes (
  id             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre         VARCHAR(100)    NOT NULL,
  apellido       VARCHAR(100)    NOT NULL,
  telefono       VARCHAR(20)     NOT NULL,
  email          VARCHAR(150)    NULL,
  direccion      VARCHAR(200)    NULL,
  fecha_registro DATE            NOT NULL DEFAULT (CURRENT_DATE),
  activo         TINYINT(1)      NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY clientes_telefono_uk (telefono),
  UNIQUE KEY clientes_email_uk (email),
  CONSTRAINT clientes_activo_ck CHECK (activo IN (0,1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
  COMMENT='Clientes del negocio de lavado de autos';

CREATE TABLE IF NOT EXISTS vehiculos (
  id         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  cliente_id BIGINT UNSIGNED NOT NULL,
  placa      VARCHAR(20)     NOT NULL,
  marca      VARCHAR(60)     NOT NULL,
  modelo     VARCHAR(60)     NOT NULL,
  anio       SMALLINT        NOT NULL,
  color      VARCHAR(30)     NULL,
  tipo       ENUM('sedan','suv','pickup','moto','van') NOT NULL DEFAULT 'sedan',
  creado_en  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY vehiculos_placa_uk (placa),
  KEY vehiculos_cliente_idx (cliente_id),
  CONSTRAINT vehiculos_cliente_fk FOREIGN KEY (cliente_id)
    REFERENCES clientes (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT vehiculos_anio_ck CHECK (anio BETWEEN 1980 AND 2035)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
  COMMENT='Vehículos registrados por cliente';

CREATE TABLE IF NOT EXISTS servicios (
  id           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre       VARCHAR(120)    NOT NULL,
  descripcion  VARCHAR(255)    NULL,
  precio       DECIMAL(10,2)   NOT NULL,
  duracion_min SMALLINT        NOT NULL,
  activo       TINYINT(1)      NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY servicios_nombre_uk (nombre),
  CONSTRAINT servicios_precio_ck CHECK (precio >= 0),
  CONSTRAINT servicios_duracion_ck CHECK (duracion_min > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
  COMMENT='Catálogo de servicios de lavado';

CREATE TABLE IF NOT EXISTS empleados (
  id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre        VARCHAR(100)    NOT NULL,
  apellido      VARCHAR(100)    NOT NULL,
  puesto        ENUM('lavador','supervisor','cajero','recepcionista','gerente') NOT NULL,
  telefono      VARCHAR(20)     NULL,
  email         VARCHAR(150)    NULL,
  fecha_ingreso DATE            NULL,
  activo        TINYINT(1)      NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY empleados_email_uk (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
  COMMENT='Personal del negocio';

CREATE TABLE IF NOT EXISTS insumos (
  id             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre         VARCHAR(120)    NOT NULL,
  unidad         ENUM('litro','kilo','pieza') NOT NULL,
  stock          DECIMAL(10,2)   NOT NULL DEFAULT 0,
  stock_minimo   DECIMAL(10,2)   NOT NULL DEFAULT 0,
  costo_unitario DECIMAL(10,2)   NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY insumos_nombre_uk (nombre),
  CONSTRAINT insumos_stock_ck CHECK (stock >= 0),
  CONSTRAINT insumos_stock_minimo_ck CHECK (stock_minimo >= 0),
  CONSTRAINT insumos_costo_ck CHECK (costo_unitario >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
  COMMENT='Inventario de insumos';

CREATE TABLE IF NOT EXISTS promociones (
  id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre        VARCHAR(120)    NOT NULL,
  descuento_pct DECIMAL(5,2)    NOT NULL,
  fecha_inicio  DATE            NOT NULL,
  fecha_fin     DATE            NOT NULL,
  activo        TINYINT(1)      NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY promociones_nombre_uk (nombre),
  CONSTRAINT promociones_descuento_ck CHECK (descuento_pct BETWEEN 0 AND 100),
  CONSTRAINT promociones_fechas_ck CHECK (fecha_fin >= fecha_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
  COMMENT='Promociones y descuentos';

-- ---------------------------------------------------------------------------
-- Operación
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS citas (
  id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  cliente_id  BIGINT UNSIGNED NOT NULL,
  vehiculo_id BIGINT UNSIGNED NOT NULL,
  fecha_hora  DATETIME        NOT NULL,
  estado      ENUM('pendiente','confirmada','atendida','cancelada','no_asistio')
              NOT NULL DEFAULT 'pendiente',
  notas       TEXT            NULL,
  PRIMARY KEY (id),
  KEY citas_cliente_idx (cliente_id),
  KEY citas_vehiculo_idx (vehiculo_id),
  CONSTRAINT citas_cliente_fk FOREIGN KEY (cliente_id)
    REFERENCES clientes (id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT citas_vehiculo_fk FOREIGN KEY (vehiculo_id)
    REFERENCES vehiculos (id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
  COMMENT='Citas agendadas';

CREATE TABLE IF NOT EXISTS ordenes (
  id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  cliente_id    BIGINT UNSIGNED NOT NULL,
  vehiculo_id   BIGINT UNSIGNED NOT NULL,
  empleado_id   BIGINT UNSIGNED NOT NULL,
  fecha         DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  estado        ENUM('abierta','en_proceso','terminada','pagada','cancelada')
                NOT NULL DEFAULT 'abierta',
  subtotal      DECIMAL(10,2)   NOT NULL DEFAULT 0,
  descuento     DECIMAL(10,2)   NOT NULL DEFAULT 0,
  total         DECIMAL(10,2)   NOT NULL DEFAULT 0,
  observaciones TEXT            NULL,
  PRIMARY KEY (id),
  KEY ordenes_cliente_idx (cliente_id),
  KEY ordenes_vehiculo_idx (vehiculo_id),
  KEY ordenes_empleado_idx (empleado_id),
  CONSTRAINT ordenes_cliente_fk FOREIGN KEY (cliente_id)
    REFERENCES clientes (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ordenes_vehiculo_fk FOREIGN KEY (vehiculo_id)
    REFERENCES vehiculos (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ordenes_empleado_fk FOREIGN KEY (empleado_id)
    REFERENCES empleados (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ordenes_subtotal_ck CHECK (subtotal >= 0),
  CONSTRAINT ordenes_descuento_ck CHECK (descuento >= 0),
  CONSTRAINT ordenes_total_ck CHECK (total >= 0),
  CONSTRAINT ordenes_total_subtotal_ck CHECK (total <= subtotal)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
  COMMENT='Órdenes de servicio de lavado';

CREATE TABLE IF NOT EXISTS orden_detalle (
  id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  orden_id        BIGINT UNSIGNED NOT NULL,
  servicio_id     BIGINT UNSIGNED NOT NULL,
  cantidad        SMALLINT        NOT NULL DEFAULT 1,
  precio_unitario DECIMAL(10,2)   NOT NULL,
  subtotal        DECIMAL(10,2)   NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY orden_detalle_orden_servicio_uk (orden_id, servicio_id),
  KEY orden_detalle_servicio_idx (servicio_id),
  CONSTRAINT orden_detalle_orden_fk FOREIGN KEY (orden_id)
    REFERENCES ordenes (id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT orden_detalle_servicio_fk FOREIGN KEY (servicio_id)
    REFERENCES servicios (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT orden_detalle_cantidad_ck CHECK (cantidad > 0),
  CONSTRAINT orden_detalle_precio_ck CHECK (precio_unitario >= 0),
  CONSTRAINT orden_detalle_subtotal_ck CHECK (subtotal >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
  COMMENT='Servicios incluidos en cada orden';

CREATE TABLE IF NOT EXISTS pagos (
  id         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  orden_id   BIGINT UNSIGNED NOT NULL,
  monto      DECIMAL(10,2)   NOT NULL,
  metodo     ENUM('efectivo','tarjeta','transferencia','wallet') NOT NULL,
  fecha_pago DATETIME        NULL,
  referencia VARCHAR(60)     NULL,
  estado     ENUM('aprobado','pendiente','rechazado') NOT NULL DEFAULT 'aprobado',
  PRIMARY KEY (id),
  KEY pagos_orden_idx (orden_id),
  CONSTRAINT pagos_orden_fk FOREIGN KEY (orden_id)
    REFERENCES ordenes (id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT pagos_monto_ck CHECK (monto > 0),
  CONSTRAINT pagos_aprobado_fecha_ck CHECK (estado <> 'aprobado' OR fecha_pago IS NOT NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
  COMMENT='Pagos asociados a las órdenes';

CREATE TABLE IF NOT EXISTS consumo_insumos (
  id        BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  orden_id  BIGINT UNSIGNED NOT NULL,
  insumo_id BIGINT UNSIGNED NOT NULL,
  cantidad  DECIMAL(10,2)   NOT NULL,
  fecha     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY consumo_insumos_orden_insumo_uk (orden_id, insumo_id),
  KEY consumo_insumos_insumo_idx (insumo_id),
  CONSTRAINT consumo_insumos_orden_fk FOREIGN KEY (orden_id)
    REFERENCES ordenes (id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT consumo_insumos_insumo_fk FOREIGN KEY (insumo_id)
    REFERENCES insumos (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT consumo_insumos_cantidad_ck CHECK (cantidad > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
  COMMENT='Insumos utilizados por orden de servicio';

CREATE TABLE IF NOT EXISTS orden_promociones (
  orden_id     BIGINT UNSIGNED NOT NULL,
  promocion_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (orden_id, promocion_id),
  KEY orden_promociones_promo_idx (promocion_id),
  CONSTRAINT orden_promociones_orden_fk FOREIGN KEY (orden_id)
    REFERENCES ordenes (id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT orden_promociones_promo_fk FOREIGN KEY (promocion_id)
    REFERENCES promociones (id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
  COMMENT='Promociones aplicadas a cada orden';

-- ===========================================================================
--  Datos de ejemplo (144 filas)
-- ===========================================================================

INSERT IGNORE INTO clientes (id, nombre, apellido, telefono, email, direccion, fecha_registro, activo) VALUES
  (1,'Juan','Pérez','555-1001','juan.perez@mail.com','Av. Reforma 123','2026-01-05',1),
  (2,'María','López','555-1002','maria.lopez@mail.com','Calle Hidalgo 45','2026-01-12',1),
  (3,'Carlos','Ramírez','555-1003','carlos.ramirez@mail.com','Insurgentes 890','2026-02-03',1),
  (4,'Ana','Torres','555-1004','ana.torres@mail.com','Av. Juárez 12','2026-02-18',1),
  (5,'Luis','Hernández','555-1005','luis.hernandez@mail.com','Calle Morelos 78','2026-03-02',1),
  (6,'Sofía','Méndez','555-1006','sofia.mendez@mail.com','Av. Universidad 1456','2026-03-21',1),
  (7,'Pedro','Castillo','555-1007','pedro.castillo@mail.com','Calle Allende 33','2026-04-07',1),
  (8,'Lucía','Romero','555-1008','lucia.romero@mail.com','Av. Chapultepec 200','2026-04-25',1),
  (9,'Jorge','Vargas','555-1009','jorge.vargas@mail.com','Calle Zaragoza 67','2026-05-14',1),
  (10,'Daniela','Ortiz','555-1010','daniela.ortiz@mail.com','Av. Constitución 500','2026-06-01',1),
  (11,'Ricardo','Flores','555-1011','ricardo.flores@mail.com','Calle 5 de Mayo 21','2026-07-09',1),
  (12,'Elena','Guzmán','555-1012','elena.guzman@mail.com','Av. Independencia 999','2026-08-15',1);

INSERT IGNORE INTO vehiculos (id, cliente_id, placa, marca, modelo, anio, color, tipo) VALUES
  (1,1,'ABC-123-A','Nissan','Versa',2020,'Blanco','sedan'),
  (2,2,'DEF-456-B','Toyota','Corolla',2019,'Gris','sedan'),
  (3,3,'GHI-789-C','Ford','Ranger',2021,'Azul','pickup'),
  (4,4,'JKL-012-D','Honda','CR-V',2022,'Rojo','suv'),
  (5,5,'MNO-345-E','Chevrolet','Aveo',2018,'Negro','sedan'),
  (6,6,'PQR-678-F','Mazda','CX-5',2023,'Plata','suv'),
  (7,7,'STU-901-G','Volkswagen','Jetta',2020,'Blanco','sedan'),
  (8,8,'VWX-234-H','Kia','Sportage',2021,'Verde','suv'),
  (9,9,'YZA-567-I','Yamaha','FZ25',2022,'Negro','moto'),
  (10,10,'BCD-890-J','Renault','Kangoo',2019,'Blanco','van'),
  (11,11,'EFG-123-K','Seat','Ibiza',2020,'Azul','sedan'),
  (12,12,'HIJ-456-L','Hyundai','Tucson',2023,'Gris','suv');

INSERT IGNORE INTO servicios (id, nombre, descripcion, precio, duracion_min, activo) VALUES
  (1,'Lavado básico','Lavado exterior y secado',120.00,30,1),
  (2,'Lavado premium','Lavado exterior, interior y aspirado',250.00,45,1),
  (3,'Lavado de motor','Limpieza y desengrase del motor',180.00,40,1),
  (4,'Aspirado interior','Aspirado de asientos y alfombras',80.00,20,1),
  (5,'Encerado','Encerado y abrillantado de carrocería',220.00,50,1),
  (6,'Lavado de tapicería','Limpieza profunda de asientos y tapetes',350.00,90,1),
  (7,'Pulido de faros','Pulido y restauración de faros',150.00,30,1),
  (8,'Desinfección con ozono','Eliminación de olores y bacterias',200.00,60,1),
  (9,'Lavado de chasis','Limpieza de bajos y chasis',140.00,35,1),
  (10,'Paquete completo','Lavado, encerado, motor e interiores',450.00,120,1);

INSERT IGNORE INTO empleados (id, nombre, apellido, puesto, telefono, email, fecha_ingreso, activo) VALUES
  (1,'Miguel','Sánchez','lavador','555-2001','miguel.sanchez@lavado.com','2024-01-15',1),
  (2,'Laura','Díaz','cajero','555-2002','laura.diaz@lavado.com','2024-02-01',1),
  (3,'Roberto','Núñez','lavador','555-2003','roberto.nunez@lavado.com','2024-03-10',1),
  (4,'Patricia','Silva','recepcionista','555-2004','patricia.silva@lavado.com','2024-04-05',1),
  (5,'Fernando','Ríos','lavador','555-2005','fernando.rios@lavado.com','2024-05-20',1),
  (6,'Gabriela','Peña','supervisor','555-2006','gabriela.pena@lavado.com','2024-06-01',1),
  (7,'Óscar','Luna','lavador','555-2007','oscar.luna@lavado.com','2024-07-12',1),
  (8,'Verónica','Campos','cajero','555-2008','veronica.campos@lavado.com','2024-08-03',1),
  (9,'Andrés','Molina','lavador','555-2009','andres.molina@lavado.com','2024-09-16',1),
  (10,'Teresa','Ibarra','gerente','555-2010','teresa.ibarra@lavado.com','2024-10-01',1);

INSERT IGNORE INTO insumos (id, nombre, unidad, stock, stock_minimo, costo_unitario) VALUES
  (1,'Shampoo automotriz','litro',40.00,10.00,85.50),
  (2,'Cera líquida','litro',25.00,5.00,120.00),
  (3,'Limpiador de tapicería','litro',18.00,4.00,150.00),
  (4,'Desengrasante','litro',30.00,8.00,95.00),
  (5,'Abrillantador de llantas','litro',22.00,5.00,110.00),
  (6,'Toallas de microfibra','pieza',80.00,20.00,35.00),
  (7,'Silicona para tablero','litro',15.00,3.00,130.00),
  (8,'Limpiador de vidrios','litro',28.00,6.00,70.00),
  (9,'Aromatizante','pieza',60.00,15.00,25.00),
  (10,'Ozono','pieza',50.00,10.00,60.00);

INSERT IGNORE INTO promociones (id, nombre, descuento_pct, fecha_inicio, fecha_fin, activo) VALUES
  (1,'Martes de lavado',15.00,'2026-01-01','2026-12-31',1),
  (2,'Cliente frecuente',10.00,'2026-01-01','2026-12-31',1),
  (3,'Paquete familiar',20.00,'2026-02-01','2026-06-30',1),
  (4,'Promo SUV',12.00,'2026-03-01','2026-05-31',1),
  (5,'Bienvenida',25.00,'2026-01-01','2026-12-31',1),
  (6,'Día del padre',18.00,'2026-06-01','2026-06-30',1),
  (7,'Aniversario',30.00,'2026-09-01','2026-09-30',1),
  (8,'Lavado + encerado',15.00,'2026-04-01','2026-08-31',1),
  (9,'Temporada de lluvias',8.00,'2026-06-01','2026-09-30',1),
  (10,'Fin de año',22.00,'2026-12-01','2026-12-31',1);

INSERT IGNORE INTO citas (id, cliente_id, vehiculo_id, fecha_hora, estado, notas) VALUES
  (1,1,1,'2026-11-10 09:00:00','pendiente','Lavado básico'),
  (2,2,2,'2026-11-10 10:30:00','confirmada','Lavado premium'),
  (3,3,3,'2026-11-10 12:00:00','confirmada','Lavado de motor'),
  (4,4,4,'2026-11-11 08:30:00','pendiente','Encerado'),
  (5,5,5,'2026-11-11 11:00:00','atendida','Aspirado interior'),
  (6,6,6,'2026-11-12 09:15:00','confirmada','Desinfección con ozono'),
  (7,7,7,'2026-11-12 13:00:00','cancelada','Cliente reprogramó'),
  (8,8,8,'2026-11-13 10:00:00','pendiente','Paquete completo'),
  (9,9,9,'2026-11-13 15:30:00','confirmada','Lavado de chasis'),
  (10,10,10,'2026-11-14 08:00:00','pendiente','Lavado premium'),
  (11,11,11,'2026-11-14 12:45:00','no_asistio','No llegó'),
  (12,12,12,'2026-11-15 09:30:00','confirmada','Paquete completo');

INSERT IGNORE INTO ordenes (id, cliente_id, vehiculo_id, empleado_id, fecha, estado, subtotal, descuento, total, observaciones) VALUES
  (1,1,1,1,'2026-11-10 09:10:00','pagada',200.00,50.00,150.00,'Promoción de bienvenida'),
  (2,2,2,3,'2026-11-10 10:40:00','pagada',470.00,47.00,423.00,'Cliente frecuente'),
  (3,3,3,5,'2026-11-10 12:10:00','pagada',320.00,48.00,272.00,'Martes de lavado'),
  (4,4,4,7,'2026-09-15 10:00:00','pagada',550.00,165.00,385.00,'Promoción aniversario'),
  (5,5,5,9,'2026-06-20 12:30:00','pagada',530.00,95.40,434.60,'Día del padre'),
  (6,6,6,1,'2026-05-10 09:20:00','pagada',400.00,48.00,352.00,'Promo SUV'),
  (7,7,7,3,'2026-04-18 11:00:00','terminada',420.00,63.00,357.00,'Pago pendiente'),
  (8,8,8,5,'2026-07-05 10:15:00','terminada',800.00,64.00,736.00,'Pago pendiente'),
  (9,9,9,7,'2026-12-20 16:00:00','pagada',120.00,26.40,93.60,'Fin de año'),
  (10,10,10,9,'2026-03-15 09:00:00','pagada',180.00,36.00,144.00,'Paquete familiar'),
  (11,11,11,1,'2026-05-25 15:30:00','pagada',150.00,0.00,150.00,'Sin promoción'),
  (12,12,12,3,'2026-11-05 16:45:00','pagada',140.00,0.00,140.00,'Sin promoción');

INSERT IGNORE INTO orden_detalle (id, orden_id, servicio_id, cantidad, precio_unitario, subtotal) VALUES
  (1,1,1,1,120.00,120.00),
  (2,1,4,1,80.00,80.00),
  (3,2,2,1,250.00,250.00),
  (4,2,5,1,220.00,220.00),
  (5,3,3,1,180.00,180.00),
  (6,3,9,1,140.00,140.00),
  (7,4,6,1,350.00,350.00),
  (8,4,8,1,200.00,200.00),
  (9,5,10,1,450.00,450.00),
  (10,5,4,1,80.00,80.00),
  (11,6,2,1,250.00,250.00),
  (12,6,7,1,150.00,150.00),
  (13,7,5,1,220.00,220.00),
  (14,7,8,1,200.00,200.00),
  (15,8,10,1,450.00,450.00),
  (16,8,6,1,350.00,350.00),
  (17,9,1,1,120.00,120.00),
  (18,10,3,1,180.00,180.00),
  (19,11,7,1,150.00,150.00),
  (20,12,9,1,140.00,140.00);

INSERT IGNORE INTO pagos (id, orden_id, monto, metodo, fecha_pago, referencia, estado) VALUES
  (1,1,150.00,'efectivo','2026-11-10 09:50:00',NULL,'aprobado'),
  (2,2,423.00,'tarjeta','2026-11-10 11:40:00','TXN-1001','aprobado'),
  (3,3,272.00,'efectivo','2026-11-10 13:00:00',NULL,'aprobado'),
  (4,4,385.00,'transferencia','2026-09-15 12:00:00','SPEI-2201','aprobado'),
  (5,5,434.60,'wallet','2026-06-20 14:10:00','WALLET-3301','aprobado'),
  (6,6,352.00,'tarjeta','2026-05-10 10:20:00','TXN-1002','aprobado'),
  (7,7,357.00,'efectivo',NULL,NULL,'pendiente'),
  (8,8,736.00,'transferencia',NULL,'SPEI-2202','pendiente'),
  (9,9,93.60,'tarjeta','2026-12-20 18:00:00','TXN-1003','aprobado'),
  (10,10,144.00,'efectivo','2026-03-15 09:45:00',NULL,'aprobado'),
  (11,11,150.00,'wallet','2026-05-25 16:30:00','WALLET-3302','aprobado'),
  (12,12,140.00,'tarjeta','2026-11-05 17:15:00','TXN-1004','aprobado');

INSERT IGNORE INTO consumo_insumos (id, orden_id, insumo_id, cantidad, fecha) VALUES
  (1,1,1,0.50,'2026-11-10 09:15:00'),
  (2,1,6,4.00,'2026-11-10 09:15:00'),
  (3,2,1,0.60,'2026-11-10 10:45:00'),
  (4,2,2,0.30,'2026-11-10 10:45:00'),
  (5,3,1,0.40,'2026-11-10 12:15:00'),
  (6,3,5,0.20,'2026-11-10 12:15:00'),
  (7,4,1,0.80,'2026-09-15 10:05:00'),
  (8,4,6,6.00,'2026-09-15 10:05:00'),
  (9,5,4,0.50,'2026-06-20 12:35:00'),
  (10,5,8,0.40,'2026-06-20 12:35:00'),
  (11,6,1,0.50,'2026-05-10 09:25:00'),
  (12,6,2,0.25,'2026-05-10 09:25:00'),
  (13,7,2,0.40,'2026-04-18 11:05:00'),
  (14,8,3,0.50,'2026-07-05 10:20:00');

INSERT IGNORE INTO orden_promociones (orden_id, promocion_id) VALUES
  (1,5),(2,2),(3,1),(4,7),(5,6),(6,4),(7,8),(8,9),(9,10),(10,3);

-- ===========================================================================
--  Verificación rápida
-- ===========================================================================

SELECT 'clientes' AS tabla, COUNT(*) AS filas FROM clientes
UNION ALL SELECT 'vehiculos',        COUNT(*) FROM vehiculos
UNION ALL SELECT 'servicios',        COUNT(*) FROM servicios
UNION ALL SELECT 'empleados',        COUNT(*) FROM empleados
UNION ALL SELECT 'insumos',          COUNT(*) FROM insumos
UNION ALL SELECT 'promociones',      COUNT(*) FROM promociones
UNION ALL SELECT 'citas',            COUNT(*) FROM citas
UNION ALL SELECT 'ordenes',          COUNT(*) FROM ordenes
UNION ALL SELECT 'orden_detalle',    COUNT(*) FROM orden_detalle
UNION ALL SELECT 'pagos',            COUNT(*) FROM pagos
UNION ALL SELECT 'consumo_insumos',  COUNT(*) FROM consumo_insumos
UNION ALL SELECT 'orden_promociones',COUNT(*) FROM orden_promociones
ORDER BY tabla;
