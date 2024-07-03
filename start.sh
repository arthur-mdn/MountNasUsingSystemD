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

# Définir les chemins de montage
MOUNT_PATH_NAS_DOCUMENTS=/mnt/NAS_Documents
MOUNT_PATH_NAS_PUBLIC=/mnt/NAS_Public
MOUNT_PATH_NAS_VMS=/mnt/NAS_VMS

# Créer les répertoires de montage
mkdir -p "$MOUNT_PATH_NAS_DOCUMENTS" "$MOUNT_PATH_NAS_PUBLIC" "$MOUNT_PATH_NAS_VMS"

# Créer fichier credentials
cat >/etc/systemd.cred.edissyum-nas << EOF
username=$USERNAME
password=$PASSWORD
domain=$DOMAIN
EOF

# sudo mount -t cifs //192.168.10.10/Documents /mnt/NAS_Documents -o credentials=/etc/systemd.cred.edissyum-nas


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
Options=credentials=/etc/systemd.cred.edissyum-nas
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
