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

#echo "smbclient //$HOST/$MAIN_DIR -U $USERNAME --password $PASSWORD -W $DOMAIN"

smbclient //$HOST/$MAIN_DIR -U $USERNAME --password $PASSWORD -W $DOMAIN

