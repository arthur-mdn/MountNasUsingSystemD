#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "A lancer en root !"
  exit
fi

# Définir les chemins de montage
MOUNT_PATH_NAS_DOCUMENTS=/mnt/NAS_Documents
MOUNT_PATH_NAS_PUBLIC=/mnt/NAS_Public
MOUNT_PATH_NAS_VMS=/mnt/NAS_VMS

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

# Supprimer les unités de montage existantes
remove_mount_unit "$MOUNT_PATH_NAS_DOCUMENTS"
remove_mount_unit "$MOUNT_PATH_NAS_PUBLIC"
remove_mount_unit "$MOUNT_PATH_NAS_VMS"

# Recharger le daemon systemd pour appliquer les modifications
echo "Reloading systemd daemon..."
systemctl daemon-reload

# Vérifier si les répertoires de montage sont vides et les supprimer si c'est le cas
cleanup_mount_point() {
  local mount_path=$1

  if [ -d "$mount_path" ]; then
    if [ -z "$(ls -A "$mount_path")" ]; then
      echo "Removing empty mount point $mount_path..."
      rmdir "$mount_path"
    else
      echo "Mount point $mount_path is not empty, not removing."
    fi
  fi
}

cleanup_mount_point "$MOUNT_PATH_NAS_DOCUMENTS"
cleanup_mount_point "$MOUNT_PATH_NAS_PUBLIC"
cleanup_mount_point "$MOUNT_PATH_NAS_VMS"

echo "All specified mounts have been stopped and removed."
