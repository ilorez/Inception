#!/bin/bash

# Generate self-signed TLS certificate
mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/nginx/ssl/key.pem \
	-out /etc/nginx/ssl/cert.pem \
	-subj "/CN=localhost/C=MA/ST=Ben_guerir/O=1337"

# Start NGINX in foreground
nginx -g "daemon off;"
