#!/bin/sh
# Bot-Shell-Titanium - v5.0 - Architecture robuste et fonctionnalités avancées

# --- FICHIERS DE DONNÉES ---
FICHIER_BLAGUES="blagues.txt"
FICHIER_MEMOIRE="memoire.db"


#################################################################
# 🧠 MODULES DU CERVEAU LOCAL (STABILISÉS) 🧠                    #
#################################################################

# 💬 Module de conversation
module_conversation() {
  case "$1" in
    *bonjour*|*salut*) typing "Bot-Shell-Titanium. Systèmes opérationnels." ;;
    *merci*) typing "À votre service." ;;
  esac
}

# 😂 Module de blagues
module_blague() {
  [ -f "$FICHIER_BLAGUES" ] && typing "$(shuf -n 1 $FICHIER_BLAGUES)" || typing "Archive de blagues non trouvée."
}

# 🖥️ Module Moniteur Système (Zéro Dépendance)
module_moniteur_systeme() {
  if echo "$1" | grep -q "cpu"; then
    typing "--- Analyse CPU (charge sur 1s) ---"
    # Lecture directe depuis /proc/stat pour calculer l'utilisation
    OLD_STATS=$(head -n 1 /proc/stat)
    sleep 1
    NEW_STATS=$(head -n 1 /proc/stat)
    
    OLD_USER=$(echo $OLD_STATS | awk '{print $2}')
    OLD_NICE=$(echo $OLD_STATS | awk '{print $3}')
    OLD_SYSTEM=$(echo $OLD_STATS | awk '{print $4}')
    OLD_IDLE=$(echo $OLD_STATS | awk '{print $5}')
    
    NEW_USER=$(echo $NEW_STATS | awk '{print $2}')
    NEW_NICE=$(echo $NEW_STATS | awk '{print $3}')
    NEW_SYSTEM=$(echo $NEW_STATS | awk '{print $4}')
    NEW_IDLE=$(echo $NEW_STATS | awk '{print $5}')
    
    OLD_TOTAL=$(($OLD_USER + $OLD_NICE + $OLD_SYSTEM + $OLD_IDLE))
    NEW_TOTAL=$(($NEW_USER + $NEW_NICE + $NEW_SYSTEM + $NEW_IDLE))
    
    DIFF_IDLE=$(($NEW_IDLE - $OLD_IDLE))
    DIFF_TOTAL=$(($NEW_TOTAL - $OLD_TOTAL))
    
    CPU_USAGE=$(awk "BEGIN {print 100 * (1 - ($DIFF_IDLE / $DIFF_TOTAL))}")
    typing "Utilisation CPU actuelle : ${CPU_USAGE}%"

  elif echo "$1" | grep -qE "ram|mémoire"; then
    typing "--- Analyse Mémoire Vive (RAM) ---"
    # Lecture directe et formatage depuis /proc/meminfo
    MEM_TOTAL=$(grep "MemTotal" /proc/meminfo | awk '{print $2}')
    MEM_FREE=$(grep "MemAvailable" /proc/meminfo | awk '{print $2}')
    MEM_USED=$(($MEM_TOTAL - $MEM_FREE))
    MEM_PERCENT=$(awk "BEGIN {print 100 * $MEM_USED / $MEM_TOTAL}")
    typing "Utilisation RAM : ${MEM_PERCENT}% (${MEM_USED}k / ${MEM_TOTAL}k)"

  elif echo "$1" | grep -q "disque"; then
    typing "--- Analyse Espace Disque ---"
    df -h /
  fi
}


#################################################################
# 🌍 MODULES D'INTELLIGENCE CONNECTÉE (API) 🌍                   #
#################################################################

# 📚 Module de recherche web
module_recherche_web() {
  query=$(echo "$1" | sed -E "s/cherche |c'est quoi |qui est |définition de //i")
  typing "Recherche web pour : $query"
  url_query=$(echo "$query" | sed 's/ /+/g')
  api_response=$(curl -s "https://api.duckduckgo.com/?q=${url_query}&format=json" | jq -r '.AbstractText')
  [ -n "$api_response" ] && [ "$api_response" != "null" ] && typing "$api_response" || typing "Aucune réponse directe trouvée."
}

# ✨ NOUVEAU : Module "Sagesse"
module_sagesse() {
  typing "Je consulte les archives de la pensée..."
  # API simple qui ne nécessite pas de clé
  RESPONSE=$(curl -s "http://api.forismatic.com/api/1.0/?method=getQuote&format=text&lang=fr")
  # Parfois l'API renvoie des erreurs, on les filtre
  if ! echo "$RESPONSE" | grep -q "Forismatic"; then
    typing "$RESPONSE"
  else
    typing "La fortune sourit à ceux qui attendent. Réessayez."
  fi
}


#################################################################
# 🤖 CŒUR DU BOT (INITIALISATION ET BOUCLE PRINCIPALE) 🤖       #
#################################################################

typing() { [ -n "$1" ] && echo "$1"; }

typing "--- Bot-Shell-Titanium v5.0 en ligne. Stabilité structurelle confirmée. ---"

# BOUCLE PRINCIPALE AVEC AIGUILLEUR ROBUSTE (if/elif/else)
while true; do
  printf "Vous> "
  read input
  input_lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')

  if [ -z "$input_lower" ]; then
    continue # Ignore l'entrée vide
  elif echo "$input_lower" | grep -qE "bonjour|salut|merci"; then
    module_conversation "$input_lower"
  elif echo "$input_lower" | grep -q "blague"; then
    module_blague
  elif echo "$input_lower" | grep -qE "cpu|ram|mémoire|disque"; then
    module_moniteur_systeme "$input_lower"
  elif echo "$input_lower" | grep -q "une citation|sagesse"; then
    module_sagesse
  elif echo "$input_lower" | grep -qE "cherche|c'est quoi|qui est|définition de"; then
    module_recherche_web "$input_lower"
  elif echo "$input_lower" | grep -qE "au revoir|quitter|bye"; then
    typing "Arrêt du système."
    break
  else
    typing "Commande non interprétable. Mots-clés : cpu, ram, disque, cherche, citation..."
  fi
done
