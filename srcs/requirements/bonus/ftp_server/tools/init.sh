#!/bin/bash
set -e

FTP_PASS=$(cat /run/secrets/ftp_password)

adduser --disabled-password --gecos "" --home "$FTP_HOME_DIR" --shell /bin/bash "$FTP_USER"
echo "$FTP_USER:$FTP_PASS" | chpasswd
chown -R "$FTP_USER":"$FTP_USER" "$FTP_HOME_DIR"
mkdir -p /var/run/vsftpd/empty
exec vsftpd /etc/vsftpd.conf