# 🎙️ VoxLocal AI : Assistant Vocal Privé (Groq + Piper TTS)

**VoxLocal AI** est un serveur d'assistance vocale hybride conçu pour être le "cerveau" et la "voix" de votre application mobile. 

Il combine la vitesse fulgurante des modèles de langage de **Groq** (pour générer des réponses intelligentes) avec la confidentialité de **Piper TTS** (pour synthétiser la voix 100% en local sur votre machine). Le tout est packagé pour **NixOS** et exposé de manière sécurisée via **Cloudflare Tunnels**.

## ✨ Fonctionnalités Principales

* **Cerveau Cloud ultra-rapide :** Utilise l'API Groq (Llama 3) pour des réponses intelligentes et instantanées.
* **Voix 100% Locale :** La synthèse vocale est calculée sur votre processeur via Piper TTS (modèle neuronal français *Siwis*). Votre voix ne fuite pas sur Internet.
* **Formatage Spécial Voix :** Le prompt système de l'IA est optimisé pour générer du texte fluide, sans caractères Markdown imprononçables.
* **Architecture NixOS :** Environnement de développement reproductible (`shell.nix`) sans conflit de dépendances.
* **API Mobile-Ready :** Renvoie directement le flux audio `.wav` ainsi que le texte généré dans les en-têtes HTTP pour un affichage synchronisé sur l'application mobile.

## 🏗️ Architecture du Flux (Workflow)

1. **📱 Application Mobile** envoie une question texte (`POST /chat`).
2. **⚙️ FastAPI (NixOS)** reçoit la question et l'envoie à l'API **Groq**.
3. **🧠 Groq** génère la réponse intelligente et la renvoie à FastAPI.
4. **🗣️ Piper TTS** transforme cette réponse texte en fichier audio localement.
5. **📤 FastAPI** renvoie le fichier audio au téléphone, ajoute le texte dans les headers, puis supprime le fichier temporaire du serveur.

## 🛠️ Prérequis

* Un système avec **Nix** installé (NixOS recommandé).
* Une clé API gratuite sur [Groq Console](https://console.groq.com/).

## 📦 Installation

1. **Préparer le dossier du projet :**
   ```bash
   mkdir voxlocal-ai && cd voxlocal-ai
