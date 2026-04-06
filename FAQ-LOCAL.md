# ❓ FAQ — Lancement local de mamAI

## Installation & Configuration

### Q: Comment installer les dépendances rapidement ?
**A:** Trois options :
```bash
# Option 1 : pip (recommandé)
pip install -r requirements.txt

# Option 2 : make
make install

# Option 3 : nix (NixOS/macOS)
nix-shell
```

### Q: Où je rentre ma clé Groq API ?
**A:** Éditer `.env.local` :
```bash
# Copier le template
cp .env .env.local

# Éditer avec votre éditeur
nano .env.local
# ou
code .env.local
```

Ajouter :
```
GROQ_API_KEY=gsk_... (votre clé de https://console.groq.com/keys)
```

### Q: Python n'est pas trouvé ?
**A:** Vérifier l'installation :
```bash
# macOS
brew install python@3.11
python3 --version

# Linux
sudo apt install python3.11
python3 --version
```

---

## Lancement & Exécution

### Q: Comment lancer l'API ?
**A:** 
```bash
# Méthode 1 : Script bash
./run-local.sh

# Méthode 2 : Make
make run

# Méthode 3 : macOS (fichier .command)
Double-cliquez sur "Launch-mamAI-Local.command"

# Méthode 4 : Commande directe
uvicorn api:app --reload
```

### Q: Le port 8000 est déjà utilisé ?
**A:**
```bash
# Trouver le processus utilisant le port
lsof -i :8000

# Tuer le processus (adapter le PID)
kill -9 <PID>

# Ou utiliser un autre port
API_PORT=8001 make run
```

### Q: L'API démarre mais ne répond pas ?
**A:** 
```bash
# Tester la connexion
curl http://127.0.0.1:8000/health

# Si ça ne marche pas, vérifier les logs
# (l'API affiche les erreurs dans le terminal)
```

---

## Dépendances & Modèles

### Q: Piper TTS n'est pas trouvé ?
**A:**
```bash
# Installation
brew install piper-tts              # macOS
sudo apt install piper-tts          # Linux

# Vérifier
which piper

# Tester
echo "Bonjour" | piper --model fr_FR-siwis-medium.onnx
```

### Q: Le modèle Piper `fr_FR-siwis-medium.onnx` n'existe pas ?
**A:** Le modèle doit être dans le répertoire du projet. Vérifier :
```bash
ls -lh /Users/lony/api-assitence-numerique/fr_FR-siwis-medium.onnx

# Taille typique : ~150-200 MB
# Si absent, télécharger depuis le dépôt Piper
```

### Q: Comment vérifier que tout est configuré ?
**A:**
```bash
python3 check-setup.py
```

Cela valide :
- ✓ Python
- ✓ Modèle Piper
- ✓ Clé Groq
- ✓ Dépendances Python

---

## Connexion Flutter/Mobile

### Q: Mon téléphone ne peut pas atteindre l'API ?
**A:** Vérifier :
1. **Même Wi-Fi** (obligatoire pour Android)
2. **IP correcte** : `ipconfig getifaddr en0` (macOS) ou `hostname -I` (Linux)
3. **Port ouvert** : `curl http://192.168.x.x:8000/health`
4. **Firewall** : Autorisez le port 8000 dans les réglages macOS

### Q: L'API est locale mais inaccessible de l'app ?
**A:** Sur Android, `localhost` ne fonctionne pas. Utiliser :
```dart
// ❌ Ne marche pas sur Android
const String _apiUrl = 'http://localhost:8000/chat';

// ✅ Marche
const String _apiUrl = 'http://192.168.1.100:8000/chat';
```

Sur iOS/Émulateur :
```dart
// localhost fonctionne
const String _apiUrl = 'http://127.0.0.1:8000/chat';
```

### Q: Erreur CORS lors de l'appel API ?
**A:** Activer CORS dans `api.py` :
```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # À restreindre en prod
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

---

## Groq API & Erreurs LLM

### Q: "GROQ_API_KEY not found" ou "Invalid API key" ?
**A:**
1. Vérifier qu'on a bien génération une clé sur https://console.groq.com/keys
2. Vérifier qu'elle est bien dans `.env.local`
3. Recharger : `source .env.local` puis `./run-local.sh`

### Q: "Rate limit exceeded" dans les logs Groq ?
**A:** Groq a des limites gratuites. Soit :
- Attendre 1 minute
- Réduire la fréquence des appels
- Passer à un plan payant

### Q: L'API Groq est très lente ?
**A:** C'est normal la première fois (warm-up du modèle). Les appels suivants sont plus rapides.

---

## Nettoyage & Maintenance

### Q: L'API crée des fichiers .wav qui ne sont pas supprimés ?
**A:**
```bash
# Nettoyer les fichiers temporaires
make clean

# Ou manuellement
rm -f /tmp/*.wav
```

### Q: Comment mettre à jour les dépendances ?
**A:**
```bash
pip install --upgrade -r requirements.txt
pip freeze > requirements.txt  # Sauvegarder les versions
```

### Q: Réinitialiser la configuration ?
**A:**
```bash
# Supprimer les fichiers locaux
rm .env.local

# Copier le template par défaut
cp .env .env.local
```

---

## Déploiement & Production

### Q: Comment passer de local à Cloudflare ?
**A:**
1. S'assurer que l'API fonctionne en local
2. Lancer le tunnel :
   ```bash
   cloudflared tunnel --url http://localhost:8000
   ```
3. Copier l'URL Cloudflare : `https://XXXXX.trycloudflare.com`
4. Éditer `lib/pages/chat_page.dart` et remplacer l'URL
5. Redéployer l'app Flutter

### Q: Docker ou déploiement cloud ?
**A:** Pour Docker local :
```bash
docker-compose up
```

Pour déploiement cloud (Heroku, Render, Railway...) :
Utiliser le `Dockerfile` fourni.

---

## Support & Debugging

### Q: Comment voir les logs détaillés ?
**A:**
```bash
PYTHONUNBUFFERED=1 uvicorn api:app --log-level debug
```

### Q: Le serveur crash ou redémarre ?
**A:** Vérifier les logs pour voir l'erreur. Commandes principales :
```bash
# Logs du dernier crash
tail -50 logs.txt  # si vous redirigez les sorties

# Ou simplement lancer sans redirection
./run-local.sh
```

### Q: Où trouver plus d'aide ?
- 📖 [LOCAL-SETUP.md](LOCAL-SETUP.md) — Guide complet
- 📖 [FLUTTER-LOCAL-CONFIG.md](FLUTTER-LOCAL-CONFIG.md) — Config mobile
- 📖 [dev-instrution.md](dev-instrution.md) — Architecture générale
- 🐛 [Issues sur GitHub](https://github.com/Lol163636363/api-assitence-numerique/issues)

---

**Pas trouvé votre question ? Ouvrez une issue ou contactez l'équipe mamAI !**
