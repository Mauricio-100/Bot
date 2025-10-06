#!/bin/sh
# Bot-Shell-Pro - Un bot modulaire avec mémoire et outils avancés

# --- FICHIERS DE DONNÉES ---
# Le bot va créer ces fichiers pour fonctionner
FICHIER_BLAGUES="blagues.txt"
FICHIER_MEMOIRE="memoire.db"


#################################################################
# 🧠 MODULES DU CERVEAU LOCAL (OUTILS SHELL) 🧠                  #
#################################################################

# 💬 Module de conversation
module_conversation() {
  case $(echo "$1" | tr '[:upper:]' '[:lower:]') in
    *bonjour*|*salut*) typing "Salutations ! Quelles sont les instructions pour aujourd'hui ?" ;;
    *merci*) typing "À votre service." ;;
  esac
}

# 😂 Module de blagues
module_blague() {
  [ -f "$FICHIER_BLAGUES" ] && typing "$(shuf -n 1 $FICHIER_BLAGUES)" || typing "Je ne trouve pas mon fichier de blagues."
}

# 🔐 Module générateur de mot de passe
module_generateur_mdp() {
  printf "Longueur du mot de passe ? > "
  read longueur
  if ! [[ "$longueur" =~ ^[0-9]+$ ]]; then
    typing "Erreur : Longueur non valide."
    return
  fi
  mdp=$(head /dev/urandom | tr -dc 'A-Za-z0-9!@#$%^&*' | head -c${longueur})
  typing "Mot de passe généré : $mdp"
}

# 💾 NOUVEAU : Module de mémoire persistante
module_memoire() {
  input_lower=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  # Crée le fichier mémoire s'il n'existe pas
  touch "$FICHIER_MEMOIRE"

  if [[ $input_lower == *"souviens-toi que"* ]]; then
    # Syntaxe: "souviens-toi que [clé] est [valeur]"
    cle=$(echo "$input_lower" | sed -n 's/.*souviens-toi que \(.*\) est .*/\1/p' | sed 's/^[ \t]*//;s/[ \t]*$//')
    valeur=$(echo "$input_lower" | sed -n 's/.* est \(.*\)/\1/p' | sed 's/^[ \t]*//;s/[ \t]*$//')
    
    # Supprime l'ancienne entrée si elle existe
    grep -v "^${cle}:" "$FICHIER_MEMOIRE" > "${FICHIER_MEMOIRE}.tmp" && mv "${FICHIER_MEMOIRE}.tmp" "$FICHIER_MEMOIRE"
    # Ajoute la nouvelle entrée
    echo "${cle}:${valeur}" >> "$FICHIER_MEMOIRE"
    typing "C'est noté. Je me souviendrai que '${cle}' est '${valeur}'."

  elif [[ $input_lower == *"rappelle-moi"* ]]; then
    # Syntaxe: "rappelle-moi [clé]"
    cle=$(echo "$input_lower" | sed 's/rappelle-moi //')
    resultat=$(grep "^${cle}:" "$FICHIER_MEMOIRE" | cut -d':' -f2-)
    
    if [ -n "$resultat" ]; then
      typing "Vous m'avez demandé de me souvenir que '${cle}' est '${resultat}'."
    else
      typing "Je n'ai aucune information concernant '${cle}'."
    fi
  fi
}


#################################################################
# 🌍 MODULES D'INTELLIGENCE CONNECTÉE (API ET RÉSEAU) 🌍         #
#################################################################

# ☀️ Module Météo
module_meteo() {
  ville=$(echo "$1" | sed -E 's/.*météo à (.*)/\1/i')
  typing "Analyse météo pour $ville..."
  curl -s "wttr.in/${ville}?format=3"
}

# 📚 Module de recherche web
module_recherche_web() {
  typing "Accès à la base de connaissance mondiale..."
  query=$(echo "$1" | sed -E 's/(cherche|c\'est quoi|qui est|définition de) //i')
  url_query=$(echo "$query" | sed 's/ /+/g')
  api_response=$(curl -s "https://api.duckduckgo.com/?q=${url_query}&format=json" | jq -r '.AbstractText')
  [ -n "$api_response" ] && [ "$api_response" != "null" ] && typing "$api_response" || typing "Aucune réponse directe trouvée pour '$query'."
}

# 🔢 NOUVEAU : Module de faits sur les nombres
module_faits_nombres() {
  # Syntaxe : "un fait sur le nombre 42"
  nombre=$(echo "$1" | grep -o '[0-9]*')
  if [ -n "$nombre" ]; then
    typing "Je consulte l'encyclopédie des nombres..."
    fait=$(curl -s "http://numbersapi.com/${nombre}")
    typing "$fait"
  else
    typing "Je n'ai pas compris sur quel nombre vous voulez un fait."
  fi
}

# 📡 NOUVEAU : Module réseau
module_reseau() {
  if [[ $1 == *"ping"* ]]; then
    domaine=$(echo "$1" | sed 's/ping //')
    typing "J'envoie 3 paquets ICMP à ${domaine}..."
    ping -c 3 "$domaine"
  elif [[ $1 == *"whois"* ]]; then
    domaine=$(echo "$1" | sed 's/whois //')
    typing "Récupération des informations WHOIS pour ${domaine}..."
    whois "$domaine"
  fi
}


#################################################################
# 🤖 CŒUR DU BOT (INITIALISATION ET BOUCLE PRINCIPALE) 🤖       #
#################################################################

# Utilitaire pour simuler la frappe
typing() { [ -n "$1" ] && echo "$1"; } # Version simplifiée pour la rapidité

# --- DÉMARRAGE DU BOT ---
typing "Initialisation de Bot-Shell-Pro... Cerveau modulaire en ligne."

# --- BOUCLE PRINCIPALE (L'AIGUILLEUR) ---
while true; do
  printf "Vous> "
  read input

  case $(echo "$input" | tr '[:upper:]' '[:lower:]') in
    *bonjour*|*salut*|*merci*)
      module_conversation "$input" ;;
    *blague*)
      module_blague ;;
    *génère un mot de passe*)
      module_generateur_mdp ;;
    *souviens-toi que*|*rappelle-moi*)
      module_memoire "$input" ;;
    *météo à*)
      module_meteo "$input" ;;
    *fait sur le nombre*)
      module_faits_nombres "$input" ;;
    *ping*|*whois*)
      module_reseau "$input" ;;
    *cherche*|*c\'est quoi*|*qui est*|*définition de*)
      module_recherche_web "$input" ;;
    *au revoir*|*quitter*|*bye*)
      typing "Arrêt des processus. Au revoir."
      break ;;
    "") # Ne rien faire si l'utilisateur appuie sur Entrée
      ;; 
    *)
      typing "Commande non reconnue. Mots-clés : blague, météo, cherche, ping, whois, souviens-toi, rappelle-moi, ... " ;;
  esac
done
