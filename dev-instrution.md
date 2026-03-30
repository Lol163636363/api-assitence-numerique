# mamAI — Fichiers livrés

## Structure
```
mamAI/
├── pubspec.yaml                  ← dépendances Flutter
├── api.py                        ← backend FastAPI (remplace l'existant)
└── lib/
    ├── main.dart                 ← point d'entrée + routing setup/chat
    └── pages/
        ├── setup_page.dart       ← choix du mot-clé (1er lancement)
        └── chat_page.dart        ← chat + wake word detection en continu
```

## Flux complet
```
App ouverte
  └─► setup_page (si 1er lancement)
        └─► utilisateur tape ou dit son mot-clé
              └─► sauvegarde SharedPreferences
                    └─► chat_page
                          └─► boucle wake word (speech_to_text en continu)
                                └─► mot-clé détecté → écoute commande
                                      └─► silence 2s → POST /chat
                                            └─► Groq LLM → Piper TTS
                                                  └─► WAV + X-IA-Reponse
                                                        └─► lecture audio
                                                              └─► retour boucle
```

## Avant de lancer

### Flutter
1. `flutter pub get`
2. Dans `lib/pages/chat_page.dart`, remplacer :
   ```dart
   const String _apiUrl = 'https://TON-TUNNEL.trycloudflare.com/chat';
   ```

### Android
Ajouter dans `android/app/src/main/AndroidManifest.xml` :
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

### iOS
Ajouter dans `ios/Runner/Info.plist` :
```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>mamAI a besoin du micro pour vous écouter.</string>
<key>NSMicrophoneUsageDescription</key>
<string>mamAI a besoin du micro pour vous écouter.</string>
```

### Serveur (NixOS)
Dans `api.py`, adapter :
```python
PIPER_MODEL = "/path/to/fr_FR-siwis-medium.onnx"
```