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

rm /etc/systemd.cred.$DOMAIN

unit_name=$(systemd-escape -p --suffix=mount "$MOUNT_PATH")

if systemctl is-active --quiet $unit_name; then
  systemctl stop $unit_name
fi

if systemctl is-enabled --quiet $unit_name; then
  systemctl disable $unit_name
fi

rm -f /etc/systemd/system/$unit_name

systemctl daemon-reload

