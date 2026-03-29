{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  # Outils de compilation (CMake et Ninja sont obligatoires pour Flutter Linux)
  nativeBuildInputs = with pkgs; [
    pkg-config
    cmake
    ninja
  ];

  # Librairies requises
  buildInputs = with pkgs; [
    flutter
    gtk3
    glib
    pcre2
    
    # La librairie manquante demandée par ton erreur
    libunwind
    
    # Moteur audio (GStreamer)
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
  ];

  shellHook = ''
    echo "📱 Environnement Flutter Linux (Corrigé) prêt !"
  '';
}