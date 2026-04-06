# 🚀 DÉMARRAGE RAPIDE — mamAI Local

> Lancez l'API mamAI en local en **5 minutes** sans Cloudflare

## ⚡ TL;DR (Trop Long; pas lu)

```bash
# 1. Installer les dépendances
pip install -r requirements.txt

# 2. Configurer la clé Groq
cp .env .env.local
# Éditer .env.local et ajouter votre clé Groq

# 3. Lancer l'API
./run-local.sh
```

L'API est accessible sur : **http://127.0.0.1:8000**

---

## 📋 Installation complète (10 min)

### Étape 1 : Vérifier les prérequis

```bash
# Python >= 3.9
python3 --version

# Piper TTS
brew install piper-tts  # macOS
# ou apt install piper-tts  # Linux
```

### Étape 2 : Cloner le projet (optionnel si déjà cloné)

```bash
git clone https://github.com/Lol163636363/api-assitence-numerique
cd api-assitence-numerique
```

### Étape 3 : Installer les dépendances Python

```bash
make install
# OU
pip install -r requirements.txt
```

### Étape 4 : Configurer l'API Groq

```bash
# Copier le template
cp .env .env.local

# Éditer avec votre éditeur
nano .env.local
# Ajouter votre clé Groq de https://console.groq.com/keys
```

### Étape 5 : Vérifier la configuration

```bash
python3 check-setup.py
```

### Étape 6 : Lancer l'API

```bash
# Option 1 : Script bash
./run-local.sh

# Option 2 : Make
make run

# Option 3 : Commande directe
uvicorn api:app --reload
```

✅ **Success !** L'API est prête sur http://127.0.0.1:8000

---

## 🧪 Tester l'API

### Health Check
```bash
curl http://127.0.0.1:8000/health
# Résultat : {"status":"ok"}
```

### Envoyer un message
```bash
curl -X POST http://127.0.0.1:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"texte": "Bonjour, qui es-tu?"}'
```

### Documentation interactive
Ouvrir dans le navigateur :
```
http://127.0.0.1:8000/docs
```

---

## 📱 Connecter Flutter

Voir **[FLUTTER-LOCAL-CONFIG.md](FLUTTER-LOCAL-CONFIG.md)**

TL;DR :
```dart
// Dans lib/pages/chat_page.dart
const String _apiUrl = 'http://192.168.1.100:8000/chat';
// Remplacer 192.168.1.100 par votre IP locale (ipconfig getifaddr en0)
```

---

## 📚 Fichiers importants

| Fichier | Rôle |
|---------|------|
| **run-local.sh** | 🚀 Lancer l'API |
| **LOCAL-SETUP.md** | 📖 Guide détaillé |
| **FLUTTER-LOCAL-CONFIG.md** | 📱 Config mobile |
| **FAQ-LOCAL.md** | ❓ Questions fréquentes |
| **Makefile** | ⚙️ Commandes utiles |
| **check-setup.py** | 🧪 Vérifier la config |
| **docker-compose.yml** | 🐳 Docker |

---

## 🎯 Commandes principales

```bash
make run              # Lancer l'API
make dev              # Lancer avec rechargement auto
make test             # Tester la connexion
make check            # Vérifier la configuration
make clean            # Nettoyer les fichiers temp
```

---

## 🐛 Problèmes courants

| Problème | Solution |
|----------|----------|
| Port 8000 utilisé | `API_PORT=8001 make run` |
| Piper non trouvé | `brew install piper-tts` |
| Clé Groq invalide | Vérifier `.env.local` |
| Flutter ne voit pas l'API | Vérifier l'IP locale et le Wi-Fi |

Voir **[FAQ-LOCAL.md](FAQ-LOCAL.md)** pour plus de solutions.

---

## 🔄 Retour à Cloudflare ?

```bash
# Remplacer l'URL Flutter : https://XXXXX.trycloudflare.com/chat
cloudflared tunnel --url http://localhost:8000
```

---

## 📚 Documentation

- 🏠 [README.md](README.md) — Présentation générale
- 🛠️ [LOCAL-SETUP.md](LOCAL-SETUP.md) — Guide d'installation complet
- 📱 [FLUTTER-LOCAL-CONFIG.md](FLUTTER-LOCAL-CONFIG.md) — Configuration mobile
- 📖 [dev-instrution.md](dev-instrution.md) — Architecture du projet
- ❓ [FAQ-LOCAL.md](FAQ-LOCAL.md) — Q&R

---

## 💡 Tips

- **Rechargement automatique** : Le serveur redémarre quand vous modifiez `api.py`
- **Logs détaillés** : Ajouter `--log-level debug` pour plus d'infos
- **Arrêter** : `Ctrl+C` dans le terminal

---

**Prêt ? Lancez `./run-local.sh` ! 🚀**
