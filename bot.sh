#!/bin/sh
# Bot-Shell-Genius - Un bot Shell avec un cerveau modulaire avancé

# --- PRÉREQUIS ---
# Assurez-vous d'avoir installé jq et curl : apk add jq curl
# Créez un fichier blagues.txt dans le même dossier.
# -----------------

#################################################################
# 🧠 MODULES DU CERVEAU LOCAL (OUTILS SHELL) 🧠                  #
#################################################################

# 💬 Module de conversation et personnalité
module_conversation() {
  case $(echo "$1" | tr '[:upper:]' '[:lower:]') in
    *bonjour*|*salut*)
      typing "Salut ! Prêt à me mettre au défi ?" ;;
    *ça va*)
      typing "Toujours au top ! Je viens de compiler quelques nouvelles idées." ;;
    *merci*)
      typing "De rien ! C'est toujours un plaisir d'aider." ;;
  esac
}

# 😂 Module de blagues
module_blague() {
  if [ -f "blagues.txt" ]; then
    # shuf -n 1 prend une ligne au hasard dans le fichier
    blague=$(shuf -n 1 blagues.txt)
    typing "$blague"
  else
    typing "Je ne trouve pas mon livre de blagues (blagues.txt)..."
  fi
}

# ⚙️ Module pour les commandes système et fichiers
module_systeme_fichiers() {
  input_lower=$(echo "$1" | tr '[:upper:]' '[:lower:]')

  case $input_lower in
    *info système*)
      typing "Voici ce que je sais sur mon environnement :"
      typing "Système : $(uname -s) sur une architecture $(uname -m)."
      typing "Nom d'hôte : $(hostname)"
      ;;
    *liste les fichiers*)
      typing "Voici les fichiers dans le dossier courant :"
      # ls -F ajoute un symbole pour indiquer le type de fichier (ex: / pour dossier)
      ls -F
      ;;
    *montre le fichier*)
      # Extrait le nom du fichier après "montre le fichier "
      fichier=$(echo "$input_lower" | sed 's/montre le fichier //')
      if [ -f "$fichier" ]; then
        typing "--- Contenu de $fichier ---"
        cat "$fichier"
        typing "--- Fin du fichier ---"
      else
        typing "Désolé, le fichier '$fichier' n'existe pas ici."
      fi
      ;;
  esac
}

# 🔐 Module générateur de mot de passe
module_generateur_mdp() {
  typing "Quelle longueur pour le mot de passe ? (entrez un nombre)"
  printf "Longueur> "
  read longueur
  # Vérifie si l'entrée est bien un nombre
  if ! [[ "$longueur" =~ ^[0-9]+$ ]]; then
    typing "Ceci n'est pas un nombre valide."
    return
  fi
  # Génère un mot de passe robuste
  mdp=$(head /dev/urandom | tr -dc 'A-Za-z0-9!@#$%^&*' | head -c${longueur})
  typing "Voici un mot de passe sécurisé : $mdp"
}


#################################################################
# 🌍 MODULES D'INTELLIGENCE CONNECTÉE (API) 🌍                   #
#################################################################

# ☀️ Module Météo avec wttr.in
module_meteo() {
  # Extrait la ville après "météo à "
  ville=$(echo "$1" | sed -E 's/.*météo à (.*)/\1/i')
  typing "Je regarde le ciel pour $ville..."
  # ?format=3 donne une réponse simple et concise
  meteo_info=$(curl -s "wttr.in/${ville}?format=3")
  typing "$meteo_info"
}

# 📚 Module de recherche web (amélioré)
module_recherche_web() {
  typing "Je consulte ma base de données mondiale..."
  query=$(echo "$1" | sed -E -e 's/cherche //i' -e "s/c'est quoi //i" -e 's/sais-tu que //i' -e 's/qui est //i' -e 'définition de //i')
  url_query=$(echo "$query" | sed 's/ /+/g')
  api_response=$(curl -s "https://api.duckduckgo.com/?q=${url_query}&format=json" | jq -r '.AbstractText')

  if [ -n "$api_response" ] && [ "$api_response" != "null" ]; then
    typing "$api_response"
  else
    typing "Je n'ai rien trouvé de concluant pour '$query'."
  fi
}

# 🌐 Module de traduction
module_traduction() {
  # Extrait la langue et le texte. Syntaxe attendue: "traduis en [langue] : [texte]"
  langue=$(echo "$1" | sed -n 's/.*traduis en \([^:]*\) : .*/\1/p' | sed 's/ //g')
  texte=$(echo "$1" | sed -n 's/.*: \(.*\)/\1/p')

  if [ -z "$langue" ] || [ -z "$texte" ]; then
    typing "Syntaxe incorrecte. Utilisez : traduis en [langue] : [texte à traduire]"
    return
  fi

  typing "Je traduis en '$langue'..."
  # On encode le texte pour l'URL
  texte_encode=$(echo "$texte" | sed 's/ /%20/g')
  # On appelle une API publique qui scrape Google Translate
  traduction=$(curl -s "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=${langue}&dt=t&q=${texte_encode}" | jq -r '.[0][0][0]')
  
  if [ -n "$traduction" ] && [ "$traduction" != "null" ]; then
    typing "$traduction"
  else
    typing "La traduction a échoué. La langue '$langue' est-elle correcte ?"
  fi
}


#################################################################
# 🤖 CŒUR DU BOT (INITIALISATION ET BOUCLE PRINCIPALE) 🤖       #
#################################################################

# Utilitaire pour simuler la frappe
typing() {
  text="$1"
  delay=0.01 # On accélère un peu la frappe
  for i in $(seq 0 $(expr length "${text}" - 1)); do
    echo -n "${text:$i:1}"
    sleep ${delay}
  done
  echo ""
}

# --- DÉMARRAGE DU BOT ---
typing "Bonjour ! Je suis Bot-Shell-Genius. Mon cerveau a été massivement mis à jour."

# --- BOUCLE PRINCIPALE (L'AIGUILLEUR) ---
while true; do
  printf "Vous> "
  read input

  # L'aiguilleur qui envoie l'input au bon module
  case $(echo "$input" | tr '[:upper:]' '[:lower:]') in
    *bonjour*|*salut*|*ça va*|*merci*)
      module_conversation "$input" ;;
    *blague*)
      module_blague ;;
    *info système*|*liste les fichiers*|*montre le fichier*)
      module_systeme_fichiers "$input" ;;
    *génère un mot de passe*)
      module_generateur_mdp ;;
    *météo à*)
      module_meteo "$input" ;;
    *traduis en*)
      module_traduction "$input" ;;
    *cherche*|*c\'est quoi*|*sais-tu*|*qui est*|*définition de*)
      module_recherche_web "$input" ;;
    *au revoir*|*quitter*|*bye*)
      typing "Session terminée. À bientôt !"
      break ;;
    *)
      typing "Commande non comprise. Essayez 'météo à Paris', 'cherche...', 'traduis en...', 'blague', 'info système', 'génère un mot de passe'..." ;;
  esac
done
