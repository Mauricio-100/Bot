#!/bin/sh
# Bot-Shell-Colossus - v10.0 - Client lourd avec de multiples outils et modules.

# --- CONFIGURATION ---
# URL de votre cerveau externe sur Render
CORPUS_URL="https://bot-tve8.onrender.com"

# --- MODULES AVANCÉS ---

# Module d'aide : La commande la plus importante !
module_aide() {
  typing "--- Manuel d'Opération Bot-Shell-Colossus ---"
  typing " cherche [sujet]   \t- Interroge le cerveau et Wikipedia."
  typing " calcule [opération]\t- Fait un calcul mathématique complexe."
  typing " qr pour [texte]   \t- Génère un QR Code dans le terminal."
  typing " net [ping|dns] [cible]\t- Outils réseau (ex: net ping google.com)."
  typing " status            \t- Affiche le statut du système local."
  typing " aide              \t- Affiche cette aide."
  typing " quitter           \t- Termine la session."
}

# Module de Recherche et d'Apprentissage (amélioré)
module_recherche() {
  query=$(echo "$1" | sed -E "s/cherche //i")
  url_query=$(echo "$query" | sed 's/ /%20/g')
  
  # 1. Interroger le cerveau externe
  response_corpus=$(curl -s -w "\n%{http_code}" "${CORPUS_URL}/corpus/${url_query}")
  http_code=$(tail -n1 <<< "$response_corpus") && content=$(sed '$d' <<< "$response_corpus")
  if [ "$http_code" -eq 200 ]; then
    typing "[Mémoire centrale] : $(echo "$content" | jq -r '.definition')"
    return
  fi

  # 2. Si inconnu, interroger Wikipedia
  typing "Info non mémorisée. Accès à Wikipedia..."
  wiki_url_query=$(echo "$query" | sed 's/ /_/g')
  wiki_response=$(curl -s -A "Bot-Shell-Colossus/10.0" "https://fr.wikipedia.org/api/rest_v1/page/summary/${wiki_url_query}" | jq -r '.extract')

  if [ -n "$wiki_response" ] && [ "$wiki_response" != "null" ]; then
    typing "$wiki_response"
    printf "Voulez-vous que j'apprenne cette information ? (o/n)> "
    read confirmation
    if [ "$confirmation" = "o" ]; then
      json_payload=$(jq -n --arg sujet "$query" --arg def "$wiki_response" '{sujet: $sujet, definition: $def}')
      curl -s -X POST -H "Content-Type: application/json" -d "$json_payload" "${CORPUS_URL}/corpus" > /dev/null
      typing "Information transmise au cerveau central."
    fi
  else
    typing "Aucune information trouvée sur aucune source."
  fi
}

# Module de Calcul via API
module_calcul() {
  expression=$(echo "$1" | sed 's/calcule //i')
  typing "Transmission de l'expression au module de calcul..."
  json_payload=$(jq -n --arg expr "$expression" '{expression: $expr}')
  
  response_calc=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -d "$json_payload" "${CORPUS_URL}/calculate")
  http_code=$(tail -n1 <<< "$response_calc") && content=$(sed '$d' <<< "$response_calc")

  if [ "$http_code" -eq 200 ]; then
    typing "Résultat : $(echo "$content" | jq -r '.result')"
  else
    typing "Erreur du module de calcul : $(echo "$content" | jq -r '.error')"
  fi
}

# Module QR Code
module_qr_code() {
  data=$(echo "$1" | sed -E 's/qr pour //i')
  typing "Génération du QR Code pour : $data"
  curl -s "qrenco.de/$data"
}

# Module Outils Réseau
module_outils_reseau() {
  sub_command=$(echo "$1" | awk '{print $2}')
  target=$(echo "$1" | awk '{print $3}')
  case "$sub_command" in
    ping) typing "--- PING $target ---" ; ping -c 4 "$target" ;;
    dns) typing "--- DNS LOOKUP $target ---" ; dig "$target" ;;
    *) typing "Sous-commande réseau non valide. Utilisez 'ping' ou 'dns'." ;;
  esac
}

# Module Statut Système
module_statut_systeme() {
  typing "--- Statut du Système Local ---"
  typing "OS: $(uname -s -r)"
  typing "Uptime: $(uptime | sed 's/.*up \([^,]*\), .*/\1/') "
  typing "Charge CPU (1 min): $(uptime | awk -F'load average: ' '{print $2}' | cut -d, -f1)"
}

# --- CŒUR DU BOT ---
typing() { [ -n "$1" ] && echo -e "$1"; }
typing "--- Bot-Shell-Colossus v10.0 connecté à ${CORPUS_URL} ---"
typing "Tapez 'aide' pour voir la liste des commandes."

while true; do
  printf "Vous> "
  read input
  input_lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')

  case "$input_lower" in
    "") continue ;;
    aide*) module_aide ;;
    cherche*) module_recherche "$input_lower" ;;
    calcule*) module_calcul "$input_lower" ;;
    qr\ pour*) module_qr_code "$input_lower" ;;
    net*) module_outils_reseau "$input_lower" ;;
    status*) module_statut_systeme ;;
    quitter|au\ revoir|bye) typing "Session terminée." ; break ;;
    *) typing "Commande inconnue. Tapez 'aide' pour la liste." ;;
  esac
done
