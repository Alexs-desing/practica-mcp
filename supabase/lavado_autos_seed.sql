-- Datos de ejemplo del esquema `lavado_autos` (144 filas en total).
-- Idempotente: se puede ejecutar varias veces sin duplicar registros.

insert into lavado_autos.clientes (id, nombre, apellido, telefono, email, direccion, fecha_registro, activo) values
  (1,'Juan','Pérez','555-1001','juan.perez@mail.com','Av. Reforma 123','2026-01-05',true),
  (2,'María','López','555-1002','maria.lopez@mail.com','Calle Hidalgo 45','2026-01-12',true),
  (3,'Carlos','Ramírez','555-1003','carlos.ramirez@mail.com','Insurgentes 890','2026-02-03',true),
  (4,'Ana','Torres','555-1004','ana.torres@mail.com','Av. Juárez 12','2026-02-18',true),
  (5,'Luis','Hernández','555-1005','luis.hernandez@mail.com','Calle Morelos 78','2026-03-02',true),
  (6,'Sofía','Méndez','555-1006','sofia.mendez@mail.com','Av. Universidad 1456','2026-03-21',true),
  (7,'Pedro','Castillo','555-1007','pedro.castillo@mail.com','Calle Allende 33','2026-04-07',true),
  (8,'Lucía','Romero','555-1008','lucia.romero@mail.com','Av. Chapultepec 200','2026-04-25',true),
  (9,'Jorge','Vargas','555-1009','jorge.vargas@mail.com','Calle Zaragoza 67','2026-05-14',true),
  (10,'Daniela','Ortiz','555-1010','daniela.ortiz@mail.com','Av. Constitución 500','2026-06-01',true),
  (11,'Ricardo','Flores','555-1011','ricardo.flores@mail.com','Calle 5 de Mayo 21','2026-07-09',true),
  (12,'Elena','Guzmán','555-1012','elena.guzman@mail.com','Av. Independencia 999','2026-08-15',true)
on conflict (id) do nothing;

insert into lavado_autos.vehiculos (id, cliente_id, placa, marca, modelo, anio, color, tipo) values
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
  (12,12,'HIJ-456-L','Hyundai','Tucson',2023,'Gris','suv')
on conflict (id) do nothing;

insert into lavado_autos.servicios (id, nombre, descripcion, precio, duracion_min, activo) values
  (1,'Lavado básico','Lavado exterior y secado',120.00,30,true),
  (2,'Lavado premium','Lavado exterior, interior y aspirado',250.00,45,true),
  (3,'Lavado de motor','Limpieza y desengrase del motor',180.00,40,true),
  (4,'Aspirado interior','Aspirado de asientos y alfombras',80.00,20,true),
  (5,'Encerado','Encerado y abrillantado de carrocería',220.00,50,true),
  (6,'Lavado de tapicería','Limpieza profunda de asientos y tapetes',350.00,90,true),
  (7,'Pulido de faros','Pulido y restauración de faros',150.00,30,true),
  (8,'Desinfección con ozono','Eliminación de olores y bacterias',200.00,60,true),
  (9,'Lavado de chasis','Limpieza de bajos y chasis',140.00,35,true),
  (10,'Paquete completo','Lavado, encerado, motor e interiores',450.00,120,true)
on conflict (id) do nothing;

insert into lavado_autos.empleados (id, nombre, apellido, puesto, telefono, email, fecha_ingreso, activo) values
  (1,'Miguel','Sánchez','lavador','555-2001','miguel.sanchez@lavado.com','2024-01-15',true),
  (2,'Laura','Díaz','cajero','555-2002','laura.diaz@lavado.com','2024-02-01',true),
  (3,'Roberto','Núñez','lavador','555-2003','roberto.nunez@lavado.com','2024-03-10',true),
  (4,'Patricia','Silva','recepcionista','555-2004','patricia.silva@lavado.com','2024-04-05',true),
  (5,'Fernando','Ríos','lavador','555-2005','fernando.rios@lavado.com','2024-05-20',true),
  (6,'Gabriela','Peña','supervisor','555-2006','gabriela.pena@lavado.com','2024-06-01',true),
  (7,'Óscar','Luna','lavador','555-2007','oscar.luna@lavado.com','2024-07-12',true),
  (8,'Verónica','Campos','cajero','555-2008','veronica.campos@lavado.com','2024-08-03',true),
  (9,'Andrés','Molina','lavador','555-2009','andres.molina@lavado.com','2024-09-16',true),
  (10,'Teresa','Ibarra','gerente','555-2010','teresa.ibarra@lavado.com','2024-10-01',true)
on conflict (id) do nothing;

insert into lavado_autos.insumos (id, nombre, unidad, stock, stock_minimo, costo_unitario) values
  (1,'Shampoo automotriz','litro',40.00,10.00,85.50),
  (2,'Cera líquida','litro',25.00,5.00,120.00),
  (3,'Limpiador de tapicería','litro',18.00,4.00,150.00),
  (4,'Desengrasante','litro',30.00,8.00,95.00),
  (5,'Abrillantador de llantas','litro',22.00,5.00,110.00),
  (6,'Toallas de microfibra','pieza',80.00,20.00,35.00),
  (7,'Silicona para tablero','litro',15.00,3.00,130.00),
  (8,'Limpiador de vidrios','litro',28.00,6.00,70.00),
  (9,'Aromatizante','pieza',60.00,15.00,25.00),
  (10,'Ozono','pieza',50.00,10.00,60.00)
on conflict (id) do nothing;

insert into lavado_autos.promociones (id, nombre, descuento_pct, fecha_inicio, fecha_fin, activo) values
  (1,'Martes de lavado',15.00,'2026-01-01','2026-12-31',true),
  (2,'Cliente frecuente',10.00,'2026-01-01','2026-12-31',true),
  (3,'Paquete familiar',20.00,'2026-02-01','2026-06-30',true),
  (4,'Promo SUV',12.00,'2026-03-01','2026-05-31',true),
  (5,'Bienvenida',25.00,'2026-01-01','2026-12-31',true),
  (6,'Día del padre',18.00,'2026-06-01','2026-06-30',true),
  (7,'Aniversario',30.00,'2026-09-01','2026-09-30',true),
  (8,'Lavado + encerado',15.00,'2026-04-01','2026-08-31',true),
  (9,'Temporada de lluvias',8.00,'2026-06-01','2026-09-30',true),
  (10,'Fin de año',22.00,'2026-12-01','2026-12-31',true)
on conflict (id) do nothing;

insert into lavado_autos.citas (id, cliente_id, vehiculo_id, fecha_hora, estado, notas) values
  (1,1,1,'2026-11-10 09:00:00-06','pendiente','Lavado básico'),
  (2,2,2,'2026-11-10 10:30:00-06','confirmada','Lavado premium'),
  (3,3,3,'2026-11-10 12:00:00-06','confirmada','Lavado de motor'),
  (4,4,4,'2026-11-11 08:30:00-06','pendiente','Encerado'),
  (5,5,5,'2026-11-11 11:00:00-06','atendida','Aspirado interior'),
  (6,6,6,'2026-11-12 09:15:00-06','confirmada','Desinfección con ozono'),
  (7,7,7,'2026-11-12 13:00:00-06','cancelada','Cliente reprogramó'),
  (8,8,8,'2026-11-13 10:00:00-06','pendiente','Paquete completo'),
  (9,9,9,'2026-11-13 15:30:00-06','confirmada','Lavado de chasis'),
  (10,10,10,'2026-11-14 08:00:00-06','pendiente','Lavado premium'),
  (11,11,11,'2026-11-14 12:45:00-06','no_asistio','No llegó'),
  (12,12,12,'2026-11-15 09:30:00-06','confirmada','Paquete completo')
on conflict (id) do nothing;

insert into lavado_autos.ordenes (id, cliente_id, vehiculo_id, empleado_id, fecha, estado, subtotal, descuento, total, observaciones) values
  (1,1,1,1,'2026-11-10 09:10:00-06','pagada',200.00,50.00,150.00,'Promoción de bienvenida'),
  (2,2,2,3,'2026-11-10 10:40:00-06','pagada',470.00,47.00,423.00,'Cliente frecuente'),
  (3,3,3,5,'2026-11-10 12:10:00-06','pagada',320.00,48.00,272.00,'Martes de lavado'),
  (4,4,4,7,'2026-09-15 10:00:00-06','pagada',550.00,165.00,385.00,'Promoción aniversario'),
  (5,5,5,9,'2026-06-20 12:30:00-06','pagada',530.00,95.40,434.60,'Día del padre'),
  (6,6,6,1,'2026-05-10 09:20:00-06','pagada',400.00,48.00,352.00,'Promo SUV'),
  (7,7,7,3,'2026-04-18 11:00:00-06','terminada',420.00,63.00,357.00,'Pago pendiente'),
  (8,8,8,5,'2026-07-05 10:15:00-06','terminada',800.00,64.00,736.00,'Pago pendiente'),
  (9,9,9,7,'2026-12-20 16:00:00-06','pagada',120.00,26.40,93.60,'Fin de año'),
  (10,10,10,9,'2026-03-15 09:00:00-06','pagada',180.00,36.00,144.00,'Paquete familiar'),
  (11,11,11,1,'2026-05-25 15:30:00-06','pagada',150.00,0.00,150.00,'Sin promoción'),
  (12,12,12,3,'2026-11-05 16:45:00-06','pagada',140.00,0.00,140.00,'Sin promoción')
on conflict (id) do nothing;

insert into lavado_autos.orden_detalle (id, orden_id, servicio_id, cantidad, precio_unitario, subtotal) values
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
  (20,12,9,1,140.00,140.00)
on conflict (id) do nothing;

insert into lavado_autos.pagos (id, orden_id, monto, metodo, fecha_pago, referencia, estado) values
  (1,1,150.00,'efectivo','2026-11-10 09:50:00-06',null,'aprobado'),
  (2,2,423.00,'tarjeta','2026-11-10 11:40:00-06','TXN-1001','aprobado'),
  (3,3,272.00,'efectivo','2026-11-10 13:00:00-06',null,'aprobado'),
  (4,4,385.00,'transferencia','2026-09-15 12:00:00-06','SPEI-2201','aprobado'),
  (5,5,434.60,'wallet','2026-06-20 14:10:00-06','WALLET-3301','aprobado'),
  (6,6,352.00,'tarjeta','2026-05-10 10:20:00-06','TXN-1002','aprobado'),
  (7,7,357.00,'efectivo',null,null,'pendiente'),
  (8,8,736.00,'transferencia',null,'SPEI-2202','pendiente'),
  (9,9,93.60,'tarjeta','2026-12-20 18:00:00-06','TXN-1003','aprobado'),
  (10,10,144.00,'efectivo','2026-03-15 09:45:00-06',null,'aprobado'),
  (11,11,150.00,'wallet','2026-05-25 16:30:00-06','WALLET-3302','aprobado'),
  (12,12,140.00,'tarjeta','2026-11-05 17:15:00-06','TXN-1004','aprobado')
on conflict (id) do nothing;

insert into lavado_autos.consumo_insumos (id, orden_id, insumo_id, cantidad, fecha) values
  (1,1,1,0.50,'2026-11-10 09:15:00-06'),
  (2,1,6,4.00,'2026-11-10 09:15:00-06'),
  (3,2,1,0.60,'2026-11-10 10:45:00-06'),
  (4,2,2,0.30,'2026-11-10 10:45:00-06'),
  (5,3,1,0.40,'2026-11-10 12:15:00-06'),
  (6,3,5,0.20,'2026-11-10 12:15:00-06'),
  (7,4,1,0.80,'2026-09-15 10:05:00-06'),
  (8,4,6,6.00,'2026-09-15 10:05:00-06'),
  (9,5,4,0.50,'2026-06-20 12:35:00-06'),
  (10,5,8,0.40,'2026-06-20 12:35:00-06'),
  (11,6,1,0.50,'2026-05-10 09:25:00-06'),
  (12,6,2,0.25,'2026-05-10 09:25:00-06'),
  (13,7,2,0.40,'2026-04-18 11:05:00-06'),
  (14,8,3,0.50,'2026-07-05 10:20:00-06')
on conflict (id) do nothing;

insert into lavado_autos.orden_promociones (orden_id, promocion_id) values
  (1,5),(2,2),(3,1),(4,7),(5,6),(6,4),(7,8),(8,9),(9,10),(10,3)
on conflict do nothing;

-- Sincronizar las secuencias de las columnas identity con los IDs insertados.
select setval(pg_get_serial_sequence('lavado_autos.clientes','id'), (select max(id) from lavado_autos.clientes));
select setval(pg_get_serial_sequence('lavado_autos.vehiculos','id'), (select max(id) from lavado_autos.vehiculos));
select setval(pg_get_serial_sequence('lavado_autos.servicios','id'), (select max(id) from lavado_autos.servicios));
select setval(pg_get_serial_sequence('lavado_autos.empleados','id'), (select max(id) from lavado_autos.empleados));
select setval(pg_get_serial_sequence('lavado_autos.insumos','id'), (select max(id) from lavado_autos.insumos));
select setval(pg_get_serial_sequence('lavado_autos.promociones','id'), (select max(id) from lavado_autos.promociones));
select setval(pg_get_serial_sequence('lavado_autos.citas','id'), (select max(id) from lavado_autos.citas));
select setval(pg_get_serial_sequence('lavado_autos.ordenes','id'), (select max(id) from lavado_autos.ordenes));
select setval(pg_get_serial_sequence('lavado_autos.orden_detalle','id'), (select max(id) from lavado_autos.orden_detalle));
select setval(pg_get_serial_sequence('lavado_autos.pagos','id'), (select max(id) from lavado_autos.pagos));
select setval(pg_get_serial_sequence('lavado_autos.consumo_insumos','id'), (select max(id) from lavado_autos.consumo_insumos));
