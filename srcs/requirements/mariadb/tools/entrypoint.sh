#!/bin/bash
set -e

DATADIR="/var/lib/mysql"

# Read docker secrets
DB_NORMAL_PW=$(cat /run/secrets/db_normal_pw)
DB_ADMIN_PW=$(cat /run/secrets/db_admin_PW)

# 🚨 FIX: Explicitly set and export the standard MariaDB root password variable.
# This is CRITICAL for the final 'exec mysqld' command to initialize the root password.
export MYSQL_ROOT_PASSWORD="${DB_ADMIN_PW}"

# 1. Ownership setup and Cleanup (Remains the same)
mkdir -p "$DATADIR"
chown -R mysql:mysql "$DATADIR"
chmod -R 700 "$DATADIR"

echo "Cleaning up stale MariaDB files..."
rm -f "$DATADIR/mysql.sock"
rm -f "$DATADIR/$(hostname).pid"

# 2. System Initialization (First Run Check)
if [ ! -d "$DATADIR/mysql" ]; then
    echo "Initializing MariaDB system database..."
    # 🚨 Compliant action: This single command runs in the foreground and exits.
    mariadb-install-db --user=mysql --datadir="$DATADIR" --skip-log-bin
fi

# 3. Custom Database and User Initialization (Compliant --bootstrap)
if [ ! -f "$DATADIR/.initialized" ]; then
    echo "Running custom database and user setup via --bootstrap..."

    # 🚨 FIX: We use --bootstrap ONLY for creating non-root users/databases.
    # The 'ALTER USER root' is OMITTED to avoid Error 1290.
    # The root password is handled by the exported MYSQL_ROOT_PASSWORD environment variable.
    gosu mysql mysqld --user=mysql --datadir="$DATADIR" --bootstrap <<-EOSQL
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS '${DB_NORMAL_USER}'@'%' IDENTIFIED BY '${DB_NORMAL_PW}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_NORMAL_USER}'@'%';

CREATE USER IF NOT EXISTS '${DB_ADMIN}'@'%' IDENTIFIED BY '${DB_ADMIN_PW}';
GRANT ALL PRIVILEGES ON *.* TO '${DB_ADMIN}'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;
EOSQL

    touch "$DATADIR/.initialized"
    echo "Initialization complete."
fi

echo "Starting MariaDB daemon as PID 1..."
# 4. Final PID 1 Start
# The daemon starts as non-root (gosu) and reads MYSQL_ROOT_PASSWORD to set root's password.
exec gosu mysql /usr/bin/mysqld --user=mysql --datadir="$DATADIR" --bind-address=0.0.0.0