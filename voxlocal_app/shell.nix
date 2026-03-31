{ pkgs ? import <nixpkgs> { config.allowUnfree = true; } }:

let
  # ── Android SDK ─────────────────────────────────────────────────────────────
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    cmdLineToolsVersion = "11.0";
    toolsVersion        = "26.1.1";
    platformToolsVersion = "34.0.5";
    buildToolsVersions  = [ "34.0.0" ];
    includeEmulator     = false;
    includeSystemImages = false;
    platformVersions    = [ "34" ];         # Android 14 — cible mamAI
    abiVersions         = [ "arm64-v8a" ];  # APK arm64 uniquement
    includeSources      = false;
    includeNDK          = false;
  };

  androidSdk = androidComposition.androidsdk;

in pkgs.mkShell {
  name = "mamai-flutter-env";

  buildInputs = with pkgs; [
    # ── Flutter ────────────────────────────────────────────────────────────────
    flutter

    # ── Android SDK ────────────────────────────────────────────────────────────
    androidSdk
    jdk17          # Java requis par Gradle

    # ── Outils système ─────────────────────────────────────────────────────────
    git
    curl
    unzip
    which

    # ── Pour le backend mamAI (optionnel, si tu lances api.py depuis ici) ──────
    python312
    python312Packages.fastapi
    python312Packages.uvicorn
    python312Packages.httpx
    piper-tts
  ];

  # ── Variables d'environnement ─────────────────────────────────────────────
  shellHook = ''
    # Android SDK
    export ANDROID_HOME="${androidSdk}/libexec/android-sdk"
    export ANDROID_SDK_ROOT="$ANDROID_HOME"

    # Java
    export JAVA_HOME="${pkgs.jdk17}"

    # PATH
    export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
    export PATH="${pkgs.flutter}/bin:$PATH"

    # Désactive la télémétrie Flutter
    flutter config --no-analytics > /dev/null 2>&1 || true

    # Accepte automatiquement les licences Android
    yes | sdkmanager --licenses > /dev/null 2>&1 || true

    echo ""
    echo "╔══════════════════════════════════════╗"
    echo "║       mamAI — Flutter Build Env      ║"
    echo "╠══════════════════════════════════════╣"
    echo "║  flutter build apk --release         ║"
    echo "║    --target-platform android-arm64   ║"
    echo "╚══════════════════════════════════════╝"
    echo ""
    echo "ANDROID_HOME : $ANDROID_HOME"
    echo "JAVA_HOME    : $JAVA_HOME"
    echo "Flutter      : $(flutter --version 2>/dev/null | head -1)"
    echo ""
  '';
}
