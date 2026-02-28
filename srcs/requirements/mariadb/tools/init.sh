#!/bin/bash
mysqld_safe &

until mysqladmin ping --silent; do 
  sleep 1
done

mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS wordpress;
CREATE USER IF NOT EXISTS 'znajdaou'@'%' IDENTIFIED BY '123';
GRANT ALL PRIVILEGES ON wordpress.* TO 'znajdaou'@'%';
FLUSH PRIVILEGES;
EOF

mysqladmin shutdown
exec mysqld_safe
