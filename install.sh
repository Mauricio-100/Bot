
#!/bin/sh
# Script d'installation pour Bot-Shell-Prestige

echo "--- Mise à jour de la liste des paquets (apk) ---"
apk update

echo "--- Mise a jour de tous les pakage du mobile (apk) ---"
apk upgrade

echo "\n--- Installation des dépendances requises ---"
# curl: pour les API web
# jq: pour lire le JSON des API
# whois: pour le module réseau
# procps-ng: pour les commandes 'top' et 'free' améliorées (moniteur système)
apk add curl jq whois procps-ng

echo "\n--- Installation terminée ! ---"
echo "Tous les outils pour la version Prestige sont installés."
echo "Vous pouvez lancer le bot avec : ./bot.sh"
