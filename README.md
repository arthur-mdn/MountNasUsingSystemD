# MountNasUsingSystemD

## Utilisation avec fichier credentials (mdp en clair...)

### Configuration

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

### Lancement

```bash
sudo ./start.sh
```
