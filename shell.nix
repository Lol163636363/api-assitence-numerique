{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  # 1. Dépendances système et Python
  buildInputs = with pkgs; [
    # Configuration de Python avec toutes les librairies nécessaires
    (python3.withPackages (ps: with ps; [
      fastapi        # Framework Web
      uvicorn        # Serveur ASGI pour lancer FastAPI
      pydantic       # Validation des données (modèle MessageMobile)
      python-dotenv  # Lecture du fichier .env (clé Groq)
      requests       # Appels HTTP vers l'API Groq
    ]))

    # Moteur de synthèse vocale local (neuronal)
    piper-tts
    
    # Outil pour exposer l'API sur internet sans ouvrir de ports
    cloudflared
    
    # Outils utilitaires
    wget
    alsa-utils # Fournit 'aplay' pour les tests sonores locaux
  ];

  # 2. Variables d'environnement et correctifs pour NixOS
  shellHook = ''
    echo "❄️  [VoxLocal-AI] Environnement NixOS chargé avec succès !"
    echo "-------------------------------------------------------"
    echo "🧠 Intelligence : Groq Cloud (Llama 3)"
    echo "🗣️  Voix : Piper TTS (Local)"
    echo "🌐 Tunnel : Cloudflare"
    echo "-------------------------------------------------------"
    echo "👉 Pour lancer l'API : uvicorn api:app --reload"
    echo "👉 Pour le tunnel : cloudflared tunnel --url http://localhost:8000"
    
    # Correction pour les librairies audio sur NixOS
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ pkgs.alsa-lib ]}:$LD_LIBRARY_PATH"
  '';
}
