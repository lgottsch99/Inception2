-- Create WordPress database
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- WordPress user (used by wordpress container)
CREATE USER IF NOT EXISTS '${DB_NORMAL_USER}'@'%' IDENTIFIED BY '${DB_NORMAL_PW}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_NORMAL_USER}'@'%';

-- Administrator user (custom admin for db mgmt), % → allows connections from any hos
CREATE USER IF NOT EXISTS '${DB_ADMIN}'@'%' IDENTIFIED BY '${DB_ADMIN_PW}';
GRANT ALL PRIVILEGES ON *.* TO '${DB_ADMIN}'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;
