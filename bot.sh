#!/bin/sh
# Bot-Shell-Expert - v3.0 - Un bot modulaire avec des outils experts

# --- FICHIERS DE DONNÉES ---
FICHIER_BLAGUES="blagues.txt"
FICHIER_MEMOIRE="memoire.db"


#################################################################
# 🧠 MODULES DU CERVEAU LOCAL (OUTILS SHELL) 🧠                  #
#################################################################

# 💬 Module de conversation
module_conversation() {
  case $(echo "$1" | tr '[:upper:]' '[:lower:]') in
    *bonjour*|*salut*) typing "Salutations ! Système Bot-Shell-Expert en ligne." ;;
    *merci*) typing "À votre service." ;;
  esac
}

# 😂 Module de blagues
module_blague() {
  [ -f "$FICHIER_BLAGUES" ] && typing "$(shuf -n 1 $FICHIER_BLAGUES)" || typing "Fichier de blagues introuvable."
}

# 💾 Module de mémoire persistante
module_memoire() {
  touch "$FICHIER_MEMOIRE"
  input_lower=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  if [[ $input_lower == *"souviens-toi que"* ]]; then
    cle=$(echo "$input_lower" | sed -n 's/.*souviens-toi que \(.*\) est .*/\1/p' | sed 's/^[ \t]*//;s/[ \t]*$//')
    valeur=$(echo "$input_lower" | sed -n 's/.* est \(.*\)/\1/p' | sed 's/^[ \t]*//;s/[ \t]*$//')
    grep -v "^${cle}:" "$FICHIER_MEMOIRE" > "${FICHIER_MEMOIRE}.tmp" && mv "${FICHIER_MEMOIRE}.tmp" "$FICHIER_MEMOIRE"
    echo "${cle}:${valeur}" >> "$FICHIER_MEMOIRE"
    typing "Confirmé. '${cle}' est maintenant associé à '${valeur}'."
  elif [[ $input_lower == *"rappelle-moi"* ]]; then
    cle=$(echo "$input_lower" | sed 's/rappelle-moi //')
    resultat=$(grep "^${cle}:" "$FICHIER_MEMOIRE" | cut -d':' -f2-)
    [ -n "$resultat" ] && typing "Rappel : '${cle}' est '${resultat}'." || typing "Aucune donnée pour '${cle}'."
  fi
}

# 🛠️ NOUVEAU : Module d'outils de chiffrement et d'encodage
module_crypto_outils() {
  input_lower=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  if [[ $input_lower == *"encode base64"* ]]; then
    texte=$(echo "$input_lower" | sed 's/encode base64 //')
    encode=$(echo -n "$texte" | base64)
    typing "Encodage Base64 : $encode"
  elif [[ $input_lower == *"decode base64"* ]]; then
    texte=$(echo "$input_lower" | sed 's/decode base64 //')
    decode=$(echo -n "$texte" | base64 -d)
    typing "Décodage Base64 : $decode"
  fi
}


#################################################################
# 🌍 MODULES D'INTELLIGENCE CONNECTÉE (API ET RÉSEAU) 🌍         #
#################################################################

# ☀️ Module Météo
module_meteo() {
  ville=$(echo "$1" | sed -E 's/.*météo à (.*)/\1/i')
  typing "Analyse météo en cours pour $ville..."
  curl -s "wttr.in/${ville}?format=3"
}

# 📚 Module de recherche web
module_recherche_web() {
  typing "Accès à la base de connaissance mondiale..."
  query=$(echo "$1" | sed -E "s/(cherche|c'est quoi|qui est|définition de) //i")
  url_query=$(echo "$query" | sed 's/ /+/g')
  api_response=$(curl -s "https://api.duckduckgo.com/?q=${url_query}&format=json" | jq -r '.AbstractText')
  [ -n "$api_response" ] && [ "$api_response" != "null" ] && typing "$api_response" || typing "Aucune réponse directe trouvée pour '$query'."
}

# 📡 Module réseau
module_reseau() {
  if [[ $1 == *"ping"* ]]; then
    domaine=$(echo "$1" | sed 's/ping //')
    typing "Envoi de 3 pings vers ${domaine}..."
    ping -c 3 "$domaine"
  elif [[ $1 == *"whois"* ]]; then
    domaine=$(echo "$1" | sed 's/whois //')
    typing "Analyse WHOIS de ${domaine}..."
    whois "$domaine"
  fi
}

# 🔳 NOUVEAU : Module Générateur de QR Code
module_qr_code() {
  # Syntaxe : "qr pour [texte ou url]"
  data=$(echo "$1" | sed -E 's/qr pour //i')
  typing "Génération du QR Code pour : $data"
  # On n'encode pas le data, curl s'en charge bien la plupart du temps
  curl -s "qrenco.de/$data"
}


#################################################################
# 🤖 CŒUR DU BOT (INITIALISATION ET BOUCLE PRINCIPALE) 🤖       #
#################################################################

# Utilitaire pour l'affichage (version simplifiée pour la réactivité)
typing() { [ -n "$1" ] && echo "$1"; }

# --- DÉMARRAGE DU BOT ---
typing "--- Bot-Shell-Expert v3.0 activé ---"

# --- BOUCLE PRINCIPALE (L'AIGUILLEUR) ---
while true; do
  printf "Vous> "
  read input

  case $(echo "$input" | tr '[:upper:]' '[:lower:]') in
    *bonjour*|*salut*|*merci*)
      module_conversation "$input" ;;
    *blague*)
      module_blague ;;
    *souviens-toi que*|*rappelle-moi*)
      module_memoire "$input" ;;
    *encode base64*|*decode base64*)
      module_crypto_outils "$input" ;;
    *météo à*)
      module_meteo "$input" ;;
    *ping*|*whois*)
      module_reseau "$input" ;;
    *qr pour*)
      module_qr_code "$input" ;;
    *cherche*|*c'est quoi*|*qui est*|*définition de*) # <<<--- BUG CORRIGÉ ICI
      module_recherche_web "$input" ;;
    *au revoir*|*quitter*|*bye*)
      typing "Extinction."
      break ;;
    "")
      ;; 
    *)
      typing "Commande non reconnue. Essayez : qr, météo, cherche, ping, encode, decode, souviens-toi..." ;;
  esac
done
