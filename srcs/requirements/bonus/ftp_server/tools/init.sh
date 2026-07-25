#!/bin/bash
set -e

FTP_PASS=$(cat /run/secrets/ftp_password)

# if user already exists, do not create it again
if id "$FTP_USER" &>/dev/null; then
    echo "User $FTP_USER already exists, skipping user creation."
else
  adduser --disabled-password --gecos "" --home "$FTP_HOME_DIR" --shell /bin/bash "$FTP_USER"
  echo "$FTP_USER:$FTP_PASS" | chpasswd
  chown -R "$FTP_USER":"$FTP_USER" "$FTP_HOME_DIR"
  mkdir -p /var/run/vsftpd/empty
fi


exec vsftpd  /etc/vsftpd.conf