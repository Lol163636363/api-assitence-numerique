#!/usr/bin/env python3
"""
🧪 Script de test pour vérifier que l'API mamAI est correctement configurée
"""

import os
import sys
import subprocess
from pathlib import Path

def check_python():
    """Vérifier la version de Python"""
    print("✓ Python version:", sys.version.split()[0])
    return True

def check_piper_model():
    """Vérifier que le modèle Piper existe"""
    model_path = Path(__file__).parent / "fr_FR-siwis-medium.onnx"
    if model_path.exists():
        size_mb = model_path.stat().st_size / (1024 * 1024)
        print(f"✓ Modèle Piper trouvé ({size_mb:.1f} MB)")
        return True
    else:
        print(f"✗ Modèle Piper non trouvé : {model_path}")
        return False

def check_groq_api_key():
    """Vérifier que la clé Groq est configurée"""
    api_key = os.environ.get("GROQ_API_KEY")
    if api_key and api_key != "your_groq_api_key_here":
        print("✓ GROQ_API_KEY configurée")
        return True
    else:
        print("✗ GROQ_API_KEY non configurée ou vide")
        print("  → Éditer .env.local et ajouter votre clé Groq")
        return False

def check_dependencies():
    """Vérifier les dépendances Python"""
    required = ["fastapi", "uvicorn", "pydantic", "httpx"]
    missing = []
    for package in required:
        try:
            __import__(package.replace("-", "_"))
            print(f"✓ {package}")
        except ImportError:
            missing.append(package)
            print(f"✗ {package}")
    
    if missing:
        print(f"\n💡 Installer les dépendances manquantes :")
        print(f"   pip install {' '.join(missing)}")
        return False
    return True

def main():
    print("════════════════════════════════════════════════════")
    print("🧪 Diagnostic de l'API mamAI")
    print("════════════════════════════════════════════════════\n")
    
    checks = [
        ("Python", check_python),
        ("Modèle Piper TTS", check_piper_model),
        ("Clé API Groq", check_groq_api_key),
        ("Dépendances Python", check_dependencies),
    ]
    
    results = []
    for name, check_func in checks:
        print(f"{name}:")
        try:
            result = check_func()
            results.append((name, result))
        except Exception as e:
            print(f"✗ Erreur : {e}")
            results.append((name, False))
        print()
    
    # Résumé
    print("════════════════════════════════════════════════════")
    passed = sum(1 for _, result in results if result)
    total = len(results)
    print(f"Résumé : {passed}/{total} vérifications réussies")
    
    if passed == total:
        print("✅ Tout est OK ! Lancez l'API avec : ./run-local.sh")
        return 0
    else:
        print("⚠️  Veuillez corriger les erreurs ci-dessus")
        return 1

if __name__ == "__main__":
    sys.exit(main())
