#!/bin/sh
# Bot-Shell-Web - Un bot Shell avec accès au web via l'API DuckDuckGo

# --- PRÉREQUIS ---
# Assurez-vous d'avoir installé jq : apk add jq
# -----------------

# Fonction pour que le bot "tape" sa réponse
typing() {
  text="$1"
  delay=0.03
  for i in $(seq 0 $(expr length "${text}" - 1)); do
    echo -n "${text:$i:1}"
    sleep ${delay}
  done
  echo ""
}

# Salutation de départ
typing "Bonjour ! Je suis Bot-Shell-Web. Posez-moi une question ou demandez-moi de chercher quelque chose."

# Boucle principale du bot
while true; do
  printf "> "
  read input

  # Le CERVEAU du bot
  case $(echo "$input" | tr '[:upper:]' '[:lower:]') in
    *bonjour*|*salut*)
      typing "Salut ! En quoi puis-je vous aider ?"
      ;;

    *heure*)
      typing "Il est $(date +'%H heures et %M minutes')."
      ;;

    # --- NOUVELLE FONCTIONNALITÉ : RECHERCHE WEB ---
    *cherche*|*c\'est quoi*|*sais-tu*|*qui est*)
      typing "Un instant, je cherche sur le web..."

      # 1. Isoler la question de recherche
      # On supprime les mots-clés comme "cherche ", "c'est quoi ", etc.
      query=$(echo "$input" | sed -E -e 's/cherche //i' -e "s/c'est quoi //i" -e 's/sais-tu que //i' -e 's/qui est //i')

      # 2. Formater la question pour une URL (remplace les espaces par '+')
      url_query=$(echo "$query" | sed 's/ /+/g')

      # 3. Appeler l'API avec curl et extraire la réponse avec jq
      # -s pour le mode silencieux
      # jq -r '.AbstractText' prend le champ AbstractText et l'affiche en texte brut (sans les guillemets)
      api_response=$(curl -s "https://api.duckduckgo.com/?q=${url_query}&format=json" | jq -r '.AbstractText')

      # 4. Vérifier si une réponse a été trouvée
      if [ -n "$api_response" ] && [ "$api_response" != "null" ]; then
        typing "$api_response"
      else
        typing "Désolé, je n'ai trouvé aucune réponse directe pour '$query'."
      fi
      ;;

    # --- FIN DE LA NOUVELLE FONCTIONNALITÉ ---

    *calcule*)
      operation=$(echo "$input" | sed 's/calcule //i')
      # On utilise $((...)) qui est plus moderne et puissant que expr
      resultat=$(($operation))
      typing "Le résultat de $operation est $resultat."
      ;;

    *au revoir*|*quitter*|*bye*)
      typing "Au revoir ! N'hésitez pas si vous avez d'autres questions."
      break
      ;;

    *)
      typing "Je ne comprends pas. Vous pouvez me demander de calculer quelque chose, de donner l'heure, ou de chercher une information (ex: 'cherche la hauteur de la tour eiffel')."
      ;;
  esac
done
