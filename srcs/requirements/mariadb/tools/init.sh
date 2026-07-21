#!/bin/bash

set -e 




if [ -n "$MYSQL_PASSWORD_FILE" ] && [ -f "$MYSQL_PASSWORD_FILE" ]; then
    MYSQL_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")
else
    echo "Error: MYSQL_PASSWORD_FILE=$MYSQL_PASSWORD_FILE is not set or the file does not exist."

    exit 1
fi

if [ -n "$MYSQL_ROOT_PASSWORD_FILE" ] && [ -f "$MYSQL_ROOT_PASSWORD_FILE" ]; then
    MYSQL_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
else
    echo "Error: MYSQL_ROOT_PASSWORD_FILE=$MYSQL_ROOT_PASSWORD_FILE is not set or the file does not exist."
    exit 1
fi


if [ ! -d "/var/lib/mysql/mysql" ]; then
    
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
# start mariadb server in the background and skip networking to avoid remote connections during initialization
    mysqld_safe --skip-networking &
    
    # wait for mariadb server to start
    until mysqladmin ping --silent; do 
      sleep 1
    done
    

    # create database and user
    mysql -u root <<EOF
    CREATE DATABASE IF NOT EXISTS '${MYSQL_DATABASE}';
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON '${MYSQL_DATABASE}'.* TO '${MYSQL_USER}'@'%';
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    FLUSH PRIVILEGES;
    EOF

    # stop mariadb server
    mysqladmin -u root shutdown
fi

exec mysqld_safe


# env should look like this:



