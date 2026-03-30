# 🎙️ mamAI : Memory Agenda Master AI
> *"L'intelligence souveraine au creux de la main, la confidentialité en plus."*

**mamAI** est un assistant personnel hybride conçu pour transformer votre serveur **NixOS** en un véritable centre de commande façon J.A.R.V.I.S. Il combine la puissance de calcul brute du Cloud pour la réflexion et la sécurité du local pour la voix.

---

## 🧩 L'ADN de mamAI (Le concept JARVIS)
*   **M**emory : Une mémoire contextuelle pour un assistant qui apprend de vous.
*   **A**genda : Gestion intelligente du temps, des rendez-vous et des rappels.
*   **M**aster : L'orchestrateur central (FastAPI) qui pilote les services.
*   **AI** : Inférence ultra-rapide via **Llama 3.3 70B** (Groq).

---

## ✨ Fonctionnalités Clés
*   **Cerveau Hybride :** Réponse textuelle quasi-instantanée via l'API **Groq**.
*   **Voix 100% Locale :** Synthèse vocale neuronale via **Piper TTS** (modèle *Siwis*) s'exécutant sur votre CPU.
*   **Souveraineté :** Vos données vocales ne sont jamais envoyées dans le cloud.
*   **Tunneling Sécurisé :** Accès distant chiffré via **Cloudflare Tunnels** (pas d'ouverture de ports).
*   **App Mobile Native :** Interface de chat élégante développée avec **Flutter**.

---

## 🏗️ Architecture Technique

1.  **📱 Client (Flutter)** : Capture le texte et joue le flux audio binaire reçu.
2.  **🛡️ Passerelle (Cloudflare)** : Sécurise l'accès à votre serveur domestique.
3.  **⚙️ Cœur (FastAPI)** : 
    *   Reçoit la requête.
    *   Interroge le LLM.
    *   Déclenche Piper pour générer le `.wav`.
    *   Renvoie l'audio + le texte (via Headers HTTP).
    *   Nettoie les fichiers temporaires.

---

## 🛠️ Installation (NixOS)

### 1. Préparer le serveur
Clonez le dépôt et entrez dans l'environnement reproductible :
```bash
git clone [https://github.com/votre-username/mamAI.git](https://github.com/votre-username/mamAI.git)
cd mamAI
nix-shell