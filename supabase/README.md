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
