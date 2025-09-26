#!/bin/bash
set -e

# Use environment variables for DB connection
# Ensure working directory
echo "making dir ..."

mkdir -p /var/www/html
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
cd /var/www/html


# Wait for MariaDB to be ready
echo "Waiting for MariaDB..."
until mariadb -h mariadb -u$DB_NORMAL_USER -p$DB_NORMAL_PW -e "SELECT 1;" &>/dev/null; do
    echo "MariaDB not ready yet, retrying in 2s..."
    sleep 2
done
echo "MariaDB is ready!"



echo "checking if wp-config.php exists..."
#Download WordPress if not already present
if [ ! -f wp-config.php ]; then
    echo "📦 Downloading WordPress..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar

# Download WordPress core
	echo "download core..."

    ./wp-cli.phar core download --allow-root --force

echo "config create.."
    # Create wp-config.php
	# db-host = container hosting the db
	# using normal user for wordpress to conect to db -> securituy
    ./wp-cli.phar config create \
        --dbname=$DB_NAME \
        --dbuser=$DB_NORMAL_USER \
        --dbpass=$DB_NORMAL_PW \
        --dbhost=mariadb \
        --allow-root

echo "core install.."

  # Install WordPress
	# admin here is WORDPRESS ADMIN:use normal wp user for this (new user also possible)
	#./wp-cli.phar cor gives you the ability to log into WordPress at /wp-admin and manage the site
    #ok and safe to use normal wp user for this (new user also possible)
	./wp-cli.phar core install \
        --url=$DOMAIN_NAME \
        --title="Inception" \
        --admin_user=$DB_NORMAL_USER \
        --admin_password=$DB_NORMAL_PW \
        --admin_email=$DB_NORMAL_MAIL \
        --allow-root
fi

echo "running final cmd php fpm ..."
# Start PHP-FPM
php-fpm8.2 -F