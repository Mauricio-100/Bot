#!/bin-sh
# Bot-Shell-Phoenix - v6.0 - Cerveau de recherche multi-sources et auto-diagnostic.

FICHIER_BLAGUES="blagues.txt"

# 💬 Module de conversation
module_conversation() {
  case "$1" in
    *bonjour*|*salut*) typing "Bot-Shell-Phoenix en ligne. Tous les systèmes sont nominaux." ;;
    *merci*) typing "Avec plaisir." ;;
  esac
}


echo "cree par Mauricio tuks"

# 😂 Module de blagues
module_blague() {
  [ -f "$FICHIER_BLAGUES" ] && typing "$(shuf -n 1 $FICHIER_BLAGUES)" || typing "Archive de blagues non trouvée."
}

# 🖥️ Module Moniteur Système (Zéro Dépendance)
module_moniteur_systeme() {
  if echo "$1" | grep -q "cpu"; then
    typing "--- Analyse Charge CPU (1s) ---"
    OLD_STATS=$(head -n 1 /proc/stat) && sleep 1 && NEW_STATS=$(head -n 1 /proc/stat)
    OLD_TOTAL=$(awk '{print $2+$3+$4+$5}' <<< "$OLD_STATS")
    NEW_TOTAL=$(awk '{print $2+$3+$4+$5}' <<< "$NEW_STATS")
    OLD_IDLE=$(awk '{print $5}' <<< "$OLD_STATS")
    NEW_IDLE=$(awk '{print $5}' <<< "$NEW_STATS")
    DIFF_TOTAL=$((NEW_TOTAL - OLD_TOTAL))
    DIFF_IDLE=$((NEW_IDLE - OLD_IDLE))
    [ "$DIFF_TOTAL" -eq 0 ] && DIFF_TOTAL=1 # Éviter la division par zéro
    CPU_USAGE=$(awk "BEGIN {printf \"%.2f\", 100 * (1 - ($DIFF_IDLE / $DIFF_TOTAL))}")
    typing "Utilisation CPU : ${CPU_USAGE}%"
  elif echo "$1" | grep -qE "ram|mémoire"; then
    typing "--- Analyse Mémoire RAM ---"
    awk '/MemTotal|MemAvailable/ {printf "%s: %d MB\n", $1, $2/1024}' /proc/meminfo
  fi
}

# 📚 Module de Recherche Avancée (Wikipedia + DDG)
module_recherche_avancee() {
  query=$(echo "$1" | sed -E "s/cherche |c'est quoi |qui est |définition de //i")
  typing "Recherche avancée pour : $query"
  url_query=$(echo "$query" | sed 's/ /_/g') # Wikipedia préfère les underscores

  # --- CERVEAU 1 : WIKIPEDIA (Prioritaire) ---
  typing "[Phase 1/2] Interrogation de l'encyclopédie Wikipedia..."
  # On ajoute un User-Agent pour être un bon citoyen du web
  UA="Bot-Shell-Phoenix/1.0 (https://github.com/Mauricio-100/Bot; user-script)"
  wiki_response=$(curl -s -A "$UA" "https://fr.wikipedia.org/api/rest_v1/page/summary/${url_query}" | jq -r '.extract')

  if [ -n "$wiki_response" ] && [ "$wiki_response" != "null" ]; then
    typing "$wiki_response"
    return
  fi

  # --- CERVEAU 2 : DUCKDUCKGO (Fallback) ---
  typing "[Phase 2/2] Wikipedia silencieux. Passage à DuckDuckGo..."
  url_query_ddg=$(echo "$query" | sed 's/ /+/g')
  ddg_response=$(curl -s -A "$UA" "https://api.duckduckgo.com/?q=${url_query_ddg}&format=json" | jq -r '.AbstractText // .Answer // .Definition')

  if [ -n "$ddg_response" ] && [ "$ddg_response" != "null" ]; then
    typing "$ddg_response"
  else
    typing "Échec de la recherche sur toutes les sources. Aucune donnée trouvée."
  fi
}

# 🩺 Module d'Auto-Diagnostic
module_diagnostic() {
  typing "--- Lancement du diagnostic système ---"
  typing "Vérification de la connexion à Wikipedia..."
  wiki_status=$(curl -o /dev/null -s -w "%{http_code}" "https://fr.wikipedia.org/w/api.php")
  [ "$wiki_status" -eq 200 ] && typing "  [OK] Wikipedia est en ligne." || typing "  [ERREUR] Impossible de joindre Wikipedia (Code: $wiki_status)."

  typing "Vérification de la connexion à DuckDuckGo API..."
  ddg_status=$(curl -o /dev/null -s -w "%{http_code}" "https://api.duckduckgo.com/")
  [ "$ddg_status" -eq 200 ] && typing "  [OK] DuckDuckGo API est en ligne." || typing "  [ERREUR] Impossible de joindre DuckDuckGo API (Code: $ddg_status)."
  typing "--- Diagnostic terminé ---"
}

# 🤖 Cœur du bot et utilitaires
typing() { [ -n "$1" ] && echo -e "$1"; }

typing "--- Bot-Shell-Phoenix v6.0 activé. Cerveau de recherche redondant en ligne. ---"

while true; do
  printf "Vous> "
  read input
  input_lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')

  if [ -z "$input_lower" ]; then
    continue
  elif echo "$input_lower" | grep -qE "bonjour|salut|merci"; then
    module_conversation "$input_lower"
  elif echo "$input_lower" | grep -q "blague"; then
    module_blague
  elif echo "$input_lower" | grep -qE "cpu|ram|mémoire"; then
    module_moniteur_systeme "$input_lower"
  elif echo "$input_lower" | grep -q "diagnostic"; then
    module_diagnostic
  elif echo "$input_lower" | grep -qE "cherche|c'est quoi|qui est|définition de"; then
    module_recherche_avancee "$input_lower"
  elif echo "$input_lower" | grep -qE "au revoir|quitter|bye"; then
    typing "Extinction des systèmes."
    break
  else
    typing "Commande non reconnue. Essayez : cherche, cpu, ram, diagnostic, blague..."
  fi
done
