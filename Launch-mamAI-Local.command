#!/bin/bash

# 🚀 Script de lancement macOS pour mamAI
# Double-cliquez sur ce fichier pour lancer l'API en local

cd "$(dirname "$0")"

# Vérifier les variables d'environnement
if [ ! -f .env.local ]; then
    cp .env .env.local
    echo "⚠️  Fichier .env.local créé"
    echo "⚠️  Veuillez éditer .env.local et ajouter votre clé Groq"
    exit 1
fi

# Charger les variables
set -a
source .env.local
set +a

# Interface utilisateur
clear
echo "╔════════════════════════════════════════════════════════╗"
echo "║                                                        ║"
echo "║        🎙️  mamAI — Assistant Vocal Local             ║"
echo "║                                                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Lancement de l'API... "
echo ""
echo "📡 Accès : http://127.0.0.1:8000"
echo "📖 Docs  : http://127.0.0.1:8000/docs"
echo ""
echo "Appuyez sur Ctrl+C pour arrêter"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Lancer uvicorn
uvicorn api:app --host 127.0.0.1 --port 8000 --reload

# Garder la fenêtre ouverte à la fermeture
echo ""
echo "L'API s'est arrêtée. Fermez cette fenêtre."
read -p "Appuyez sur Entrée pour quitter"
