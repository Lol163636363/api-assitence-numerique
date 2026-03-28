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
        "model": "llama3-8b-8192", # Modèle ultra-rapide et performant
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
    print("🧠 Réflexion de l'IA Groq en cours...")
    reponse_ia = interroger_groq(message.texte)
    print(f"🤖 L'IA répond : {reponse_ia}")
    
    # 2. On génère la voix avec Piper
    nom_fichier = f"audio_{uuid.uuid4().hex}.wav"
    modele_voix = "fr_FR-siwis-medium.onnx"
    
    process = subprocess.Popen(
        ["piper", "--model", modele_voix, "--output_file", nom_fichier],
        stdin=subprocess.PIPE,
        stderr=subprocess.DEVNULL
    )
    process.communicate(input=reponse_ia.encode('utf-8'))
    
    # 3. On programme le nettoyage
    background_tasks.add_task(supprimer_fichier, nom_fichier)
    
    # 4. On renvoie l'audio (et on ajoute la réponse texte dans les headers pour le debug ou l'affichage mobile)
    print("📤 Envoi de la réponse audio au téléphone...")
    
    # On nettoie les retours à la ligne pour que ça passe dans les headers HTTP
    header_texte = reponse_ia.replace('\n', ' ').encode('latin-1', 'ignore').decode('latin-1')
    
    return FileResponse(
        path=nom_fichier, 
        media_type="audio/wav", 
        filename="reponse_ia.wav",
        headers={"X-IA-Reponse": header_texte}
    )
