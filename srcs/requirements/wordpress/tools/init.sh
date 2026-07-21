
wget https://wordpress.org/latest.tar.gz

tar -xzvf latest.tar.gz

rm latest.tar.gz

mkdir -p /var/www/html

mv wordpress/* /var/www/html/
