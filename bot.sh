#!/bin/sh
# Bot-Shell-Modular - Un bot Shell avec un cerveau modulaire

# --- MODULES CÉRÉBRAUX (FONCTIONS) ---

# Module pour les conversations de base
module_conversation() {
  case $(echo "$1" | tr '[:upper:]' '[:lower:]') in
    *bonjour*|*salut*)
      typing "Salut ! Comment puis-je vous aider aujourd'hui ?"
      ;;
    *ça va*)
      typing "Je suis un programme, donc je fonctionne à plein régime ! Et vous ?"
      ;;
  esac
}

# Module pour donner l'heure et la date
module_temps() {
  case $(echo "$1" | tr '[:upper:]' '[:lower:]') in
    *heure*)
      typing "Il est exactement $(date +'%H heures et %M minutes')."
      ;;
    *date*)
      typing "Nous sommes le $(date +'%A %d %B %Y')."
      ;;
  esac
}

# Module pour faire des calculs
module_calcul() {
  # Retire le mot "calcule" pour n'avoir que l'opération
  operation=$(echo "$1" | sed 's/calcule //i')
  # Tente le calcul et gère les erreurs
  resultat=$(LC_NUMERIC=C awk "BEGIN {print $operation}")
  if [ $? -eq 0 ]; then
    typing "Le résultat de $operation est $resultat."
  else
    typing "Désolé, je n'ai pas pu comprendre ce calcul."
  fi
}

# Module pour chercher sur le web avec l'API DuckDuckGo
module_recherche_web() {
  typing "Un instant, je consulte ma base de données mondiale..."
  query=$(echo "$1" | sed -E -e 's/cherche //i' -e "s/c'est quoi //i" -e 's/sais-tu que //i' -e 's/qui est //i')
  url_query=$(echo "$query" | sed 's/ /+/g')
  api_response=$(curl -s "https://api.duckduckgo.com/?q=${url_query}&format=json" | jq -r '.AbstractText')

  if [ -n "$api_response" ] && [ "$api_response" != "null" ]; then
    typing "$api_response"
  else
    typing "Je n'ai rien trouvé de concluant pour '$query'."
  fi
}

# NOUVEAU : Module pour donner des infos sur le système
module_systeme() {
    typing "Voici quelques informations sur le système sur lequel je fonctionne :"
    typing "Type de système : $(uname -s)"
    typing "Architecture : $(uname -m)"
    # La commande 'free' ou 'df' peut être limitée sur iSH, mais on essaie
    typing "Utilisation de la mémoire : $(free -h | grep Mem | awk '{print $3 "/" $2}')"
}


# --- UTILITAIRES ---
# Fonction pour simuler la frappe
typing() {
  text="$1"
  delay=0.03
  for i in $(seq 0 $(expr length "${text}" - 1)); do
    echo -n "${text:$i:1}"
    sleep ${delay}
  done
  echo ""
}

# --- DÉMARRAGE DU BOT ---
typing "Bonjour ! Je suis Bot-Shell-Modular. Mon cerveau a été mis à jour."

# --- BOUCLE PRINCIPALE (LE CERVEAU / AIGUILLEUR) ---
while true; do
  printf "Vous> "
  read input

  # L'aiguilleur qui envoie l'input au bon module
  case $(echo "$input" | tr '[:upper:]' '[:lower:]') in
    *bonjour*|*salut*|*ça va*)
      module_conversation "$input"
      ;;
    *heure*|*date*)
      module_temps "$input"
      ;;
    *calcule*)
      module_calcul "$input"
      ;;
    *cherche*|*c\'est quoi*|*sais-tu*|*qui est*)
      module_recherche_web "$input"
      ;;
    *système*|*info système*)
      module_systeme
      ;;
    *au revoir*|*quitter*|*bye*)
      typing "Opération terminée. Au revoir."
      break
      ;;
    *)
      typing "Commande non reconnue. Essayez 'cherche', 'calcule', 'date', 'heure' ou 'info système'."
      ;;
  esac
done
