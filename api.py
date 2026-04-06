"""
mamAI — api.py
FastAPI backend : POST /chat → Groq LLM + Piper TTS → stream WAV
"""

import os
import uuid
import subprocess
from urllib.parse import quote

import httpx
from fastapi import FastAPI, BackgroundTasks
from fastapi.responses import FileResponse
from pydantic import BaseModel

app = FastAPI(title="mamAI API")

# ── Config ────────────────────────────────────────────────────────────────────
GROQ_API_KEY = os.environ["GROQ_API_KEY"]
GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions"
MODEL        = "llama-3.3-70b-versatile"
PIPER_MODEL  = os.environ.get(
    "PIPER_MODEL",
    os.path.join(os.path.dirname(__file__), "fr_FR-siwis-medium.onnx")
)

SYSTEM_PROMPT = (
    "Tu es mamAI, un assistant vocal en français. "
    "Réponds de façon concise (1-3 phrases maximum). "
    "N'utilise jamais de Markdown, de listes ou d'astérisques. "
    "Parle directement, sans préambule."
)


# ── Schéma ────────────────────────────────────────────────────────────────────
class ChatPayload(BaseModel):
    texte: str


# ── Endpoint principal ────────────────────────────────────────────────────────
@app.post("/chat")
async def chat(payload: ChatPayload, bg: BackgroundTasks):
    # 1. Appel LLM (Groq)
    async with httpx.AsyncClient(timeout=30) as client:
        resp = await client.post(
            GROQ_API_URL,
            headers={
                "Authorization": f"Bearer {GROQ_API_KEY}",
                "Content-Type": "application/json",
            },
            json={
                "model": MODEL,
                "messages": [
                    {"role": "system", "content": SYSTEM_PROMPT},
                    {"role": "user",   "content": payload.texte},
                ],
                "max_tokens": 200,
                "temperature": 0.7,
            },
        )
        resp.raise_for_status()
        reponse_ia: str = resp.json()["choices"][0]["message"]["content"].strip()

    # 2. Synthèse vocale (Piper TTS)
    wav_path = f"/tmp/{uuid.uuid4()}.wav"
    proc = subprocess.run(
        ["piper", "--model", PIPER_MODEL, "--output_file", wav_path],
        input=reponse_ia.encode("utf-8"),
        capture_output=True,
    )
    if proc.returncode != 0:
        raise RuntimeError(f"Piper error: {proc.stderr.decode()}")

    # 3. Nettoyage différé du fichier WAV
    bg.add_task(os.remove, wav_path)

    # 4. Envoi du flux audio + texte dans le header
    #    → quote() pour encoder les accents en URL-safe
    return FileResponse(
        wav_path,
        media_type="audio/wav",
        headers={
            "X-IA-Reponse": quote(reponse_ia),
            "Access-Control-Expose-Headers": "X-IA-Reponse",
        },
    )


# ── Health check ──────────────────────────────────────────────────────────────
@app.get("/health")
def health():
    return {"status": "ok"}