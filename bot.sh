#!/bin/sh
# Bot-Shell-Aesthetics - v11.0 - Interface utilisateur avancée avec spinners et couleurs.

# --- CONFIGURATION ---
CORPUS_URL="https://bot-tve8.onrender.com"

# --- BIBLIOTHÈQUE D'INTERFACE UTILISATEUR (UI) ---

# Définition des couleurs ANSI
C_RESET='\033[0m'
C_BLUE='\033[0;34m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_CYAN='\033[0;36m'
C_GRAY='\033[0;90m'

# Spinner en pur Shell
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Fonction pour démarrer un spinner en arrière-plan
spinner_start() {
    (spinner $!) &
    SPINNER_PID=$!
}

# Fonction pour arrêter le spinner
spinner_stop() {
    kill $SPINNER_PID > /dev/null 2>&1
    wait $SPINNER_PID 2>/dev/null
}

# Fonction pour afficher le texte avec une couleur
typing_color() {
    local color=$1
    local text=$2
    echo -e "${color}${text}${C_RESET}"
}

# Le footer
show_footer() {
    typing_color "$C_GRAY" "créé par mauricio-100"
}


# --- MODULES AVANCÉS (Maintenant avec la belle UI) ---

module_aide() {
  typing_color "$C_YELLOW" "--- Manuel d'Opération Bot-Shell-Aesthetics ---"
  echo -e "${C_CYAN} cherche [sujet]${C_RESET}   - Interroge le cerveau et Wikipedia."
  echo -e "${C_CYAN} calcule [opération]${C_RESET}- Fait un calcul mathématique complexe."
  # ... (vous pouvez ajouter les autres commandes ici)
  typing_color "$C_YELLOW" "-------------------------------------------------"
}

module_recherche() {
  query=$(echo "$1" | sed -E "s/cherche //i")
  url_query=$(echo "$query" | sed 's/ /%20/g')
  
  typing_color "$C_BLUE" "-> Connexion à la mémoire centrale..."
  (curl -s -w "\n%{http_code}" "${CORPUS_URL}/corpus/${url_query}") &
  CURL_PID=$!
  spinner_start
  
  response_corpus=$(wait $CURL_PID && cat)
  spinner_stop

  http_code=$(tail -n1 <<< "$response_corpus") && content=$(sed '$d' <<< "$response_corpus")
  if [ "$http_code" -eq 200 ]; then
    typing_color "$C_GREEN" "[Mémoire centrale] : $(echo "$content" | jq -r '.definition')"
    return
  fi

  typing_color "$C_BLUE" "-> Information non mémorisée. Accès à Wikipedia..."
  (curl -s -A "Bot-Shell-Aesthetics/11.0" "https://fr.wikipedia.org/api/rest_v1/page/summary/$(echo "$query" | sed 's/ /_/g')") &
  CURL_PID=$!
  spinner_start
  wiki_response=$(wait $CURL_PID && cat | jq -r '.extract')
  spinner_stop

  if [ -n "$wiki_response" ] && [ "$wiki_response" != "null" ]; then
    typing_color "$C_GREEN" "$wiki_response"
    printf "${C_YELLOW}Voulez-vous que j'apprenne cette information ? (o/n)> ${C_RESET}"
    read confirmation
    if [ "$confirmation" = "o" ]; then
      json_payload=$(jq -n --arg sujet "$query" --arg def "$wiki_response" '{sujet: $sujet, definition: $def}')
      curl -s -X POST -H "Content-Type: application/json" -d "$json_payload" "${CORPUS_URL}/corpus" > /dev/null
      typing_color "$C_GRAY" "Information transmise au cerveau central."
    fi
  else
    typing_color "$C_RED" "Aucune information trouvée sur aucune source."
  fi
}

module_calcul() {
  expression=$(echo "$1" | sed 's/calcule //i')
  typing_color "$C_BLUE" "-> Transmission au module de calcul distant..."
  json_payload=$(jq -n --arg expr "$expression" '{expression: $expr}')
  
  (curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -d "$json_payload" "${CORPUS_URL}/calculate") &
  CURL_PID=$!
  spinner_start
  response_calc=$(wait $CURL_PID && cat)
  spinner_stop

  http_code=$(tail -n1 <<< "$response_calc") && content=$(sed '$d' <<< "$response_calc")
  if [ "$http_code" -eq 200 ]; then
    typing_color "$C_GREEN" "Résultat : $(echo "$content" | jq -r '.result')"
  else
    typing_color "$C_RED" "Erreur : $(echo "$content" | jq -r '.error')"
  fi
}


# --- CŒUR DU BOT ---
typing_color "$C_CYAN" "--- Bot-Shell-Aesthetics v11.0 connecté ---"
typing_color "$C_YELLOW" "Tapez 'aide' pour voir la liste des commandes."

while true; do
  printf "${C_BLUE}Vous> ${C_RESET}"
  read input
  input_lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')

  case "$input_lower" in
    "") continue ;;
    aide*) module_aide ;;
    cherche*) module_recherche "$input_lower" ;;
    calcule*) module_calcul "$input_lower" ;;
    quitter|au\ revoir|bye) typing_color "$C_GRAY" "Session terminée." ; show_footer; break ;;
    *) typing_color "$C_RED" "Commande inconnue. Tapez 'aide' pour la liste." ;;
  esac
done
