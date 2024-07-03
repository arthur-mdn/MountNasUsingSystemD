#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "A lancer en root !"
  exit 1
fi

# Installation des paquets nécessaires
apt-get install -y krb5-user samba cifs-utils

# Configuration de Kerberos
cat >/etc/krb5.conf <<EOF
[libdefaults]
    default_realm = EDISSYUM.LAN
    forwardable = true
    renewable = true

[realms]
    EDISSYUM.LAN = {
        kdc = dc1.edissyum.lan
        admin_server = dc1.edissyum.lan
    }

[domain_realm]
    .edissyum.lan = EDISSYUM.LAN
    edissyum.lan = EDISSYUM.LAN
EOF

# Obtenir un ticket Kerberos pour l'utilisateur
read -p "Entrez votre nom d'utilisateur Kerberos: " USERNAME
kinit $USERNAME

if [ $? -ne 0 ]; then
  echo "Échec de l'obtention du ticket Kerberos"
  exit 1
fi

# Définir les chemins de montage
MOUNT_PATH_NAS_DOCUMENTS=/mnt/NAS_Documents
MOUNT_PATH_NAS_PUBLIC=/mnt/NAS_Public
MOUNT_PATH_NAS_VMS=/mnt/NAS_VMS

# Créer les répertoires de montage
mkdir -p "$MOUNT_PATH_NAS_DOCUMENTS" "$MOUNT_PATH_NAS_PUBLIC" "$MOUNT_PATH_NAS_VMS"

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
Options=sec=krb5,multiuser
Type=cifs

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable $unit_name
  systemctl start $unit_name
  systemctl status $unit_name
}

# Créer les unités de montage
create_mount_unit "$MOUNT_PATH_NAS_DOCUMENTS" "//192.168.10.10/Documents"
create_mount_unit "$MOUNT_PATH_NAS_PUBLIC" "//192.168.10.10/Public"
create_mount_unit "$MOUNT_PATH_NAS_VMS" "//192.168.10.10/VMs"
