#!/bin/bash
set -e #exit immediately if anything fails

# Path to data dir
DATADIR="/var/lib/mysql"


#read docker secrets 
DB_NORMAL_PW=$(cat /run/secrets/db_normal_pw)
DB_ADMIN_PW=$(cat /run/secrets/db_admin_pw)

mkdir -p "$DATADIR"
chown  -R mysql:mysql "$DATADIR" #change ownership to mariadb user


# Initialize system database if missing
if [ ! -d "$DATADIR/mysql" ]; then
    echo "Initializing system database..."
    mariadb-install-db --user=mysql --datadir="$DATADIR"
fi


# If first run (fresh install), run init.sql
if [ ! -f "$DATADIR/.initialized" ]; then
    echo "Initializing database with init.sql..."

    mysqld --datadir="$DATADIR" --bootstrap <<-EOSQL
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


exec mysqld_safe --datadir="$DATADIR" --bind-address=0.0.0.0