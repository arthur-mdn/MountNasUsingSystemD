# MountSambaUsingSystemD

## Prérequis
Deux outils sont nécessaires pour tester et configurer un répertoire SAMBA.
```bash
sudo apt-get install smbclient
sudo apt-get install cifs-utils
```

## Configuration

Dupliquer le fichier config.ini.default en config.ini 

```bash
cp config.ini.default config.ini
```

Modifier les paramètres 
```ini
username=edissyum
password=edissyum
domain=edissyum
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

```bash
sudo ./start.sh
```

## Nettoyage

Si vous souhaitez démonter et supprimer le répertoire :
```bash
sudo ./clear.sh
```
