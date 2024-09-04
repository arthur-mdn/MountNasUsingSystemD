# MountSambaUsingSystemD

## Prérequis
Deux outils sont nécessaires pour tester et configurer un répertoire SAMBA.
```bash
sudo apt-get install smbclient cifs-utils
```
Puis clonez le repository
```bash
git clone https://github.com/arthur-mdn/MountSambaUsingSystemD.git
```

## Configuration

Se rendre dans le dossier du repository

```bash
cd MountSambaUsingSystemD
```

Dupliquer le fichier config.ini.default en config.ini 

```bash
cp config.ini.default config.ini
```

Modifier le fichier `config.ini`

```
nano config.ini
```

Et renseigner toutes les informations, selon les besoins

```ini
USERNAME=edissyum
PASSWORD='edissyum'
DOMAIN=edissyum
HOST=192.192.192.192
DIR='/edissyum/mem'
MOUNT_PATH='/mnt/edissyum/mem'
```

## Test

Avant de tenter le montage, nous allons nous assurer que les identifiants sont corrects en lancant un script de test.

```bash
sudo ./check.sh
```

Si vous voyez `smb: \>` cela signifie que la connexion est correctement établie. 

Vous pouvez poursuivre.

```bash
smb: \> exit
``` 

## Lancement

Une fois le test effectué, nous allons monter le répertoire en utilisant systemd.

```bash
sudo ./start.sh
```

Et voilà ! 

## Nettoyage

Si vous souhaitez démonter et supprimer le répertoire :
```bash
sudo ./clear.sh
```
