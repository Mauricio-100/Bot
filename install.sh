#!/bin/sh
# Script d'installation pour Bot-Shell-Pro

echo "--- Mise à jour de la liste des paquets (apk) ---"
apk update

echo "\n--- Installation des dépendances requises ---"
# curl : pour faire des requêtes web (API)
# jq : pour lire les réponses JSON des API
# whois : pour le module réseau
# git : pour la gestion de version de votre projet
apk add curl jq whois git

echo "\n--- Installation terminée ! ---"
echo "Tous les outils nécessaires pour le bot sont maintenant installés."
echo "Vous pouvez lancer le bot avec : ./bot.sh"
