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

## Utilisation sans fichier credentials (ticket kerberos)

### Lancement

```bash
sudo ./start_without_clear_credentials.sh
```

### Nettoyage

Utiliser le script `stop.sh` pour nettoyer et supprimer les points de montages.

```bash
sudo ./stop.sh
```
