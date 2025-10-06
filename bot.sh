#!/bin/sh
# Bot-Shell-Phoenix V2 - v13.0 - Robuste, corrigé et fiable.

# --- CONFIGURATION & DÉTECTION DE L'OS ---
CORPUS_URL="https://bot-tve8.onrender.com"
OS_TYPE="Inconnu"
case "$(uname -s)" in
    Linux*)     OS_TYPE="Linux (iSH, Termux, Ubuntu...)" ;;
    Darwin*)    OS_TYPE="macOS" ;;
    CYGWIN*|MINGW*|MSYS*) OS_TYPE="Windows (via Git Bash/Cygwin)" ;;
esac

# --- BIBLIOTHÈQUE D'INTERFACE UTILISATEUR (UI) ---
C_RESET='\033[0m'; C_BLUE='\033[0;34m'; C_GREEN='\033[0;32m'; C_YELLOW='\033[0;33m'; C_RED='\033[0;31m'; C_GRAY='\033[0;90m'

spinner() {
    local pid=$1
    while ps -p $pid > /dev/null; do
        for c in "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"; do
            printf "${C_BLUE} [%s]  ${C_RESET}" "$c"
            sleep 0.1
            printf "\b\b\b\b\b\b"
        done
    done
}

# Fonction pour exécuter une commande avec un spinner
run_with_spinner() {
    # Exécute la commande en arrière-plan et redirige sa sortie vers un fichier temporaire
    "$@" > /tmp/bot_cmd_output.txt 2>&1 &
    local pid=$!
    spinner $pid
    # Récupère le code de sortie et le contenu du fichier
    wait $pid
    local exit_code=$?
    local output=$(cat /tmp/bot_cmd_output.txt)
    rm /tmp/bot_cmd_output.txt
    
    # Renvoyer les résultats
    CMD_OUTPUT="$output"
    return $exit_code
}

typing_color() { echo -e "${1}${2}${C_RESET}"; }
show_footer() { typing_color "$C_GRAY" "\ncréé par mauricio-100"; }

# --- MODULES CORRIGÉS ---

module_aide() {
    typing_color "$C_YELLOW" "--- Manuel d'Opération Bot-Shell-Phoenix V2 ---"
    echo -e "${C_GREEN} bonjour / salut   ${C_RESET}- Pour saluer le bot."
    echo -e "${C_GREEN} cherche [sujet]   ${C_RESET}- Recherche une information."
    echo -e "${C_GREEN} calcule [opération]${C_RESET}- Calculateur mathématique (ex: 21 * (30 * 34) + 21)."
    echo -e "${C_GREEN} system            ${C_RESET}- Affiche les informations système."
    typing_color "$C_YELLOW" "----------------------------------------------------"
}

module_conversation() {
    typing_color "$C_GREEN" "Bonjour ! Je suis prêt à vous assister."
}

module_system() {
    typing_color "$C_YELLOW" "--- Informations Système ---"
    typing_color "$C_GREEN" "OS Détecté : $OS_TYPE"
    typing_color "$C_GREEN" "Connecté à : $CORPUS_URL"
}

module_recherche() {
  query=$(echo "$1" | sed -E "s/cherche //i")
  url_query=$(echo "$query" | sed 's/ /%20/g')
  
  typing_color "$C_BLUE" "-> Connexion à la mémoire centrale..."
  run_with_spinner curl -s -w "\n%{http_code}" "${CORPUS_URL}/corpus/${url_query}"
  
  response_corpus="$CMD_OUTPUT"
  http_code=$(tail -n1 <<< "$response_corpus")
  content=$(sed '$d' <<< "$response_corpus")

  if [ "$http_code" -eq 200 ]; then
    typing_color "$C_GREEN" "[Mémoire centrale] : $(echo "$content" | jq -r '.definition')"
    return
  fi

  typing_color "$C_BLUE" "-> Information non mémorisée. Accès à Wikipedia..."
  wiki_url_query=$(echo "$query" | sed 's/ /_/g')
  run_with_spinner curl -s -A "Bot-Shell-Phoenix/13.0" "https://fr.wikipedia.org/api/rest_v1/page/summary/${wiki_url_query}"
  
  wiki_response=$(echo "$CMD_OUTPUT" | jq -r '.extract')
  if [ -n "$wiki_response" ] && [ "$wiki_response" != "null" ]; then
    typing_color "$C_GREEN" "$wiki_response"
    # ... (le code d'apprentissage reste le même)
  else
    typing_color "$C_RED" "Aucune information trouvée sur aucune source."
  fi
}

module_calcul() {
  expression=$(echo "$1" | sed 's/calcule //i')
  typing_color "$C_BLUE" "-> Transmission au module de calcul distant..."
  json_payload=$(jq -n --arg expr "$expression" '{expression: $expr}')
  
  run_with_spinner curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -d "$json_payload" "${CORPUS_URL}/calculate"
  
  response_calc="$CMD_OUTPUT"
  http_code=$(tail -n1 <<< "$response_calc")
  content=$(sed '$d' <<< "$response_calc")

  if [ "$http_code" -eq 200 ]; then
    typing_color "$C_GREEN" "Résultat : $(echo "$content" | jq -r '.result')"
  else
    typing_color "$C_RED" "Erreur du module de calcul : $(echo "$content" | jq -r '.error')"
    typing_color "$C_GRAY" "Astuce : assurez-vous d'utiliser '*' pour la multiplication."
  fi
}

# --- CŒUR DU BOT ---
typing_color "$C_GREEN" "--- Bot-Shell-Phoenix V2 activé ---"
typing_color "$C_GRAY" "Tapez 'aide' pour voir la liste des commandes."

while true; do
  printf "${C_BLUE}Vous> ${C_RESET}"
  read input
  input_lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')

  case "$input_lower" in
    "") continue ;;
    aide*) module_aide ;;
    bonjour*|salut*) module_conversation ;;
    system*) module_system ;;
    cherche*) module_recherche "$input_lower" ;;
    calcule*) module_calcul "$input_lower" ;;
    quitter|bye) typing_color "$C_GRAY" "Session terminée." ; show_footer; break ;;
    *) typing_color "$C_RED" "Commande inconnue. Tapez 'aide' pour la liste." ;;
  esac
done
