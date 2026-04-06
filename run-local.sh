#!/bin/bash

# 🚀 Lancement local de l'API mamAI (sans Cloudflare)
# Usage: ./run-local.sh

set -a
source .env
set +a

# Configuration pour le lancement local
export PIPER_MODEL="${PIPER_MODEL:-.$(pwd)/fr_FR-siwis-medium.onnx}"
export API_HOST="${API_HOST:-127.0.0.1}"
export API_PORT="${API_PORT:-8000}"

echo "════════════════════════════════════════════════════════"
echo "🚀 Lancement de l'API mamAI en local"
echo "════════════════════════════════════════════════════════"
echo "📡 Host    : $API_HOST"
echo "🔌 Port    : $API_PORT"
echo "🗣️  Piper   : $PIPER_MODEL"
echo "════════════════════════════════════════════════════════"
echo ""
echo "✅ L'API sera accessible sur : http://$API_HOST:$API_PORT"
echo "📖 Documentation API        : http://$API_HOST:$API_PORT/docs"
echo ""

# Lancer le serveur FastAPI avec uvicorn
uvicorn api:app --host $API_HOST --port $API_PORT --reload
