{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    (python3.withPackages (ps: with ps; [
      fastapi
      uvicorn
      pydantic
      python-dotenv
      requests
    ]))
    
    piper-tts
    cloudflared
  ];

  shellHook = ''
    echo "❄️ Environnement NixOS chargé !"
    echo "🧠 Groq API + Piper TTS sont prêts."
  '';
}

