import os
import subprocess
import uuid
import requests
from dotenv import load_dotenv
from fastapi import FastAPI, BackgroundTasks
from fastapi.responses import FileResponse
from pydantic import BaseModel

# Charge la clé API depuis le fichier .env
load_dotenv()
GROQ_API_KEY = os.environ.get("GROQ_API_KEY")

app = FastAPI(title="VoxLocal : Serveur Vocal avec IA Groq")

class MessageMobile(BaseModel):
    texte: str

def supprimer_fichier(chemin: str):
    if os.path.exists(chemin):
        os.remove(chemin)
        print(f"🧹 Fichier nettoyé : {chemin}")

def interroger_groq(texte_utilisateur: str) -> str:
    """Envoie le texte à l'API Groq et retourne la réponse de l'IA."""
    url = "https://api.groq.com/openai/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {GROQ_API_KEY}",
        "Content-Type": "application/json"
    }
    
    # Le "System Prompt" est crucial pour dicter le comportement de l'IA à l'oral
    payload = {
        "model": "llama-3.1-8b-instant", # Modèle ultra-rapide et performant
        "messages": [
            {
                "role": "system",
                "content": "Tu es un assistant vocal intelligent, chaleureux et concis. Réponds TOUJOURS en français. Règle absolue : n'utilise JAMAIS de formatage Markdown (aucun astérisque, aucun dièse, aucune liste à puces), de symboles mathématiques complexes ou d'emojis, car ta réponse sera lue à voix haute par un synthétiseur vocal. Fais des phrases naturelles."
            },
            {
                "role": "user",
                "content": texte_utilisateur
            }
        ],
        "temperature": 0.7
    }
    
    reponse = requests.post(url, headers=headers, json=payload)
    reponse.raise_for_status() # Lève une erreur si la clé API est invalide
    
    # Extraction du texte de la réponse
    return reponse.json()["choices"][0]["message"]["content"]
    
@app.post("/chat")
async def discuter_avec_ia(message: MessageMobile, background_tasks: BackgroundTasks):
    print(f"👤 L'utilisateur dit : {message.texte}")
    
    # 1. On demande à Groq de réfléchir
    try:
        print("🧠 Réflexion de l'IA Groq en cours...")
        reponse_ia = interroger_groq(message.texte)
        print(f"🤖 L'IA répond : {reponse_ia}")
    except Exception as e:
        print(f"❌ Erreur Groq : {e}")
        raise HTTPException(status_code=500, detail="L'IA Groq a refusé la requête (Vérifie ta clé API).")
    
    # 2. On génère la voix avec Piper
    nom_fichier = f"audio_{uuid.uuid4().hex}.wav"
    modele_voix = "fr_FR-siwis-medium.onnx"
    
    print(f"🗣️ Génération de la voix dans : {nom_fichier}")
    
    try:
        # On utilise run() au lieu de Popen pour être sûr que Piper a fini avant de continuer
        process = subprocess.run(
            ["piper", "--model", modele_voix, "--output_file", nom_fichier],
            input=reponse_ia.encode('utf-8'),
            capture_output=True
        )
        
        # VERIFICATION CRITIQUE : Le fichier existe-t-il vraiment ?
        if not os.path.exists(nom_fichier):
            print(f"❌ ERREUR : Piper n'a pas généré le fichier. Sortie erreur : {process.stderr.decode()}")
            raise HTTPException(status_code=500, detail="Piper n'a pas pu générer l'audio.")

    except Exception as e:
        print(f"❌ Erreur système lors du lancement de Piper : {e}")
        raise HTTPException(status_code=500, detail="Erreur interne du moteur vocal.")
    
    # 3. On programme le nettoyage
    background_tasks.add_task(supprimer_fichier, nom_fichier)
    
    # 4. On renvoie l'audio
    print("📤 Envoi de la réponse audio au téléphone...")
    header_texte = reponse_ia.replace('\n', ' ').encode('latin-1', 'ignore').decode('latin-1')
    
    return FileResponse(
        path=nom_fichier, 
        media_type="audio/wav", 
        headers={"X-IA-Reponse": header_texte}
    )
