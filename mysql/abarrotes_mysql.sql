-- ===========================================================================
--  Tienda de abarrotes (copia MySQL del esquema `abarrotes` de Supabase)
--  PostgreSQL -> MySQL 8.0+
--  6 tablas, 44 filas de ejemplo.
-- ===========================================================================

CREATE DATABASE IF NOT EXISTS abarrotes
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE abarrotes;

SET NAMES utf8mb4;

-- ---------------------------------------------------------------------------
-- Catálogos
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS categorias (
  id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre      VARCHAR(80)     NOT NULL,
  descripcion VARCHAR(200)    NULL,
  activo      TINYINT(1)      NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY categorias_nombre_uk (nombre),
  CONSTRAINT categorias_nombre_no_vacio CHECK (CHAR_LENGTH(TRIM(nombre)) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
  COMMENT='Categorías de productos de la tienda';

CREATE TABLE IF NOT EXISTS proveedores (
  id        BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre    VARCHAR(120)    NOT NULL,
  contacto  VARCHAR(100)    NULL,
  telefono  VARCHAR(30)     NOT NULL,
  email     VARCHAR(150)    NULL,
  direccion VARCHAR(200)    NULL,
  activo    TINYINT(1)      NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY proveedores_nombre_uk (nombre),
  UNIQUE KEY proveedores_telefono_uk (telefono),
  UNIQUE KEY proveedores_email_uk (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
  COMMENT='Proveedores de la tienda';

CREATE TABLE IF NOT EXISTS productos (
  id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  categoria_id  BIGINT UNSIGNED NOT NULL,
  proveedor_id  BIGINT UNSIGNED NOT NULL,
  codigo        VARCHAR(30)     NOT NULL,
  nombre        VARCHAR(120)    NOT NULL,
  descripcion   VARCHAR(200)    NULL,
  precio_costo  DECIMAL(10,2)   NOT NULL,
  precio_venta  DECIMAL(10,2)   NOT NULL,
  stock         INT             NOT NULL DEFAULT 0,
  stock_minimo  INT             NOT NULL DEFAULT 0,
  activo        TINYINT(1)      NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY productos_codigo_uk (codigo),
  KEY productos_categoria_idx (categoria_id),
  KEY productos_proveedor_idx (proveedor_id),
  CONSTRAINT productos_categoria_fk FOREIGN KEY (categoria_id)
    REFERENCES categorias (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT productos_proveedor_fk FOREIGN KEY (proveedor_id)
    REFERENCES proveedores (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT productos_costo_ck CHECK (precio_costo >= 0),
  CONSTRAINT productos_precio_ck CHECK (precio_venta > 0),
  CONSTRAINT productos_margen_ck CHECK (precio_venta >= precio_costo),
  CONSTRAINT productos_stock_ck CHECK (stock >= 0),
  CONSTRAINT productos_stock_minimo_ck CHECK (stock_minimo >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
  COMMENT='Productos disponibles en la tienda';

CREATE TABLE IF NOT EXISTS clientes (
  id             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre         VARCHAR(100)    NOT NULL,
  apellido       VARCHAR(100)    NOT NULL,
  telefono       VARCHAR(30)     NOT NULL,
  email          VARCHAR(150)    NULL,
  direccion      VARCHAR(200)    NULL,
  fecha_registro DATE            NOT NULL DEFAULT (CURRENT_DATE),
  activo         TINYINT(1)      NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY clientes_telefono_uk (telefono),
  UNIQUE KEY clientes_email_uk (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
  COMMENT='Clientes de la tienda';

-- ---------------------------------------------------------------------------
-- Operación
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS ventas (
  id           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  cliente_id   BIGINT UNSIGNED NOT NULL,
  fecha        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  metodo_pago  ENUM('efectivo','tarjeta','transferencia','wallet')
               NOT NULL DEFAULT 'efectivo',
  total        DECIMAL(10,2)   NOT NULL DEFAULT 0,
  estado       ENUM('completada','pendiente','cancelada')
               NOT NULL DEFAULT 'completada',
  notas        TEXT            NULL,
  PRIMARY KEY (id),
  KEY ventas_cliente_idx (cliente_id),
  CONSTRAINT ventas_cliente_fk FOREIGN KEY (cliente_id)
    REFERENCES clientes (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ventas_total_ck CHECK (total >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
  COMMENT='Ventas registradas en la tienda';

CREATE TABLE IF NOT EXISTS detalle_ventas (
  id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  venta_id        BIGINT UNSIGNED NOT NULL,
  producto_id     BIGINT UNSIGNED NOT NULL,
  cantidad        INT             NOT NULL DEFAULT 1,
  precio_unitario DECIMAL(10,2)   NOT NULL,
  subtotal        DECIMAL(10,2)   NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY detalle_ventas_unicidad_uk (venta_id, producto_id),
  KEY detalle_ventas_producto_idx (producto_id),
  CONSTRAINT detalle_ventas_venta_fk FOREIGN KEY (venta_id)
    REFERENCES ventas (id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT detalle_ventas_producto_fk FOREIGN KEY (producto_id)
    REFERENCES productos (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT detalle_ventas_cantidad_ck CHECK (cantidad > 0),
  CONSTRAINT detalle_ventas_precio_ck CHECK (precio_unitario > 0),
  CONSTRAINT detalle_ventas_subtotal_ck CHECK (subtotal >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
  COMMENT='Productos incluidos en cada venta';

-- ---------------------------------------------------------------------------
-- Datos de ejemplo (44 filas)
-- ---------------------------------------------------------------------------

INSERT IGNORE INTO categorias (id, nombre, descripcion, activo) VALUES
  (1,'Bebidas','Refrescos, aguas y jugos',1),
  (2,'Snacks','Papas, galletas y botanas',1),
  (3,'Limpieza','Detergentes y papel',1),
  (4,'Alimentos básicos','Granos y alimentos de despensa',1),
  (5,'Cuidado personal','Jabones y artículos de higiene',1);

INSERT IGNORE INTO proveedores (id, nombre, contacto, telefono, email, direccion, activo) VALUES
  (1,'Distribuidora El Manantial','Pedro Hernández','555-4001','pedro@elmanantial.mx','Av. Central 120',1),
  (2,'Botanas La Esquina','Sofía Méndez','555-4002','sofia@laesquina.mx','Calle 5 de Mayo 45',1),
  (3,'Productos Cleanco','Roberto Díaz','555-4003','roberto@cleanco.mx','Av. Industrial 78',1),
  (4,'Mayorista San José','Laura Cruz','555-4004','laura@sanjose.mx','Camino Real 310',1),
  (5,'Droguería Bienestar','Andrés Vega','555-4005','andres@bienestar.mx','Calle Hidalgo 22',1);

INSERT IGNORE INTO productos (id, categoria_id, proveedor_id, codigo, nombre, descripcion, precio_costo, precio_venta, stock, stock_minimo, activo) VALUES
  (1,1,1,'BEB-001','Coca-Cola 600 ml','Refresco de cola botella 600 ml',18.00,25.00,120,20,1),
  (2,1,1,'BEB-002','Agua purificada 1 L','Agua embotellada 1 litro',8.00,12.00,200,40,1),
  (3,1,2,'BEB-003','Jugo de naranja 1 L','Jugo natural de naranja',22.00,30.00,80,15,1),
  (4,2,2,'SNA-001','Papas fritas naturales 150 g','Papas fritas sabor natural',20.00,28.00,90,15,1),
  (5,2,3,'SNA-002','Galletas María 200 g','Galletas tipo María paquete 200 g',15.00,22.00,110,20,1),
  (6,3,3,'LIM-001','Detergente líquido 1 L','Detergente para ropa 1 litro',45.00,60.00,60,10,1),
  (7,3,4,'LIM-002','Papel higiénico 12 rollos','Paquete de 12 rollos de papel higiénico',78.00,95.00,50,10,1),
  (8,4,4,'ALI-001','Arroz blanco 1 kg','Arroz blanco grano largo',32.00,40.00,150,30,1),
  (9,4,5,'ALI-002','Frijol negro 1 kg','Frijol negro selecto',38.00,48.00,130,25,1),
  (10,5,5,'PER-001','Jabón de barra 4 piezas','Paquete de 4 jabones de barra',24.00,32.00,100,20,1);

INSERT IGNORE INTO clientes (id, nombre, apellido, telefono, email, direccion, fecha_registro, activo) VALUES
  (1,'Ana','Torres','555-3001','ana.torres@mail.com','Calle Centro 12','2026-09-01',1),
  (2,'Luis','Ramírez','555-3002','luis.ramirez@mail.com','Av. Norte 45','2026-09-08',1),
  (3,'Marta','Pérez','555-3003','marta.perez@mail.com','Calle Sur 78','2026-09-15',1),
  (4,'Carlos','Soto','555-3004','carlos.soto@mail.com','Av. Este 101','2026-10-02',1),
  (5,'Elena','Ruiz','555-3005','elena.ruiz@mail.com','Calle Oeste 33','2026-10-11',1),
  (6,'Javier','Mora','555-3006','javier.mora@mail.com','Av. Central 210','2026-10-20',1);

INSERT IGNORE INTO ventas (id, cliente_id, fecha, metodo_pago, total, estado, notas) VALUES
  (1,1,'2026-11-10 09:15:00','efectivo',78.00,'completada','Compra de bebidas y papas'),
  (2,2,'2026-11-10 11:40:00','tarjeta',80.00,'completada','Pago con tarjeta de débito'),
  (3,3,'2026-11-11 10:05:00','efectivo',128.00,'completada','Compra de despensa'),
  (4,4,'2026-11-12 16:20:00','transferencia',155.00,'completada','Transferencia SPEI'),
  (5,5,'2026-11-13 08:50:00','tarjeta',156.00,'completada','Compra de jugos y jabón'),
  (6,6,'2026-11-14 13:30:00','efectivo',49.00,'pendiente','Pago por confirmar');

INSERT IGNORE INTO detalle_ventas (id, venta_id, producto_id, cantidad, precio_unitario, subtotal) VALUES
  (1,1,1,2,25.00,50.00),
  (2,1,4,1,28.00,28.00),
  (3,2,2,3,12.00,36.00),
  (4,2,5,2,22.00,44.00),
  (5,3,8,2,40.00,80.00),
  (6,3,9,1,48.00,48.00),
  (7,4,6,1,60.00,60.00),
  (8,4,7,1,95.00,95.00),
  (9,5,3,2,30.00,60.00),
  (10,5,10,3,32.00,96.00),
  (11,6,1,1,25.00,25.00),
  (12,6,2,2,12.00,24.00);

-- Verificación rápida
SELECT 'categorias' AS tabla, COUNT(*) AS filas FROM categorias
UNION ALL SELECT 'proveedores',        COUNT(*) FROM proveedores
UNION ALL SELECT 'productos',          COUNT(*) FROM productos
UNION ALL SELECT 'clientes',           COUNT(*) FROM clientes
UNION ALL SELECT 'ventas',             COUNT(*) FROM ventas
UNION ALL SELECT 'detalle_ventas',     COUNT(*) FROM detalle_ventas
ORDER BY tabla;
