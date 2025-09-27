#!/bin/bash
set -e #exit immediately if anything fails

# Path to data dir
DATADIR="/var/lib/mysql"


#read docker secrets 
DB_NORMAL_PW=$(cat /run/secrets/db_normal_pw)
DB_ADMIN_PW=$(cat /run/secrets/db_admin_pw)

mkdir -p "$DATADIR"
chown  -R mysql:mysql "$DATADIR" #change ownership to mariadb user
chmod -R 700 "$DATADIR"

# Initialize system database if missing
if [ ! -d "$DATADIR/mysql" ]; then
    echo "Initializing system database..."
    gosu mysql mariadb-install-db --user=mysql --datadir="$DATADIR" --skip-log-bin
fi


# If first run (fresh install), run init.sql
if [ ! -f "$DATADIR/.initialized" ]; then
    echo "Initializing database..."

    gosu mysql mysqld  --user=mysql --datadir="$DATADIR" --bootstrap <<-EOSQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ADMIN_PW}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${DB_ADMIN_PW}' WITH GRANT OPTION;

CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS '${DB_NORMAL_USER}'@'%' IDENTIFIED BY '${DB_NORMAL_PW}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_NORMAL_USER}'@'%';

CREATE USER IF NOT EXISTS '${DB_ADMIN}'@'%' IDENTIFIED BY '${DB_ADMIN_PW}';
GRANT ALL PRIVILEGES ON *.* TO '${DB_ADMIN}'@'%' WITH GRANT OPTION;

ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ADMIN_PW}';

FLUSH PRIVILEGES;
EOSQL


	touch "$DATADIR/.initialized"
    echo "Initialization complete."
fi

echo "Starting MariaDB ..."
exec gosu mysql mysqld --datadir="$DATADIR" --user=mysql --bind-address=0.0.0.0