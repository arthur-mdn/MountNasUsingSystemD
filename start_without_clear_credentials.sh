#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "A lancer en root !"
  exit 1
fi

# Installation des paquets nécessaires
apt-get install -y krb5-user cifs-utils keyutils

# Configuration de Kerberos
cat >/etc/krb5.conf <<EOF
[libdefaults]
    default_realm = EDISSYUM.LAN
    dns_lookup_kdc = true
    dns_lookup_realm = true

[realms]
    EDISSYUM.LAN = {
        kdc = 192.168.10.250
        admin_server = 192.168.10.250
    }

[domain_realm]
    .edissyum.lan = EDISSYUM.LAN
    edissyum.lan = EDISSYUM.LAN
EOF

# Obtenir un ticket Kerberos pour l'utilisateur
read -p "Entrez votre nom d'utilisateur Kerberos (sans domaine): " USERNAME_SHORT
USERNAME_FULL="${USERNAME_SHORT}@edissyum.lan"
kinit $USERNAME_SHORT

if [ $? -ne 0 ]; then
  echo "Échec de l'obtention du ticket Kerberos"
  exit 1
fi

# Ensure full username is used for UID and GID retrieval
if id -u "$USERNAME_FULL" > /dev/null 2>&1; then
  USER_UID=$(id -u "$USERNAME_FULL")
  USER_GID=$(id -g "$USERNAME_FULL")
else
  echo "Utilisateur inexistant: $USERNAME_FULL"
  exit 1
fi

# Get the Kerberos cache file path
KRB5CCNAME=$(klist | grep 'Ticket cache:' | awk '{print $3}')
KRB5CCPATH=$(echo $KRB5CCNAME | sed 's|FILE:||')

chown "$USER_UID:$USER_GID" "$KRB5CCPATH"
chmod 777 "$KRB5CCPATH"

# Vérifier si le ticket Kerberos est disponible
if ! klist -s; then
  echo "Aucun ticket Kerberos disponible"
  exit 1
fi

# Définir les chemins de montage
MOUNT_PATH_NAS_DOCUMENTS=/mnt/NAS_Documents
MOUNT_PATH_NAS_PUBLIC=/mnt/NAS_Public
MOUNT_PATH_NAS_VMS=/mnt/NAS_VMS

# Créer les répertoires de montage
mkdir -p "$MOUNT_PATH_NAS_DOCUMENTS" "$MOUNT_PATH_NAS_PUBLIC" "$MOUNT_PATH_NAS_VMS"

# Fonction pour arrêter et supprimer une unité de montage systemd si elle existe
remove_mount_unit() {
  local mount_path=$1
  local unit_name=$(systemd-escape -p --suffix=mount "$mount_path")

  if systemctl is-active --quiet $unit_name; then
    systemctl stop $unit_name
  fi

  if systemctl is-enabled --quiet $unit_name; then
    systemctl disable $unit_name
  fi

  rm -f /etc/systemd/system/$unit_name
}

# Fonction pour créer une unité de montage systemd
create_mount_unit() {
  local mount_path=$1
  local share_path=$2
  local unit_name=$(systemd-escape -p --suffix=mount "$mount_path")

  cat > /etc/systemd/system/$unit_name <<EOF
[Unit]
Description=cifs mount script for $share_path
Requires=network-online.target
After=network-online.service

[Mount]
What=$share_path
Where=$mount_path
Options=sec=krb5,cruid=$USER_UID,uid=$USER_UID,gid=$USER_GID,multiuser
Type=cifs

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable $unit_name
  systemctl start $unit_name
  systemctl status $unit_name
}

# Supprimer les unités de montage existantes
remove_mount_unit "$MOUNT_PATH_NAS_DOCUMENTS"
remove_mount_unit "$MOUNT_PATH_NAS_PUBLIC"
remove_mount_unit "$MOUNT_PATH_NAS_VMS"

# Créer les unités de montage
create_mount_unit "$MOUNT_PATH_NAS_DOCUMENTS" "//192.168.10.10/Documents"
create_mount_unit "$MOUNT_PATH_NAS_PUBLIC" "//192.168.10.10/Public"
create_mount_unit "$MOUNT_PATH_NAS_VMS" "//192.168.10.10/VMs"
