#!/bin/bash
set -e

# Starts mysqld_safe in the background.
# Waits until the DB server is ready.
# Runs init.sql only if the data folder (/var/lib/mysql/mysql) doesn’t exist yet.
# Then brings MariaDB to the foreground.

# Path to data dir
DATADIR="/var/lib/mysql"


# Start MariaDB in safe mode in the background
mysqld_safe --datadir="$DATADIR" & #& runs the process in the background so the script can continue executing
pid="$!" #stores PID of the last background process (MariaDB) in the variable pid


# If data dir is empty (fresh install), run init.sql
if [ ! -d "$DATADIR/mysql" ]; then
    echo "Initializing database with init.sql..."
    mariadb -uroot < /init.sql #runs init.sql cmds as root
    echo "Initialization complete."
fi

# Wait until MariaDB responds
echo "Waiting for MariaDB to be ready..."
until mariadb -uroot -e "SELECT 1;" &>/dev/null; do #ries to connect to the database using the client mariadb, -uroot → login as root, -e "SELECT 1;" → run a trivial SQL query to check if the DB is alive, &>/dev/null → throw away both stdout and stderr (so logs don’t get spammed)
    sleep 2
done
echo "MariaDB is up!"

# makes the script wait for MariaDB server process (the one we started in the background earlier
wait "$pid"