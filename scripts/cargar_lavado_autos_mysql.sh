#!/usr/bin/env bash
# Carga la base `lavado_autos` en el MySQL local y crea un usuario para
# MySQL Workbench. Debe ejecutarse desde tu terminal porque `sudo` pedirá
# tu contraseña.
#
#   bash scripts/cargar_lavado_autos_mysql.sh
#
# No imprime la contraseña. La guarda en:
#   ~/.secrets/mysql_lavado_admin_password  (permisos 600)

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SQL_FILE="$ROOT_DIR/mysql/lavado_autos_mysql.sql"
SECRET="$HOME/.secrets/mysql_lavado_admin_password"

DB_USER="lavado_admin"
DB_HOST="localhost"
DB_NAME="lavado_autos"

if [ ! -f "$SQL_FILE" ]; then
  echo "ERROR: no se encontró $SQL_FILE" >&2
  exit 1
fi

mkdir -p "$HOME/.secrets"
chmod 700 "$HOME/.secrets"

# Generar contraseña solo si no existe
if [ ! -s "$SECRET" ]; then
  umask 077
  printf '%s\n' "$(openssl rand -hex 24)" > "$SECRET"
  echo "Contraseña generada en $SECRET"
fi
chmod 600 "$SECRET"

PW="$(tr -d '\r\n' < "$SECRET")"
if [ -z "$PW" ]; then
  echo "ERROR: $SECRET está vacío." >&2
  exit 1
fi

TMP="$(mktemp)"
trap 'shred -u "$TMP" 2>/dev/null || rm -f "$TMP"' EXIT
chmod 600 "$TMP"

{
  cat "$SQL_FILE"

  cat <<SQL

-- ---------------------------------------------------------------------------
-- Usuario de MySQL Workbench
-- ---------------------------------------------------------------------------
CREATE USER IF NOT EXISTS '${DB_USER}'@'${DB_HOST}' IDENTIFIED BY '${PW}';
ALTER USER '${DB_USER}'@'${DB_HOST}' IDENTIFIED BY '${PW}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'${DB_HOST}';

-- Permiso de solo lectura para el MCP de OpenCode (opcional)
GRANT SELECT ON ${DB_NAME}.* TO 'mcp_user'@'localhost';

FLUSH PRIVILEGES;
SQL
} > "$TMP"

echo "Cargando la base '${DB_NAME}' y creando el usuario '${DB_USER}'..."
echo "Se pedirá tu contraseña de sudo."
sudo mysql < "$TMP" > /dev/null

echo
echo "Verificando la conexión y los datos..."
mysql -h 127.0.0.1 -P 3306 -u "$DB_USER" -p"$PW" -D "$DB_NAME" -e "
select 'clientes' as tabla, count(*) as filas from clientes
union all select 'vehiculos', count(*) from vehiculos
union all select 'servicios', count(*) from servicios
union all select 'empleados', count(*) from empleados
union all select 'insumos', count(*) from insumos
union all select 'promociones', count(*) from promociones
union all select 'citas', count(*) from citas
union all select 'ordenes', count(*) from ordenes
union all select 'orden_detalle', count(*) from orden_detalle
union all select 'pagos', count(*) from pagos
union all select 'consumo_insumos', count(*) from consumo_insumos
union all select 'orden_promociones', count(*) from orden_promociones
order by tabla;"

echo
echo "Listo. Datos para MySQL Workbench:"
echo "  Host:            127.0.0.1"
echo "  Port:            3306"
echo "  User:            ${DB_USER}"
echo "  Default Schema:  ${DB_NAME}"
echo "  Password:        cat $SECRET"
echo
echo "Abre Workbench, crea una conexión con esos datos y guarda la contraseña."
echo "El MCP de OpenCode también podrá leer el esquema (usuario mcp_user)."
