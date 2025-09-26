#!/bin/bash
set -e

# Use environment variables for DB connection
# Ensure working directory
mkdir -p /var/www/html
chown -R www-data:www-data /var/www/html
cd /var/www/html

#Download WordPress if not already present
if [ ! -f wp-config.php ]; then
    echo "📦 Downloading WordPress..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar

# Download WordPress core
	
    ./wp-cli.phar core download --allow-root

    # Create wp-config.php
	# db-host = container hosting the db
	# using normal user for wordpress to conect to db -> securituy
    ./wp-cli.phar config create \
        --dbname=$DB_NAME \
        --dbuser=$DB_NORMAL_USER \
        --dbpass=$DB_NORMAL_PW \
        --dbhost=mariadb \
        --allow-root

  # Install WordPress
	# admin here is WORDPRESS ADMIN:use normal wp user for this (new user also possible)
	#./wp-cli.phar cor gives you the ability to log into WordPress at /wp-admin and manage the site
    #ok and safe to use normal wp user for this (new user also possible)
	./wp-cli.phar core install \
        --url=$DOMAIN_NAME \
        --title="Inception" \
        --admin_user=$DB_NORMAL_USER \
        --admin_password=$DB_NORMAL_PW \
        --admin_email=$DP_NORMAL_MAIL \
        --allow-root
fi


# Start PHP-FPM
php-fpm8.2 -F