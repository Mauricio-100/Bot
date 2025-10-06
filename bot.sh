#!/bin/sh
# Bot-Shell-Universal - v12.0 - Auto-détection de l'OS pour une compatibilité maximale.

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
    local pid=$1; local delay=0.1; local spinstr='|/-\'
    while ps -p $pid > /dev/null; do
        printf " [%c]  " "$spinstr"; spinstr=${spinstr#?}${spinstr%???}
        sleep $delay; printf "\b\b\b\b\b\b"
    done; printf "    \b\b\b\b"
}
spinner_start() { (spinner $!) & SPINNER_PID=$!; }
spinner_stop() { kill $SPINNER_PID > /dev/null 2>&1; wait $SPINNER_PID 2>/dev/null; }
typing_color() { echo -e "${1}${2}${C_RESET}"; }
show_footer() { typing_color "$C_GRAY" "\ncréé par mauricio-100"; }

# --- MODULES AVANCÉS ---

module_aide() {
    typing_color "$C_YELLOW" "--- Manuel d'Opération Bot-Shell-Universal ---"
    echo -e "${C_GREEN} cherche [sujet]${C_RESET}   - Recherche une information."
    echo -e "${C_GREEN} calcule [opération]${C_RESET}- Calculateur mathématique."
    echo -e "${C_GREEN} system            ${C_RESET}- Affiche les informations système."
    typing_color "$C_YELLOW" "-------------------------------------------------"
}

# NOUVEAU : Module d'information système
module_system() {
    typing_color "$C_YELLOW" "--- Informations Système ---"
    typing_color "$C_GREEN" "OS Détecté : $OS_TYPE"
    typing_color "$C_GREEN" "Shell : $SHELL"
    typing_color "$C_GREEN" "Connecté à : $CORPUS_URL"
}

module_recherche() {
  query=$(echo "$1" | sed -E "s/cherche //i")
  url_query=$(echo "$query" | sed 's/ /%20/g')
  typing_color "$C_BLUE" "-> Connexion à la mémoire centrale..."
  (curl -s -w "\n%{http_code}" "${CORPUS_URL}/corpus/${url_query}") &
  CURL_PID=$! && spinner_start
  response_corpus=$(wait $CURL_PID && cat)
  spinner_stop
  # ... (le reste de la fonction est inchangé)
}

module_calcul() {
  expression=$(echo "$1" | sed 's/calcule //i')
  typing_color "$C_BLUE" "-> Transmission au module de calcul distant..."
  json_payload=$(jq -n --arg expr "$expression" '{expression: $expr}')
  (curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -d "$json_payload" "${CORPUS_URL}/calculate") &
  CURL_PID=$! && spinner_start
  response_calc=$(wait $CURL_PID && cat)
  spinner_stop
  # ... (le reste de la fonction est inchangé)
}


# --- CŒUR DU BOT ---
typing_color "$C_GREEN" "--- Bot-Shell-Universal v12.0 activé ---"
typing_color "$C_YELLOW" "Détecté sur un système de type : $OS_TYPE"
typing_color "$C_GRAY" "Tapez 'aide' pour voir la liste des commandes."

while true; do
  printf "${C_BLUE}Vous> ${C_RESET}"
  read input
  input_lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')

  case "$input_lower" in
    "") continue ;;
    aide*) module_aide ;;
    system*) module_system ;; # Nouvelle commande
    cherche*) module_recherche "$input_lower" ;;
    calcule*) module_calcul "$input_lower" ;;
    quitter|bye) typing_color "$C_GRAY" "Session terminée." ; show_footer; break ;;
    *) typing_color "$C_RED" "Commande inconnue. Tapez 'aide' pour la liste." ;;
  esac
done
