#!/bin/bash
set -e

# Initialize system DB if missing (before starting MariaDB).
# Start MariaDB in background.
# Wait until it responds.
# Run init.sql only once, using a marker file (not $DATADIR/mysql) to indicate it has run.

# Path to data dir
DATADIR="/var/lib/mysql"

mkdir -p "$DATADIR"
chown  -R mysql:mysql "$DATADIR" #change ownership to mariadb user


# Initialize system database if missing
if [ ! -d "$DATADIR/mysql" ]; then
    echo "📦 Initializing system database..."
    mariadb-install-db --user=mysql --datadir="$DATADIR"
fi

# Start MariaDB in safe mode in the background
mysqld_safe --datadir="$DATADIR" --bind-address=0.0.0.0 & #& runs the process in the background so the script can continue executing
pid="$!" #stores PID of the last background process (MariaDB) in the variable pid


# Wait until MariaDB responds
echo "Waiting for MariaDB to be ready..."
until mariadb -uroot -e "SELECT 1;" &>/dev/null; do #ries to connect to the database using the client mariadb, -uroot → login as root, -e "SELECT 1;" → run a trivial SQL query to check if the DB is alive, &>/dev/null → throw away both stdout and stderr (so logs don’t get spammed)
    sleep 2
done
echo "MariaDB is up!"


# If first run (fresh install), run init.sql
if [ ! -f "$DATADIR/.initialized" ]; then
    echo "Initializing database with init.sql..."
    mariadb -uroot <<-EOSQL
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS '${DB_NORMAL_USER}'@'%' IDENTIFIED BY '${DB_NORMAL_PW}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_NORMAL_USER}'@'%';

CREATE USER IF NOT EXISTS '${DB_ADMIN}'@'%' IDENTIFIED BY '${DB_ADMIN_PW}';
GRANT ALL PRIVILEGES ON *.* TO '${DB_ADMIN}'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;
EOSQL
	touch "$DATADIR/.initialized"
    echo "Initialization complete."
fi

# makes the script wait for MariaDB server process (the one we started in the background earlier
wait "$pid"