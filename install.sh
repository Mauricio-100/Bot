#!/bin/sh
# Script d'installation pour Bot-Shell-Titanium

echo "--- Mise à jour de la liste des paquets ---"
apk update

echo "--- Mise a jour de tous les pakage du mobile (apk) ---"
apk upgrade

echo "\n--- Installation des dépendances essentielles ---"
# curl: pour les API web
# jq: pour lire le JSON des API
# whois: pour le module réseau
apk add curl jq whois

echo "\n--- Installation Titanium terminée ! ---"
echo "Le système est prêt. Stabilité maximale engagée."
