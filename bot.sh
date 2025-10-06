#!/bin/sh
# Bot-Shell-Nexus - v9.0 - Connecté à un cerveau externe Node.js

# --- CONFIGURATION ---
# REMPLACEZ CETTE URL PAR CELLE DE VOTRE SERVEUR RENDER !
CORPUS_URL="https://mon-corpus-bot.onrender.com" 

# --- MODULES ---

# Module de Recherche et d'Apprentissage
module_recherche_nexus() {
  query=$(echo "$1" | sed -E "s/cherche //i")
  
  # --- ÉTAPE 1: INTERROGER LE CERVEAU EXTERNE ---
  typing "Connexion au cerveau externe..."
  url_query=$(echo "$query" | sed 's/ /%20/g') # Encoder les espaces pour l'URL
  
  response_corpus=$(curl -s -w "\n%{http_code}" "${CORPUS_URL}/corpus/${url_query}")
  http_code=$(tail -n1 <<< "$response_corpus")
  content=$(sed '$d' <<< "$response_corpus")

  if [ "$http_code" -eq 200 ]; then
    definition=$(echo "$content" | jq -r '.definition')
    typing "[Mémoire centrale] : $definition"
    return
  fi

  # --- ÉTAPE 2: SI INCONNU, INTERROGER WIKIPEDIA ---
  typing "Information non mémorisée. Accès à l'encyclopédie..."
  wiki_url_query=$(echo "$query" | sed 's/ /_/g')
  wiki_response=$(curl -s -A "Bot-Shell-Nexus/9.0" "https://fr.wikipedia.org/api/rest_v1/page/summary/${wiki_url_query}" | jq -r '.extract')

  if [ -n "$wiki_response" ] && [ "$wiki_response" != "null" ]; then
    typing "$wiki_response"
    
    printf "Dois-je apprendre cette information ? (o/n)> "
    read confirmation
    if [ "$confirmation" = "o" ]; then
      # --- APPRENTISSAGE : ENVOYER AU CERVEAU EXTERNE ---
      json_payload=$(jq -n --arg sujet "$query" --arg def "$wiki_response" '{sujet: $sujet, definition: $def}')
      curl -s -X POST -H "Content-Type: application/json" -d "$json_payload" "${CORPUS_URL}/corpus"
      typing "Information transmise au cerveau central."
    fi
  else
    typing "Aucune information trouvée sur aucune source."
  fi
}

# 🤖 Cœur du bot et utilitaires
typing() { [ -n "$1" ] && echo -e "$1"; }
typing "--- Bot-Shell-Nexus v9.0 connecté à ${CORPUS_URL} ---"

while true; do
  printf "Vous> "
  read input
  input_lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')

  if [ -z "$input_lower" ]; then
    continue
  elif echo "$input_lower" | grep -qE "cherche"; then
    module_recherche_nexus "$input_lower"
  elif echo "$input_lower" | grep -qE "au revoir|quitter"; then
    typing "Déconnexion."
    break
  else
    typing "Commande non reconnue. Utilisez 'cherche [sujet]'."
  fi
done
