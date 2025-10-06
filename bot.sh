#!/bin/sh
# Bot-Shell-Indestructible - v7.0 - Shebang corrigé, stabilité maximale et calculateur scientifique.

FICHIER_BLAGUES="blagues.txt"

# 💬 Module de conversation
module_conversation() {
  case "$1" in
    *bonjour*|*salut*) typing "Bot-Shell-Indestructible. Tous les systèmes sont corrects." ;;
    *merci*) typing "Pas de problème." ;;
  esac
}

# 😂 Module de blagues
module_blague() {
  [ -f "$FICHIER_BLAGUES" ] && typing "$(shuf -n 1 $FICHIER_BLAGUES)" || typing "Archive de blagues non trouvée."
}

# 🖥️ Module Moniteur Système
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
    [ "$DIFF_TOTAL" -eq 0 ] && DIFF_TOTAL=1
    CPU_USAGE=$(awk "BEGIN {printf \"%.2f\", 100 * (1 - ($DIFF_IDLE / $DIFF_TOTAL))}")
    typing "Utilisation CPU : ${CPU_USAGE}%"
  elif echo "$1" | grep -qE "ram|mémoire"; then
    typing "--- Analyse Mémoire RAM ---"
    awk '/MemTotal|MemAvailable/ {printf "%s: %.2f MB\n", $1, $2/1024}' /proc/meminfo
  fi
}

# 📚 Module de Recherche (Wikipedia)
module_recherche_wikipedia() {
  query=$(echo "$1" | sed -E "s/cherche |c'est quoi |qui est |définition de //i")
  typing "Interrogation de l'encyclopédie pour : $query"
  url_query=$(echo "$query" | sed 's/ /_/g')
  UA="Bot-Shell/7.0 (user-script)"
  wiki_response=$(curl -s -A "$UA" "https://fr.wikipedia.org/api/rest_v1/page/summary/${url_query}" | jq -r '.extract')

  if [ -n "$wiki_response" ] && [ "$wiki_response" != "null" ]; then
    typing "$wiki_response"
  else
    typing "Aucun article trouvé dans l'encyclopédie pour cette requête."
  fi
}

# 🧮 NOUVEAU : Module de Calcul Scientifique
module_calcul_scientifique() {
  # Syntaxe : "calcule [opération]"
  operation=$(echo "$1" | sed 's/calcule //i')
  # On utilise awk qui est un véritable langage de programmation pour le texte et les nombres.
  # Il gère les décimaux et les priorités d'opérations.
  # LC_NUMERIC=C force le point comme séparateur décimal.
  resultat=$(LC_NUMERIC=C awk "BEGIN {print $operation}")
  if [ $? -eq 0 ]; then
      typing "Résultat : $resultat"
  else
      typing "Erreur dans l'expression mathématique."
  fi
}

# 🩺 Module d'Auto-Diagnostic
module_diagnostic() {
  typing "--- Lancement du diagnostic système ---"
  typing "Vérification de la connexion à Wikipedia..."
  wiki_status=$(curl -o /dev/null -s -w "%{http_code}" "https://fr.wikipedia.org/w/api.php")
  [ "$wiki_status" -eq 200 ] && typing "  [OK] Wikipedia est en ligne." || typing "  [ERREUR] Impossible de joindre Wikipedia (Code: $wiki_status)."
  typing "--- Diagnostic terminé ---"
}

# 🤖 Cœur du bot et utilitaires
typing() { [ -n "$1" ] && echo -e "$1"; }

typing "--- Bot-Shell-Indestructible v7.0 activé. Stabilité garantie. ---"

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
  elif echo "$input_lower" | grep -q "calcule"; then
    module_calcul_scientifique "$input_lower"
  elif echo "$input_lower" | grep -qE "cherche|c'est quoi|qui est|définition de"; then
    module_recherche_wikipedia "$input_lower"
  elif echo "$input_lower" | grep -qE "au revoir|quitter|bye"; then
    typing "Arrêt d'urgence non nécessaire. Extinction normale."
    break
  else
    typing "Commande non reconnue. Essayez : cherche, calcule, cpu, ram, diagnostic, blague..."
  fi
done
