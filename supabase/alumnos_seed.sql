-- ============================================================
-- Datos de ejemplo — esquema alumnos
-- 226 filas. Idempotente: usa on conflict do nothing.
-- Ejecutar después de alumnos_schema.sql
-- ============================================================

begin;

insert into alumnos.niveles (id, nombre, descripcion) values
(1, 'Primaria', 'Educación básica, 6 grados'),
(2, 'Secundaria', 'Educación básica, 3 grados'),
(3, 'Bachillerato', 'Educación media superior, 3 grados')
on conflict (id) do nothing;

insert into alumnos.grados (id, nivel_id, nombre, orden) values
(1, 1, '1° Primaria', 1),
(2, 1, '2° Primaria', 2),
(3, 2, '1° Secundaria', 1),
(4, 2, '2° Secundaria', 2),
(5, 3, '1° Bachillerato', 1)
on conflict (id) do nothing;

insert into alumnos.aulas (id, nombre, capacidad, ubicacion) values
(1, 'A-101', 30, 'Planta baja'),
(2, 'A-102', 30, 'Planta baja'),
(3, 'B-201', 35, 'Primer piso'),
(4, 'LAB-1', 25, 'Laboratorio de ciencias')
on conflict (id) do nothing;

insert into alumnos.tutores (id, nombre, apellido, parentesco, email, telefono, direccion) values
(1, 'María', 'López', 'Madre', 'maria.lopez@example.com', '555-100-1001', 'Av. Reforma 101'),
(2, 'José', 'Pérez', 'Padre', 'jose.perez@example.com', '555-100-1002', 'Calle Hidalgo 202'),
(3, 'Ana', 'García', 'Madre', 'ana.garcia@example.com', '555-100-1003', 'Av. Juárez 303'),
(4, 'Carlos', 'Ruiz', 'Padre', 'carlos.ruiz@example.com', '555-100-1004', 'Calle Allende 404'),
(5, 'Laura', 'Sánchez', 'Madre', 'laura.sanchez@example.com', '555-100-1005', 'Av. Constitución 505')
on conflict (id) do nothing;

insert into alumnos.profesores (id, nombre, apellido, email, telefono, especialidad, fecha_ingreso, activo) values
(1, 'Laura', 'Méndez', 'laura.mendez@colegio.example', '555-200-2001', 'Matemáticas', '2018-08-15', true),
(2, 'Pedro', 'Castillo', 'pedro.castillo@colegio.example', '555-200-2002', 'Español', '2019-08-20', true),
(3, 'Sofía', 'Ramírez', 'sofia.ramirez@colegio.example', '555-200-2003', 'Ciencias Naturales', '2020-01-10', true),
(4, 'Miguel', 'Torres', 'miguel.torres@colegio.example', '555-200-2004', 'Historia', '2017-08-01', true),
(5, 'Elena', 'Vargas', 'elena.vargas@colegio.example', '555-200-2005', 'Inglés', '2021-08-15', true)
on conflict (id) do nothing;

insert into alumnos.alumnos (id, matricula, nombre, apellido, fecha_nacimiento, email, telefono, direccion, grado_id, aula_id, fecha_inscripcion, activo) values
(1, 'MAT-2026-001', 'Ana', 'López', '2015-03-12', 'ana.lopez@alumno.example', '555-300-3001', 'Av. Reforma 101', 1, 1, '2026-08-20', true),
(2, 'MAT-2026-002', 'Luis', 'Pérez', '2015-07-08', 'luis.perez@alumno.example', '555-300-3002', 'Calle Hidalgo 202', 1, 1, '2026-08-20', true),
(3, 'MAT-2026-003', 'María', 'García', '2014-11-21', 'maria.garcia@alumno.example', '555-300-3003', 'Av. Juárez 303', 2, 2, '2026-08-20', true),
(4, 'MAT-2026-004', 'Diego', 'Ruiz', '2013-01-30', 'diego.ruiz@alumno.example', '555-300-3004', 'Calle Allende 404', 3, 3, '2026-08-20', true),
(5, 'MAT-2026-005', 'Sofía', 'Sánchez', '2012-05-17', 'sofia.sanchez@alumno.example', '555-300-3005', 'Av. Constitución 505', 3, 3, '2026-08-20', true),
(6, 'MAT-2026-006', 'Carlos', 'Méndez', '2011-09-09', 'carlos.mendez@alumno.example', '555-300-3006', 'Calle Morelos 606', 4, 3, '2026-08-20', true),
(7, 'MAT-2026-007', 'Lucía', 'Torres', '2010-12-02', 'lucia.torres@alumno.example', '555-300-3007', 'Av. Independencia 707', 5, 4, '2026-08-20', true),
(8, 'MAT-2026-008', 'Jorge', 'Ramírez', '2010-04-25', 'jorge.ramirez@alumno.example', '555-300-3008', 'Calle Zaragoza 808', 5, 4, '2026-08-20', true)
on conflict (id) do nothing;

insert into alumnos.alumno_tutor (alumno_id, tutor_id, es_principal) values
(1, 1, true),
(1, 2, false),
(2, 2, true),
(2, 1, false),
(3, 3, true),
(4, 4, true),
(5, 5, true),
(6, 2, true),
(7, 3, true),
(8, 4, true)
on conflict do nothing;

insert into alumnos.materias (id, nombre, descripcion, creditos) values
(1, 'Matemáticas', 'Aritmética, álgebra y geometría', 4),
(2, 'Español', 'Lengua y literatura', 4),
(3, 'Ciencias Naturales', 'Biología, física y química básica', 3),
(4, 'Historia', 'Historia nacional y universal', 3),
(5, 'Inglés', 'Comprensión y producción en inglés', 3),
(6, 'Educación Física', 'Actividad física y deporte', 2)
on conflict (id) do nothing;

insert into alumnos.materia_nivel (materia_id, nivel_id) values
(1, 1),
(1, 2),
(1, 3),
(2, 1),
(2, 2),
(2, 3),
(3, 1),
(3, 2),
(4, 2),
(4, 3),
(5, 1),
(5, 2),
(5, 3),
(6, 1),
(6, 2),
(6, 3)
on conflict do nothing;

insert into alumnos.cursos (id, materia_id, profesor_id, grado_id, aula_id, ciclo_escolar, seccion, capacidad) values
(1, 1, 1, 1, 1, '2026-2027', 'A', 30),
(2, 2, 2, 1, 1, '2026-2027', 'A', 30),
(3, 3, 3, 1, 2, '2026-2027', 'A', 30),
(4, 1, 1, 2, 2, '2026-2027', 'A', 30),
(5, 2, 2, 2, 2, '2026-2027', 'A', 30),
(6, 1, 1, 3, 3, '2026-2027', 'A', 35),
(7, 4, 4, 3, 3, '2026-2027', 'A', 35),
(8, 5, 5, 3, 2, '2026-2027', 'A', 30),
(9, 1, 1, 5, 4, '2026-2027', 'A', 25),
(10, 4, 4, 5, 4, '2026-2027', 'A', 25),
(11, 1, 1, 4, 3, '2026-2027', 'A', 35),
(12, 4, 4, 4, 3, '2026-2027', 'A', 35)
on conflict (id) do nothing;

insert into alumnos.inscripciones (id, alumno_id, curso_id, fecha_inscripcion, estado) values
(1, 1, 1, '2026-08-20', 'activa'),
(2, 1, 2, '2026-08-20', 'activa'),
(3, 1, 3, '2026-08-20', 'activa'),
(4, 2, 1, '2026-08-20', 'activa'),
(5, 2, 2, '2026-08-20', 'activa'),
(6, 2, 3, '2026-08-20', 'activa'),
(7, 3, 4, '2026-08-20', 'activa'),
(8, 3, 5, '2026-08-20', 'activa'),
(9, 4, 6, '2026-08-20', 'activa'),
(10, 4, 7, '2026-08-20', 'activa'),
(11, 4, 8, '2026-08-20', 'activa'),
(12, 5, 6, '2026-08-20', 'activa'),
(13, 5, 7, '2026-08-20', 'activa'),
(14, 5, 8, '2026-08-20', 'activa'),
(15, 6, 11, '2026-08-20', 'activa'),
(16, 6, 12, '2026-08-20', 'activa'),
(17, 7, 9, '2026-08-20', 'activa'),
(18, 7, 10, '2026-08-20', 'activa'),
(19, 8, 9, '2026-08-20', 'activa'),
(20, 8, 10, '2026-08-20', 'activa')
on conflict (id) do nothing;

insert into alumnos.horarios (id, curso_id, dia_semana, hora_inicio, hora_fin, salon) values
(1, 1, 1, '08:00', '09:30', 'A-101'),
(2, 1, 3, '08:00', '09:30', 'A-101'),
(3, 2, 1, '09:30', '11:00', 'A-101'),
(4, 2, 3, '09:30', '11:00', 'A-101'),
(5, 3, 2, '08:00', '09:30', 'A-102'),
(6, 3, 4, '08:00', '09:30', 'A-102'),
(7, 4, 1, '08:00', '09:30', 'A-102'),
(8, 4, 3, '08:00', '09:30', 'A-102'),
(9, 5, 1, '09:30', '11:00', 'A-102'),
(10, 5, 3, '09:30', '11:00', 'A-102'),
(11, 6, 2, '08:00', '09:30', 'B-201'),
(12, 6, 4, '08:00', '09:30', 'B-201'),
(13, 7, 2, '09:30', '11:00', 'B-201'),
(14, 7, 4, '09:30', '11:00', 'B-201'),
(15, 8, 5, '08:00', '09:30', 'A-102'),
(16, 8, 5, '09:30', '11:00', 'A-102'),
(17, 9, 1, '07:00', '08:30', 'LAB-1'),
(18, 9, 3, '07:00', '08:30', 'LAB-1'),
(19, 10, 2, '07:00', '08:30', 'LAB-1'),
(20, 10, 4, '07:00', '08:30', 'LAB-1'),
(21, 11, 1, '10:00', '11:30', 'B-201'),
(22, 11, 3, '10:00', '11:30', 'B-201'),
(23, 12, 2, '10:00', '11:30', 'B-201'),
(24, 12, 4, '10:00', '11:30', 'B-201')
on conflict (id) do nothing;

insert into alumnos.calificaciones (id, inscripcion_id, evaluacion, calificacion, fecha_evaluacion, observaciones) values
(1, 1, 'Parcial 1', 7.2, '2026-10-15', null),
(2, 1, 'Parcial 2', 7.6, '2026-11-20', null),
(3, 2, 'Parcial 1', 7.9, '2026-10-15', null),
(4, 2, 'Parcial 2', 8.7, '2026-11-20', null),
(5, 3, 'Parcial 1', 8.6, '2026-10-15', null),
(6, 3, 'Parcial 2', 9.8, '2026-11-20', null),
(7, 4, 'Parcial 1', 9.3, '2026-10-15', null),
(8, 4, 'Parcial 2', 7.4, '2026-11-20', null),
(9, 5, 'Parcial 1', 6.5, '2026-10-15', null),
(10, 5, 'Parcial 2', 8.5, '2026-11-20', null),
(11, 6, 'Parcial 1', 7.2, '2026-10-15', null),
(12, 6, 'Parcial 2', 9.6, '2026-11-20', null),
(13, 7, 'Parcial 1', 7.9, '2026-10-15', null),
(14, 7, 'Parcial 2', 7.2, '2026-11-20', null),
(15, 8, 'Parcial 1', 8.6, '2026-10-15', null),
(16, 8, 'Parcial 2', 8.3, '2026-11-20', null),
(17, 9, 'Parcial 1', 9.3, '2026-10-15', null),
(18, 9, 'Parcial 2', 9.4, '2026-11-20', null),
(19, 10, 'Parcial 1', 6.5, '2026-10-15', null),
(20, 10, 'Parcial 2', 7.0, '2026-11-20', null),
(21, 11, 'Parcial 1', 7.2, '2026-10-15', null),
(22, 11, 'Parcial 2', 8.1, '2026-11-20', null),
(23, 12, 'Parcial 1', 7.9, '2026-10-15', null),
(24, 12, 'Parcial 2', 9.2, '2026-11-20', null),
(25, 13, 'Parcial 1', 8.6, '2026-10-15', null),
(26, 13, 'Parcial 2', 6.8, '2026-11-20', null),
(27, 14, 'Parcial 1', 9.3, '2026-10-15', null),
(28, 14, 'Parcial 2', 7.9, '2026-11-20', null),
(29, 15, 'Parcial 1', 6.5, '2026-10-15', null),
(30, 15, 'Parcial 2', 9.0, '2026-11-20', null),
(31, 16, 'Parcial 1', 7.2, '2026-10-15', null),
(32, 16, 'Parcial 2', 6.6, '2026-11-20', null),
(33, 17, 'Parcial 1', 7.9, '2026-10-15', null),
(34, 17, 'Parcial 2', 7.7, '2026-11-20', null),
(35, 18, 'Parcial 1', 8.6, '2026-10-15', null),
(36, 18, 'Parcial 2', 8.8, '2026-11-20', null),
(37, 19, 'Parcial 1', 9.3, '2026-10-15', null),
(38, 19, 'Parcial 2', 9.9, '2026-11-20', null),
(39, 20, 'Parcial 1', 6.5, '2026-10-15', null),
(40, 20, 'Parcial 2', 7.5, '2026-11-20', null)
on conflict (id) do nothing;

insert into alumnos.asistencias (id, inscripcion_id, fecha, estado, observaciones) values
(1, 1, '2026-10-01', 'presente', null),
(2, 1, '2026-10-02', 'presente', null),
(3, 1, '2026-10-05', 'presente', null),
(4, 2, '2026-10-01', 'presente', null),
(5, 2, '2026-10-02', 'presente', null),
(6, 2, '2026-10-05', 'presente', null),
(7, 3, '2026-10-01', 'presente', null),
(8, 3, '2026-10-02', 'presente', null),
(9, 3, '2026-10-05', 'presente', null),
(10, 4, '2026-10-01', 'presente', null),
(11, 4, '2026-10-02', 'presente', null),
(12, 4, '2026-10-05', 'presente', null),
(13, 5, '2026-10-01', 'presente', null),
(14, 5, '2026-10-02', 'presente', null),
(15, 5, '2026-10-05', 'presente', null),
(16, 6, '2026-10-01', 'presente', null),
(17, 6, '2026-10-02', 'presente', null),
(18, 6, '2026-10-05', 'presente', null),
(19, 7, '2026-10-01', 'presente', null),
(20, 7, '2026-10-02', 'presente', null),
(21, 7, '2026-10-05', 'presente', null),
(22, 8, '2026-10-01', 'presente', null),
(23, 8, '2026-10-02', 'presente', null),
(24, 8, '2026-10-05', 'presente', null),
(25, 9, '2026-10-01', 'presente', null),
(26, 9, '2026-10-02', 'presente', null),
(27, 9, '2026-10-05', 'tarde', null),
(28, 10, '2026-10-01', 'presente', null),
(29, 10, '2026-10-02', 'tarde', null),
(30, 10, '2026-10-05', 'presente', null),
(31, 11, '2026-10-01', 'tarde', null),
(32, 11, '2026-10-02', 'presente', null),
(33, 11, '2026-10-05', 'presente', null),
(34, 12, '2026-10-01', 'presente', null),
(35, 12, '2026-10-02', 'presente', null),
(36, 12, '2026-10-05', 'presente', null),
(37, 13, '2026-10-01', 'presente', null),
(38, 13, '2026-10-02', 'presente', null),
(39, 13, '2026-10-05', 'presente', null),
(40, 14, '2026-10-01', 'presente', null),
(41, 14, '2026-10-02', 'presente', null),
(42, 14, '2026-10-05', 'presente', null),
(43, 15, '2026-10-01', 'presente', null),
(44, 15, '2026-10-02', 'presente', null),
(45, 15, '2026-10-05', 'ausente', null),
(46, 16, '2026-10-01', 'presente', null),
(47, 16, '2026-10-02', 'ausente', null),
(48, 16, '2026-10-05', 'presente', null),
(49, 17, '2026-10-01', 'ausente', null),
(50, 17, '2026-10-02', 'presente', null),
(51, 17, '2026-10-05', 'justificada', null),
(52, 18, '2026-10-01', 'presente', null),
(53, 18, '2026-10-02', 'justificada', null),
(54, 18, '2026-10-05', 'presente', null),
(55, 19, '2026-10-01', 'justificada', null),
(56, 19, '2026-10-02', 'presente', null),
(57, 19, '2026-10-05', 'presente', null),
(58, 20, '2026-10-01', 'presente', null),
(59, 20, '2026-10-02', 'presente', null),
(60, 20, '2026-10-05', 'tarde', null)
on conflict (id) do nothing;

insert into alumnos.pagos (id, alumno_id, ciclo_escolar, concepto, monto, fecha_vencimiento, fecha_pago, metodo_pago, estado, referencia) values
(1, 1, '2026-2027', 'Colegiatura agosto', 1500.0, '2026-08-10', '2026-08-05', 'transferencia', 'pagado', 'PAG-001'),
(2, 2, '2026-2027', 'Colegiatura agosto', 1500.0, '2026-08-10', '2026-08-09', 'efectivo', 'pagado', 'PAG-002'),
(3, 3, '2026-2027', 'Colegiatura septiembre', 1500.0, '2026-09-10', '2026-09-08', 'tarjeta', 'pagado', 'PAG-003'),
(4, 4, '2026-2027', 'Colegiatura agosto', 1800.0, '2026-08-10', null, null, 'pendiente', null),
(5, 5, '2026-2027', 'Colegiatura agosto', 1800.0, '2026-08-10', '2026-08-07', 'transferencia', 'pagado', 'PAG-005'),
(6, 6, '2026-2027', 'Colegiatura septiembre', 1800.0, '2026-09-10', null, null, 'pendiente', null),
(7, 7, '2026-2027', 'Colegiatura agosto', 2200.0, '2026-08-10', '2026-08-06', 'tarjeta', 'pagado', 'PAG-007'),
(8, 8, '2026-2027', 'Colegiatura agosto', 2200.0, '2026-08-10', '2026-08-10', 'efectivo', 'pagado', 'PAG-008')
on conflict (id) do nothing;

-- Sincronizar secuencias de identidad

select setval(pg_get_serial_sequence('alumnos.niveles', 'id'), coalesce((select max(id) from alumnos.niveles), 1), true);

select setval(pg_get_serial_sequence('alumnos.grados', 'id'), coalesce((select max(id) from alumnos.grados), 1), true);

select setval(pg_get_serial_sequence('alumnos.aulas', 'id'), coalesce((select max(id) from alumnos.aulas), 1), true);

select setval(pg_get_serial_sequence('alumnos.tutores', 'id'), coalesce((select max(id) from alumnos.tutores), 1), true);

select setval(pg_get_serial_sequence('alumnos.profesores', 'id'), coalesce((select max(id) from alumnos.profesores), 1), true);

select setval(pg_get_serial_sequence('alumnos.alumnos', 'id'), coalesce((select max(id) from alumnos.alumnos), 1), true);

select setval(pg_get_serial_sequence('alumnos.materias', 'id'), coalesce((select max(id) from alumnos.materias), 1), true);

select setval(pg_get_serial_sequence('alumnos.cursos', 'id'), coalesce((select max(id) from alumnos.cursos), 1), true);

select setval(pg_get_serial_sequence('alumnos.inscripciones', 'id'), coalesce((select max(id) from alumnos.inscripciones), 1), true);

select setval(pg_get_serial_sequence('alumnos.horarios', 'id'), coalesce((select max(id) from alumnos.horarios), 1), true);

select setval(pg_get_serial_sequence('alumnos.calificaciones', 'id'), coalesce((select max(id) from alumnos.calificaciones), 1), true);

select setval(pg_get_serial_sequence('alumnos.asistencias', 'id'), coalesce((select max(id) from alumnos.asistencias), 1), true);

select setval(pg_get_serial_sequence('alumnos.pagos', 'id'), coalesce((select max(id) from alumnos.pagos), 1), true);


commit;
