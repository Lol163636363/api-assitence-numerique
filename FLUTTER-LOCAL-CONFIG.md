# 📱 Configuration Flutter pour développement local

## 🎯 Objectif
Connecter votre app Flutter au serveur mamAI local au lieu du Cloudflare Tunnel.

## 📍 Trouver votre IP locale

Ouvrez un terminal et exécutez :

### macOS
```bash
ipconfig getifaddr en0
# Résultat typique : 192.168.1.100
```

### Linux
```bash
hostname -I
# Résultat typique : 192.168.1.100
```

### Windows
```bash
ipconfig
# Cherchez "Adresse IPv4" sous votre interface réseau
```

## 🔧 Configuration Flutter

### 1. Localiser le fichier `chat_page.dart`

Chemin : `lib/pages/chat_page.dart`

### 2. Remplacer l'URL Cloudflare

Trouvez cette ligne :
```dart
const String _apiUrl = 'https://TON-TUNNEL.trycloudflare.com/chat';
```

Remplacez-la par (exemple avec IP `192.168.1.100`) :
```dart
const String _apiUrl = 'http://192.168.1.100:8000/chat';
```

### 3. Redémarrer l'app Flutter

```bash
flutter pub get
flutter run
```

## ⚖️ Considérations spéciales par plateforme

### 🍎 iOS
- ✅ `localhost` / `127.0.0.1` fonctionnent directement
- ⚠️ HTTPS ne fonctionne pas en local (utiliser HTTP)
- 🔒 L'app doit avoir la permission d'accéder au réseau local

Éditer `ios/Runner/Info.plist` :
```xml
<key>NSLocalNetworkUsageDescription</key>
<string>Pour communiquer avec le serveur mamAI local</string>
<key>NSBonjourServices</key>
<array>
    <string>_http._tcp</string>
</array>
```

### 🤖 Android
- ❌ `localhost` / `127.0.0.1` **NE fonctionnent PAS** (utilisez l'IP locale)
- ⚠️ Assurez-vous que votre appareil est sur le **même Wi-Fi** que l'ordinateur
- 🔒 Vérifier les permissions dans `AndroidManifest.xml` :

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

### Tester la connexion
```dart
import 'package:http/http.dart' as http;

void testConnection() async {
  try {
    final response = await http.get(
      Uri.parse('http://192.168.1.100:8000/health'),
    );
    if (response.statusCode == 200) {
      print('✅ API accessible');
    }
  } catch (e) {
    print('❌ Impossible de joindre l\'API : $e');
  }
}
```

## 🐛 Dépanner

### L'app dit "Impossible de se connecter"
1. Vérifier que le serveur est en cours d'exécution : `./run-local.sh`
2. Vérifier que l'IP est correcte : `ping 192.168.1.100` (adapter avec votre IP)
3. Vérifier le port : `curl http://192.168.1.100:8000/health`
4. Vérifier le firewall macOS : Réglages → Sécurité

### Le serveur est local mais l'app Flutter ne le voit pas
- **iOS** : Vérifier les permissions dans Info.plist
- **Android** : Vérifier les permissions et le Wi-Fi (même réseau obligatoire)
- **Both** : Le serveur écoute sur `127.0.0.1` ? → Changer pour `0.0.0.0`

```bash
# Dans run-local.sh ou manuelle
uvicorn api:app --host 0.0.0.0 --port 8000 --reload
```

## 🚀 Workflows de développement

### Développement local complet
```bash
# Terminal 1 : Démarrer l'API
cd /Users/lony/api-assitence-numerique
./run-local.sh

# Terminal 2 : Démarrer Flutter
cd ~/mes_projets/mamAI-flutter
flutter run -d <device_id>
```

### Sur un émulateur iOS
```bash
flutter run -d ios
# Utiliser localhost:8000 dans chat_page.dart
```

### Sur un émulateur Android
```bash
flutter run -d emulator-5554
# Utiliser 10.0.2.2:8000 (adresse spéciale Android vers hôte)
```

### Tester rapidement avec cURL
```bash
curl -X POST http://192.168.1.100:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"texte": "Bonjour mamAI"}'
```

## 📋 Checklist avant de déployer

- [ ] API locale fonctionne sur `:8000`
- [ ] IP locale trouvée et testée (`ping` + `curl`)
- [ ] URL dans `chat_page.dart` mise à jour
- [ ] Permissions configurées (iOS `Info.plist`, Android `AndroidManifest.xml`)
- [ ] App Flutter testée en développement
- [ ] Même Wi-Fi pour le mobile et l'ordinateur (Android)
- [ ] Firewall autorise le port 8000

## 🔄 Retour à Cloudflare

Pour revenir au déploiement Cloudflare :
```dart
const String _apiUrl = 'https://TON-TUNNEL.trycloudflare.com/chat';
```

Puis :
```bash
cloudflared tunnel --url http://localhost:8000
```

---

**Besoin d'aide ?** Consultez [LOCAL-SETUP.md](LOCAL-SETUP.md) pour le serveur ou [dev-instrution.md](dev-instrution.md) pour le contexte global.
