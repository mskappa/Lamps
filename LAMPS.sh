#!/bin/bash

echo ""
echo "Thanks for using LAMPS"
echo "LAMP service Spawner by msk"
echo ""
echo "This script helps to create a LAMP server in few minutes."
echo ""
echo "Configurations:"
echo "- Create the root path for the web service in var/www/"
echo ""
echo "Installed packages:"
echo "+ Apache"
echo "+ PHP"
echo ""

### Input the website name + extension
echo "Define the website name plus extension"
read -p "(Example: hello.com) " website
echo "Website name:" "$website"
echo ""

### Input the admin email address
ADMIN_EMAIL="vince.ajello@gmail.com"
echo "Define the admin email"
read -p "(Default: vince.ajello@gmail.com) " input_email
[ ! -z "$admin_email" ] && $ADMIN_EMAIL = $input_email
echo "Admin email: " "$ADMIN_EMAIL"
echo ""

### Define Variables
WEBSITE_URL=$website
ADMIN_EMAIL=$ADMIN_EMAIL
SERVICE_ROOT=/var/www/$WEBSITE_URL
SERVICE_PUBLIC_DIR=$SERVICE_ROOT/public
SERVICE_PRIVATE_DIR=$SERVICE_ROOT/required
APACHE_SITES_AVAIABLE_PATH=/etc/apache2/sites-available
VIRTUAL_HOST_CONFIG_FILENAME=$APACHE_SITES_AVAIABLE_PATH/$WEBSITE_URL.conf

### Create directories
sudo mkdir -p $SERVICE_PUBLIC_DIR
sudo mkdir -p $SERVICE_PRIVATE_DIR
sudo touch $SERVICE_PUBLIC_DIR/index.html
echo "LAMP service successfully spawned by LAMPS - <a href='https://github.com/mskappa/Lamps'>view on GitHub</a>" | sudo tee --append $SERVICE_PUBLIC_DIR/index.html
echo "Created service root in: "$SERVICE_ROOT
echo "Created public folder in: "$SERVICE_PUBLIC_DIR
echo "Created private folder in: "$SERVICE_PRIVATE_DIR
echo ""

## Update packages
sudo apt-get update
sudo apt-get upgrade -y
echo ""

## Installing Apache2
echo "Installing Apache2"
sudo apt-get install apache2 -y
echo ""

## Enabling Apache2 modules
echo "Enabling Apache Modules"
echo "ssl, rewrite"
sudo a2enmod ssl
sudo a2enmod rewrite
echo "Configuring virtual host"

## Disabling directory indexing globally
sudo a2dismod -f autoindex

## Disabling virtual host default configurations
sudo a2dissite 000-default.conf
sudo a2dissite default-ssl.conf

## Create the VirtualHost Configuration file for the service
sudo touch $VIRTUAL_HOST_CONFIG_FILENAME
echo '<VirtualHost *:80>' | sudo tee --append $VIRTUAL_HOST_CONFIG_FILENAME > /dev/null
echo 'ServerAdmin '$ADMIN_EMAIL | sudo tee --append $VIRTUAL_HOST_CONFIG_FILENAME > /dev/null
echo 'ServerName '$WEBSITE_URL | sudo tee --append $VIRTUAL_HOST_CONFIG_FILENAME > /dev/null
echo 'ServerAlias 'www.$WEBSITE_URL | sudo tee --append $VIRTUAL_HOST_CONFIG_FILENAME > /dev/null
echo 'DirectoryIndex index.html index.php' | sudo tee --append $VIRTUAL_HOST_CONFIG_FILENAME > /dev/null
echo 'DocumentRoot '$SERVICE_PUBLIC_DIR | sudo tee --append $VIRTUAL_HOST_CONFIG_FILENAME > /dev/null
echo '</VirtualHost>' | sudo tee --append $VIRTUAL_HOST_CONFIG_FILENAME > /dev/null

## Enable the VirtualHost configuration
sudo a2ensite $WEBSITE_URL.conf

## Reload apache configuration
sudo service apache2 reload

## Installing PHP
echo "Installing PHP"
sudo apt-get install -y php

# Adding index.php to test and show infos
sudo touch $SERVICE_PUBLIC_DIR/index.php
echo '<?php phpinfo(); phpinfo(INFO_MODULES); ?>' | sudo tee --append $SERVICE_PUBLIC_DIR/index.php > /dev/null

## Installing MariaDB
echo "Installing MariaDB"
sudo apt install -y mariadb-server

## Configure MariaDB
echo "Configuring MariaDB Instrallation"
sudo mysql_secure_installation
