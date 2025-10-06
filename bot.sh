#!/bin/sh
# Bot-Shell-Omega - v8.0 - Cerveau de recherche stable et module d'apprentissage actif.

# --- FICHIERS DE CONNAISSANCES ---
FICHIER_BLAGUES="blagues.txt"
CORPUS_APPRENTISSAGE="corpus.db"

# 💬 Module de conversation
module_conversation() {
  typing "Bot-Shell-Omega. Prêt à apprendre et à assister."
}

# 📚 Module de Recherche Principal (Wikipedia)
module_recherche_wikipedia() {
  query=$(echo "$1" | sed -E "s/cherche |c'est quoi |qui est |définition de //i")
  
  # --- ÉTAPE 1: VÉRIFIER LE CORPUS LOCAL D'ABORD ---
  reponse_apprise=$(grep -i "^${query}:" "$CORPUS_APPRENTISSAGE" | cut -d':' -f2-)
  if [ -n "$reponse_apprise" ]; then
    typing "[Réponse apprise] : $reponse_apprise"
    return
  fi

  # --- ÉTAPE 2: SI INCONNU, INTERROGER WIKIPEDIA ---
  typing "Accès à l'encyclopédie centrale pour : $query"
  url_query=$(echo "$query" | sed 's/ /_/g')
  UA="Bot-Shell-Omega/8.0 (user-script)"
  wiki_response=$(curl -s -A "$UA" "https://fr.wikipedia.org/api/rest_v1/page/summary/${url_query}" | jq -r '.extract')

  if [ -n "$wiki_response" ] && [ "$wiki_response" != "null" ]; then
    typing "$wiki_response"
    
    # --- AUTO-APPRENTISSAGE ---
    printf "Dois-je mémoriser cette information pour '$query' ? (o/n)> "
    read confirmation
    if [ "$confirmation" = "o" ]; then
      # On supprime l'ancienne entrée au cas où
      grep -vi "^${query}:" "$CORPUS_APPRENTISSAGE" > "${CORPUS_APPRENTISSAGE}.tmp" && mv "${CORPUS_APPRENTISSAGE}.tmp" "$CORPUS_APPRENTISSAGE"
      echo "${query}:${wiki_response}" >> "$CORPUS_APPRENTISSAGE"
      typing "Information ajoutée au corpus."
    fi
  else
    typing "Aucun article trouvé. Vous pouvez m'apprendre la réponse avec la commande 'apprends'."
  fi
}

# 🧠 Module d'Apprentissage Actif
module_apprentissage() {
  # Syntaxe : "apprends que [sujet] est [définition]"
  sujet=$(echo "$1" | sed -n "s/apprends que \(.*\) est .*/\1/p")
  definition=$(echo "$1" | sed -n "s/.* est \(.*\)/\1/p")
  
  if [ -n "$sujet" ] && [ -n "$definition" ]; then
    # On supprime l'ancienne entrée au cas où
    grep -vi "^${sujet}:" "$CORPUS_APPRENTISSAGE" > "${CORPUS_APPRENTISSAGE}.tmp" && mv "${CORPUS_APPRENTISSAGE}.tmp" "$CORPUS_APPRENTISSAGE"
    # On ajoute la nouvelle connaissance
    echo "${sujet}:${definition}" >> "$CORPUS_APPRENTISSAGE"
    typing "Connaissance acquise. Je sais maintenant que '$sujet' est '$definition'."
  else
    typing "Syntaxe d'apprentissage incorrecte. Utilisez : apprends que [sujet] est [définition]"
  fi
}

# 🤖 Cœur du bot et utilitaires
typing() { [ -n "$1" ] && echo -e "$1"; }

# --- INITIALISATION ---
touch "$CORPUS_APPRENTISSAGE"
typing "--- Bot-Shell-Omega v8.0 en ligne. Module d'apprentissage actif. ---"

# --- BOUCLE PRINCIPALE ---
while true; do
  printf "Vous> "
  read input
  input_lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')

  if [ -z "$input_lower" ]; then
    continue
  elif echo "$input_lower" | grep -qE "bonjour|salut"; then
    module_conversation
  elif echo "$input_lower" | grep -q "apprends que"; then
    module_apprentissage "$input_lower"
  elif echo "$input_lower" | grep -qE "cherche|c'est quoi|qui est|définition de"; then
    module_recherche_wikipedia "$input_lower"
  elif echo "$input_lower" | grep -qE "au revoir|quitter|bye"; then
    typing "Mise en veille."
    break
  else
    typing "Commande non reconnue. Essayez 'cherche [sujet]' ou 'apprends que [sujet] est [définition]'."
  fi
done
