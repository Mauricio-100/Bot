#!/bin/sh
# Bot-Shell-Prestige - v4.0 - Un bot avec des outils de monitoring et de recherche avancés

# --- FICHIERS DE DONNÉES ---
FICHIER_BLAGUES="blagues.txt"
FICHIER_MEMOIRE="memoire.db"


#################################################################
# 🧠 MODULES DU CERVEAU LOCAL (OUTILS SHELL) 🧠                  #
#################################################################

# 💬 Module de conversation
module_conversation() {
  case "$1" in
    *bonjour*|*salut*) typing "Bot-Shell-Prestige en ligne. Prêt pour les opérations." ;;
    *merci*) typing "De rien." ;;
  esac
}

# 😂 Module de blagues
module_blague() {
  [ -f "$FICHIER_BLAGUES" ] && typing "$(shuf -n 1 $FICHIER_BLAGUES)" || typing "Fichier de blagues introuvable."
}

# 💾 Module de mémoire persistante
module_memoire() {
  touch "$FICHIER_MEMOIRE"
  if echo "$1" | grep -q "souviens-toi que"; then
    cle=$(echo "$1" | sed -n 's/.*souviens-toi que \(.*\) est .*/\1/p' | sed 's/^[ \t]*//;s/[ \t]*$//')
    valeur=$(echo "$1" | sed -n 's/.* est \(.*\)/\1/p' | sed 's/^[ \t]*//;s/[ \t]*$//')
    grep -v "^${cle}:" "$FICHIER_MEMOIRE" > "${FICHIER_MEMOIRE}.tmp" && mv "${FICHIER_MEMOIRE}.tmp" "$FICHIER_MEMOIRE"
    echo "${cle}:${valeur}" >> "$FICHIER_MEMOIRE"
    typing "Confirmé. Donnée mémorisée."
  elif echo "$1" | grep -q "rappelle-moi"; then
    cle=$(echo "$1" | sed 's/rappelle-moi //')
    resultat=$(grep "^${cle}:" "$FICHIER_MEMOIRE" | cut -d':' -f2-)
    [ -n "$resultat" ] && typing "Rappel : '${cle}' est '${resultat}'." || typing "Aucune donnée pour '${cle}'."
  fi
}

# 🖥️ NOUVEAU : Module Moniteur Système
module_moniteur_systeme() {
  case "$1" in
    *cpu*)
      typing "--- Utilisation CPU (1 seconde) ---"
      # 'top -b -n 1' prend un instantané du CPU sans mode interactif
      top -b -n 1 | head -n 5
      ;;
    *ram*|*mémoire*)
      typing "--- Utilisation RAM / Mémoire ---"
      # 'free -h' affiche la mémoire en format lisible (Go, Mo)
      free -h
      ;;
    *disque*)
      typing "--- Utilisation Espace Disque ---"
      # 'df -h' affiche l'utilisation du disque
      df -h
      ;;
  esac
}


#################################################################
# 🌍 MODULES D'INTELLIGENCE CONNECTÉE (API ET RÉSEAU) 🌍         #
#################################################################

# ☀️ Module Météo
module_meteo() {
  ville=$(echo "$1" | sed -E 's/.*météo à (.*)//i')
  typing "Analyse météo pour $ville..."
  curl -s "wttr.in/${ville}?format=3"
}

# 📚 Module de recherche web
module_recherche_web() {
  query=$(echo "$1" | sed -E "s/cherche |c'est quoi |qui est |définition de //i")
  typing "Recherche web pour : $query"
  url_query=$(echo "$query" | sed 's/ /+/g')
  api_response=$(curl -s "https://api.duckduckgo.com/?q=${url_query}&format=json" | jq -r '.AbstractText')
  [ -n "$api_response" ] && [ "$api_response" != "null" ] && typing "$api_response" || typing "Aucune réponse directe trouvée."
}

# 📺 NOUVEAU : Module de recherche YouTube
module_recherche_youtube() {
  query=$(echo "$1" | sed 's/cherche sur youtube //i')
  typing "Recherche YouTube pour : $query ..."
  # On encode la recherche pour l'URL
  url_query=$(echo "$query" | sed 's/ /%20/g')
  # On utilise une instance publique d'Invidious, une interface alternative à YouTube
  # jq extrait le titre et l'ID de la vidéo, puis on reconstruit le lien
  curl -s "https://vid.puffyan.us/api/v1/search?q=${url_query}" | \
  jq -r '.[] | "- Titre : \(.title)\n  Lien : https://www.youtube.com/watch?v=\(.videoId)\n"' | \
  head -n 6 # On ne garde que les 3 premiers résultats (2 lignes par résultat)
}


#################################################################
# 🤖 CŒUR DU BOT (INITIALISATION ET BOUCLE PRINCIPALE) 🤖       #
#################################################################

typing() { [ -n "$1" ] && echo "$1"; }

typing "--- Bot-Shell-Prestige v4.0 initialisé ---"

while true; do
  printf "Vous> "
  read input
  # On convertit en minuscule une seule fois
  input_lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')

  # AIGUILLEUR PRINCIPAL (ROBUSTE ET CORRIGÉ)
  case "$input_lower" in
    "") ;; # Ignore l'entrée vide
    *bonjour*|*salut*|*merci*) module_conversation "$input_lower" ;;
    *blague*) module_blague ;;
    *souviens-toi que*|*rappelle-moi*) module_memoire "$input_lower" ;;
    *cpu*|*ram*|*mémoire*|*disque*) module_moniteur_systeme "$input_lower" ;;
    *météo*) module_meteo "$input_lower" ;;
    *cherche sur youtube*) module_recherche_youtube "$input_lower" ;;
    *cherche*|*c'est quoi*|*qui est*|*définition de*) module_recherche_web "$input_lower" ;;
    *au revoir*|*quitter*|*bye*) typing "Déconnexion." ; break ;;
    *) typing "Non compris. Mots-clés : cpu, ram, disque, météo, youtube, cherche, blague..." ;;
  esac
done
