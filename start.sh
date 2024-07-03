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

MOUNT_PATH_NAS_DOCUMENTS=/mnt/NAS_Documents
mkdir -p "$MOUNT_PATH_NAS_DOCUMENTS"

MOUNT_PATH_NAS_PUBLIC=/mnt/NAS_Public
mkdir -p "$MOUNT_PATH_NAS_PUBLIC"

MOUNT_PATH_NAS_VMS=/mnt/NAS_VMS
mkdir -p "$MOUNT_PATH_NAS_VMS"

# Créer fichier credentials
cat >/etc/systemd.cred.edissyum-nas << EOF
username=$USERNAME
password=$PASSWORD
domain=$DOMAIN
EOF

# sudo mount -t cifs //192.168.10.10/Documents /mnt/NAS_Documents -o credentials=/etc/systemd.cred.edissyum-nas

# Créer NAS_Documents
cat > /etc/systemd/system/$(systemd-escape -p --suffix=mount "$MOUNT_PATH_NAS_DOCUMENTS") <<EOF
[Unit]
Description=cifs mount script
Requires=network-online.target
After=network-online.service

[Mount]
What=//192.168.10.10/Documents
Where=$MOUNT_PATH_NAS_DOCUMENTS
Options=credentials=/etc/systemd.cred.edissyum-nas
Type=cifs

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable $(systemd-escape -p --suffix=mount "$MOUNT_PATH_NAS_DOCUMENTS")
systemctl start $(systemd-escape -p --suffix=mount "$MOUNT_PATH_NAS_DOCUMENTS")
systemctl status $(systemd-escape -p --suffix=mount "$MOUNT_PATH_NAS_DOCUMENTS")


# Créer NAS_Public
cat > /etc/systemd/system/$(systemd-escape -p --suffix=mount "$MOUNT_PATH_NAS_PUBLIC") <<EOF
[Unit]
Description=cifs mount script
Requires=network-online.target
After=network-online.service

[Mount]
What=//192.168.10.10/Public
Where=$MOUNT_PATH_NAS_PUBLIC
Options=credentials=/etc/systemd.cred.edissyum-nas
Type=cifs

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable $(systemd-escape -p --suffix=mount "$MOUNT_PATH_NAS_PUBLIC")
systemctl start $(systemd-escape -p --suffix=mount "$MOUNT_PATH_NAS_PUBLIC")
systemctl status $(systemd-escape -p --suffix=mount "$MOUNT_PATH_NAS_PUBLIC")


# Créer NAS_VMS
cat > /etc/systemd/system/$(systemd-escape -p --suffix=mount "$MOUNT_PATH_NAS_VMS") <<EOF
[Unit]
Description=cifs mount script
Requires=network-online.target
After=network-online.service

[Mount]
What=//192.168.10.10/VMs
Where=$MOUNT_PATH_NAS_VMS
Options=credentials=/etc/systemd.cred.edissyum-nas
Type=cifs

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable $(systemd-escape -p --suffix=mount "$MOUNT_PATH_NAS_VMS")
systemctl start $(systemd-escape -p --suffix=mount "$MOUNT_PATH_NAS_VMS")
systemctl status $(systemd-escape -p --suffix=mount "$MOUNT_PATH_NAS_VMS")
