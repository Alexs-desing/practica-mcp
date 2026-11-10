# Base de datos `alumnos` — institución educativa

Esquema PostgreSQL con **15 tablas**, **17 claves foráneas** y **226 filas** de ejemplo.
Validado sobre PostgreSQL 16: se ejecuta dos veces sin duplicar datos ni fallar.

## Archivos

| Archivo | Contenido |
|---|---|
| `alumnos_schema.sql` | `create schema`, 15 tablas, FK, checks, índices, índice único parcial y comentarios |
| `alumnos_seed.sql` | Datos de ejemplo (226 filas) + sincronización de secuencias |

## Ejecutar en Supabase

1. Entra a **https://supabase.com/dashboard/project/hwsranjhycayvmssqmgq**
2. **SQL Editor → New query**
3. Pega y ejecuta primero `alumnos_schema.sql`.
4. Crea otra consulta, pega y ejecuta `alumnos_seed.sql`.

Ambos scripts son idempotentes, así que puedes repetirlos sin miedo.

## Ejecutar en local con Docker

```bash
docker run -d --name alumnos_test -e POSTGRES_PASSWORD=test \
  -v "$PWD/supabase:/sql:ro" postgres:16

docker exec alumnos_test psql -U postgres -v ON_ERROR_STOP=1 -f /sql/alumnos_schema.sql
docker exec alumnos_test psql -U postgres -v ON_ERROR_STOP=1 -f /sql/alumnos_seed.sql

docker exec -it alumnos_test psql -U postgres
```

Dentro de `psql`:

```sql
\dt alumnos.*
select * from alumnos.alumnos;
```

## Modelo de datos

```text
niveles ──< grados ──< alumnos >── aulas
                         │
                         ├──< alumno_tutor >── tutores
                         ├──< inscripciones >── cursos
                         │            │
                         │            ├──< horarios
                         │            ├── materias ──< materia_nivel >── niveles
                         │            ├── profesores
                         │            └── grados / aulas
                         ├──< calificaciones (vía inscripciones)
                         ├──< asistencias     (vía inscripciones)
                         └──< pagos
```

Reglas destacadas:

- `alumno_tutor`: un alumno puede tener varios tutores, pero **solo uno principal**
  (índice único parcial `alumno_tutor_principal_uk`).
- `calificaciones.calificacion`: escala **0 a 10**.
- `horarios.dia_semana`: **1 = lunes** … 7 = domingo.
- `pagos`: si `estado = 'pagado'`, `fecha_pago` es obligatoria.
- Borrados: `cascade` en dependencias académicas, `restrict` en catálogos,
  `set null` en referencias opcionales a aulas.

## Consultas de verificación

```sql
-- Conteo por tabla
select 'niveles' as tabla, count(*) from alumnos.niveles
union all select 'alumnos', count(*) from alumnos.alumnos
union all select 'cursos', count(*) from alumnos.cursos
union all select 'calificaciones', count(*) from alumnos.calificaciones
union all select 'pagos', count(*) from alumnos.pagos;

-- Alumnos con nivel, grado y aula
select a.matricula, a.nombre || ' ' || a.apellido as alumno,
       n.nombre as nivel, g.nombre as grado, au.nombre as aula
from alumnos.alumnos a
join alumnos.grados g  on g.id = a.grado_id
join alumnos.niveles n on n.id = g.nivel_id
left join alumnos.aulas au on au.id = a.aula_id
order by a.matricula;

-- Promedio por alumno
select a.matricula,
       round(avg(c.calificacion), 2) as promedio
from alumnos.alumnos a
join alumnos.inscripciones i on i.alumno_id = a.id
join alumnos.calificaciones c on c.inscripcion_id = i.id
group by a.matricula
order by a.matricula;

-- Estado de cuenta
select estado, count(*) as pagos, sum(monto)::numeric(12,2) as total
from alumnos.pagos
group by estado;
```

## Dónde ver la base

| Vía | Ruta |
|---|---|
| Table Editor | Dashboard → **Table Editor** → selector de esquema → `alumnos` |
| SQL Editor | Dashboard → **SQL Editor** → `select * from alumnos.alumnos;` |
| Diagrama | Dashboard → **Database** → **Schema Visualizer** |
| Cliente externo | **Project Settings → Database → Connection string** (DBeaver, pgAdmin, psql…) |

> El esquema `alumnos` **no se expone** en la API REST por defecto. Para usar
> `supabase-js` hay que añadirlo en **Project Settings → API → Exposed schemas**
> y definir políticas RLS.

---

# Base de datos `lavado_autos` — negocio de lavado de autos

Segundo esquema del mismo proyecto Supabase. Tiene **12 tablas**, **13 claves
foráneas** y **144 filas** de ejemplo, todas relacionadas entre sí.

## Archivos

| Archivo | Contenido |
|---|---|
| `lavado_autos_schema.sql` | `create schema`, 12 tablas, FK, checks, índices y comentarios |
| `lavado_autos_seed.sql` | Datos de ejemplo (144 filas) + sincronización de secuencias |

## Modelo de datos

```text
clientes ──< vehiculos ──< citas
    │            │
    │            └──< ordenes >── empleados
    │                    │
    │                    ├──< orden_detalle >── servicios
    │                    ├──< pagos
    │                    ├──< consumo_insumos >── insumos
    │                    └──< orden_promociones >── promociones
    └────────────────────┘
```

Reglas destacadas:

- `ordenes.total <= subtotal` y `total = subtotal - descuento`.
- `pagos` con `estado = 'aprobado'` exige `fecha_pago`.
- `orden_detalle` no repite el mismo servicio en una orden.
- `consumo_insumos` no repite el mismo insumo en una orden.
- Borrados: `cascade` en dependencias de la orden, `restrict` en catálogos.

## Filas por tabla

| Tabla | Filas |
|---|---:|
| `clientes` | 12 |
| `vehiculos` | 12 |
| `servicios` | 10 |
| `empleados` | 10 |
| `insumos` | 10 |
| `promociones` | 10 |
| `citas` | 12 |
| `ordenes` | 12 |
| `orden_detalle` | 20 |
| `pagos` | 12 |
| `consumo_insumos` | 14 |
| `orden_promociones` | 10 |

## Consultas de verificación

```sql
-- Órdenes con cliente, vehículo, subtotal y total
select o.id,
       c.nombre || ' ' || c.apellido as cliente,
       v.placa, v.marca || ' ' || v.modelo as vehiculo,
       o.estado, o.subtotal, o.descuento, o.total
from lavado_autos.ordenes o
join lavado_autos.clientes c on c.id = o.cliente_id
join lavado_autos.vehiculos v on v.id = o.vehiculo_id
order by o.id;

-- Ingresos aprobados por método de pago
select metodo, count(*) as pagos, sum(monto)::numeric(12,2) as total
from lavado_autos.pagos
where estado = 'aprobado'
group by metodo
order by total desc;

-- Servicios más vendidos
select s.nombre, sum(d.cantidad) as veces, sum(d.subtotal) as importe
from lavado_autos.orden_detalle d
join lavado_autos.servicios s on s.id = d.servicio_id
group by s.nombre
order by importe desc;
```

## Dónde verlo

| Vía | Ruta |
|---|---|
| Table Editor | Dashboard → **Table Editor** → selector de esquema → `lavado_autos` |
| Database → Tables | Dashboard → **Database** → **Tables** → selector `lavado_autos` |
| Diagrama | Dashboard → **Database** → **Schema Visualizer** |
| SQL Editor | `select * from lavado_autos.ordenes;` |

> Las 12 tablas tienen **RLS desactivado**. No es urgente mientras el esquema no
> se exponga en la API, pero si lo agregas en **Project Settings → API →
> Exposed schemas**, activa RLS y crea políticas antes de usar la `anon key`.
