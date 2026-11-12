#!/usr/bin/env bash
# Crea una instancia MySQL propia (sin sudo) en el puerto 3307 con la base
# `lavado_autos` y el usuario `lavado_admin` / `123456`.
#
# Útil cuando no se puede usar el MySQL del sistema porque `root` usa
# auth_socket y Workbench conecta por TCP.
#
#   bash scripts/crear_instancia_mysql_lavado.sh
#
# La instancia se administra con:
#   systemctl --user status mysql-lavado
#   systemctl --user restart mysql-lavado
#   systemctl --user stop mysql-lavado
#
# Los datos se guardan en /var/tmp/mysql-lavado. No se usa el home porque el
# perfil AppArmor de Ubuntu para /usr/sbin/mysqld solo permite escribir en
# /var/lib/mysql, /tmp y /var/tmp. Si se borra esa carpeta, vuelve a ejecutar
# este script para recrear la base.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SQL_FILE="$ROOT_DIR/mysql/lavado_autos_mysql.sql"

PORT="${MYSQL_LAVADO_PORT:-3307}"
BASE="${MYSQL_LAVADO_BASE:-/var/tmp/mysql-lavado}"
DATA="$BASE/data"
RUN="$BASE/run"
LOGS="$BASE/logs"
SOCK="$RUN/mysql.sock"
PID="$RUN/mysql.pid"
ERRLOG="$LOGS/error.log"

ROOT_SECRET="$HOME/.secrets/mysql_lavado_root_password"
CLIENT_CNF="$BASE/client.cnf"

SERVICE_DIR="$HOME/.config/systemd/user"
SERVICE="$SERVICE_DIR/mysql-lavado.service"

APP_USER="lavado_admin"
APP_PASS="123456"
DB_NAME="lavado_autos"

if [ ! -f "$SQL_FILE" ]; then
  echo "ERROR: no se encontró $SQL_FILE" >&2
  exit 1
fi

mkdir -p "$BASE" "$DATA" "$RUN" "$LOGS" "$HOME/.secrets" "$SERVICE_DIR"
chmod 700 "$BASE" "$DATA" "$RUN" "$LOGS" "$HOME/.secrets"

# Contraseña de root de esta instancia (no la necesitas para Workbench)
if [ ! -s "$ROOT_SECRET" ]; then
  umask 077
  printf '%s\n' "$(openssl rand -hex 24)" > "$ROOT_SECRET"
fi
chmod 600 "$ROOT_SECRET"
ROOT_PW="$(tr -d '\r\n' < "$ROOT_SECRET")"

# Inicializar el datadir la primera vez
if [ -d "$DATA/mysql" ]; then
  echo "Datadir ya inicializado en $DATA"
elif [ -n "$(ls -A "$DATA" 2>/dev/null)" ]; then
  echo "ERROR: $DATA existe y no está vacío, pero no es un datadir de MySQL." >&2
  echo "Borra esa carpeta o usa MYSQL_LAVADO_BASE=/otra/ruta." >&2
  exit 1
else
  echo "Inicializando la instancia MySQL en $DATA..."
  if ! mysqld --no-defaults --initialize-insecure --datadir="$DATA" --log-error="$ERRLOG"; then
    echo "ERROR: falló la inicialización. Últimas líneas del log:" >&2
    tail -n 20 "$ERRLOG" >&2 || true
    exit 1
  fi
fi

# Archivo de credenciales para root (solo lo usa systemd y este script)
umask 077
cat > "$CLIENT_CNF" <<EOF
[client]
host=127.0.0.1
port=${PORT}
user=root
password=${ROOT_PW}
EOF
chmod 600 "$CLIENT_CNF"

# Servicio de usuario: arranca al iniciar sesión y se reinicia si falla
cat > "$SERVICE" <<EOF
[Unit]
Description=MySQL local para lavado_autos (puerto ${PORT})
After=network.target

[Service]
Type=simple
ExecStart=/usr/sbin/mysqld --no-defaults --datadir=${DATA} --socket=${SOCK} --port=${PORT} --bind-address=127.0.0.1 --pid-file=${PID} --log-error=${ERRLOG} --mysqlx=0
ExecStop=/usr/bin/mysqladmin --defaults-extra-file=${CLIENT_CNF} shutdown
Restart=on-failure
RestartSec=3

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable mysql-lavado.service >/dev/null
systemctl --user restart mysql-lavado.service

# Esperar a que responda; en la primera ejecución root no tiene contraseña.
# Nota: `mysqladmin ping` devuelve 0 aunque las credenciales fallen, por eso
# aquí se comprueba con una consulta real.
ROOT_EMPTY=0
READY=0
for i in $(seq 1 40); do
  if mysql --defaults-extra-file="$CLIENT_CNF" -e "select 1" >/dev/null 2>&1; then
    ROOT_EMPTY=0
    READY=1
    break
  fi
  if mysql --no-defaults -h 127.0.0.1 -P "$PORT" -u root -e "select 1" >/dev/null 2>&1; then
    ROOT_EMPTY=1
    READY=1
    break
  fi
  sleep 1
done

if [ "$READY" -ne 1 ]; then
  echo "ERROR: la instancia no respondió en el puerto $PORT." >&2
  echo "Revisa: $ERRLOG" >&2
  tail -n 20 "$ERRLOG" >&2 || true
  exit 1
fi

# Fijar contraseña de root la primera vez
if [ "$ROOT_EMPTY" -eq 1 ]; then
  mysql --no-defaults -h 127.0.0.1 -P "$PORT" -u root \
    -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PW}';"
fi

echo "Cargando la base ${DB_NAME}..."
mysql --defaults-extra-file="$CLIENT_CNF" < "$SQL_FILE" > /dev/null

echo "Creando el usuario ${APP_USER}..."
mysql --defaults-extra-file="$CLIENT_CNF" <<SQL
CREATE USER IF NOT EXISTS '${APP_USER}'@'localhost' IDENTIFIED BY '${APP_PASS}';
CREATE USER IF NOT EXISTS '${APP_USER}'@'127.0.0.1' IDENTIFIED BY '${APP_PASS}';
ALTER USER '${APP_USER}'@'localhost' IDENTIFIED BY '${APP_PASS}';
ALTER USER '${APP_USER}'@'127.0.0.1' IDENTIFIED BY '${APP_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${APP_USER}'@'localhost';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${APP_USER}'@'127.0.0.1';
FLUSH PRIVILEGES;
SQL

echo
echo "Verificando..."
mysql -h 127.0.0.1 -P "$PORT" -u "$APP_USER" -p"$APP_PASS" -D "$DB_NAME" -e "
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
echo "Listo. Conexión para MySQL Workbench:"
echo "  Host:            127.0.0.1"
echo "  Port:            ${PORT}"
echo "  User:            ${APP_USER}"
echo "  Password:        ${APP_PASS}"
echo "  Default Schema:  ${DB_NAME}"
echo
echo "Servicio: systemctl --user status mysql-lavado"
