#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "A lancer en root !"
  exit
fi

if [ ! -f config.ini ]; then
  echo "Veuillez créer et compléter le fichier config.ini"
  exit 1
fi

. config.ini

MAIN_DIR=$(echo "$DIR" | cut -d "/" -f 1)
USER_UID=$(id -u $SUDO_USER)
USER_GID=$(id -g $SUDO_USER)

mkdir -p "$MOUNT_PATH"

cat >/etc/systemd.cred.$DOMAIN << EOF
username=$USERNAME
password=$PASSWORD
domain=$DOMAIN
EOF

#echo "/etc/systemd.cred.$DOMAIN"

unit_name=$(systemd-escape -p --suffix=mount "$MOUNT_PATH")

cat > /etc/systemd/system/$unit_name <<EOF
[Unit]
Description=cifs mount script for $DIR
Requires=network-online.target
After=network-online.service

[Mount]
What=//$HOST/$DIR
Where=$MOUNT_PATH
Options=credentials=/etc/systemd.cred.$DOMAIN,uid=$USER_UID,gid=$USER_GID,file_mode=0770,dir_mode=0770
Type=cifs

[Install]
WantedBy=multi-user.target
EOF

# echo "/etc/systemd/system/$unit_name"

systemctl daemon-reload
systemctl enable $unit_name
systemctl start $unit_name
systemctl status $unit_name

