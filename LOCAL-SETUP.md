# 🚀 Lancement Local de mamAI (sans Cloudflare)

> Guide d'installation et de lancement de l'API mamAI sur votre machine locale

## 📋 Prérequis

### macOS
```bash
# Installer les dépendances avec Homebrew
brew install python@3.11 piper-tts

# Ou si vous utilisez la gestion de paquets système
sudo apt install python3 piper-tts  # Linux (Debian/Ubuntu)
```

### Variables d'environnement
Copier et configurer le fichier `.env.local` :
```bash
cp .env .env.local
```

Éditer `.env.local` et remplacer :
```
GROQ_API_KEY=votre_clé_groq_ici
```

## 🎯 Lancement rapide

### Option 1 : Script bash (recommandé)
```bash
./run-local.sh
```

### Option 2 : Commande directe
```bash
# D'abord charger les variables d'environnement
export GROQ_API_KEY=$(grep GROQ_API_KEY .env.local | cut -d= -f2)

# Lancer le serveur
uvicorn api:app --host 127.0.0.1 --port 8000 --reload
```

### Option 3 : Avec Nix (NixOS/macOS)
```bash
nix-shell
# À l'intérieur du shell
uvicorn api:app --reload
```

## ✅ Vérifier que l'API fonctionne

```bash
# Health check
curl http://127.0.0.1:8000/health

# Documentation interactive (Swagger)
open http://127.0.0.1:8000/docs

# Test du endpoint /chat
curl -X POST http://127.0.0.1:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"texte": "Bonjour, qui es-tu?"}'
```

## 📱 Configuration Flutter (pour le client)

Éditer `lib/pages/chat_page.dart` et remplacer l'URL Cloudflare :

```dart
// ❌ Ancienne configuration (Cloudflare)
const String _apiUrl = 'https://TON-TUNNEL.trycloudflare.com/chat';

// ✅ Nouvelle configuration (local)
const String _apiUrl = 'http://127.0.0.1:8000/chat';
```

**Important :** Sur Android, les appels HTTP vers `localhost` ne fonctionnent pas directement.  
Utilisez l'adresse IP locale de votre machine (ex: `http://192.168.x.x:8000/chat`) à la place.

Pour trouver votre IP locale :
```bash
# macOS / Linux
ifconfig | grep "inet " | grep -v 127.0.0.1

# Ou plus simplement
hostname -I  # Linux
ipconfig getifaddr en0  # macOS
```

## 🔧 Dépanner

### Erreur "ModuleNotFoundError: No module named 'fastapi'"
```bash
pip install fastapi uvicorn pydantic python-dotenv
```

### Erreur Piper TTS non trouvé
```bash
# Vérifier l'installation
which piper

# Ou installer manuellement
brew install piper-tts
```

### Modèle Piper non trouvé
Vérifier que `fr_FR-siwis-medium.onnx` est dans le répertoire `/Users/lony/api-assitence-numerique/`

### Groq API Key invalide
Générer une nouvelle clé sur [console.groq.com](https://console.groq.com/keys)

## 📊 Architecture locale

```
┌─────────────────────────────────────────────────────────────┐
│                  Votre Machine (macOS)                       │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐         ┌──────────────────────┐          │
│  │  Flutter App │◄────────►│  FastAPI @ localhost │          │
│  │ (localhost)  │         │    :8000/chat        │          │
│  └──────────────┘         └──────────────────────┘          │
│                                   ▲                          │
│                                   │                          │
│                    ┌──────────────┴──────────────┐           │
│                    ▼                             ▼           │
│            ┌─────────────────┐        ┌─────────────────┐   │
│            │  Groq LLM API   │        │  Piper TTS      │   │
│            │  (cloud)        │        │  (local CPU)    │   │
│            └─────────────────┘        └─────────────────┘   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## 💡 Tips & Astuces

- **Rechargement automatique** : L'option `--reload` redémarre le serveur quand vous modifiez `api.py`
- **Logs détaillés** : Ajouter `--log-level debug` pour plus de verbosité
- **CORS** : Pour les requêtes cross-origin, activer CORS dans `api.py` si nécessaire
- **Port occupé ?** : Changer `API_PORT` dans `.env.local` et relancer

## 🚀 Production / Déploiement

Une fois prêt pour la production :
- Utiliser Cloudflare Tunnels : `cloudflared tunnel --url http://localhost:8000`
- Ou déployer sur un VPS avec Nginx/gunicorn
- Activer HTTPS avec Let's Encrypt

---

**Questions ?** Consultez le README.md ou le fichier `dev-instrution.md`
