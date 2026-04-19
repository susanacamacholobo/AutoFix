import os
import base64
import anthropic
from groq import Groq
from dotenv import load_dotenv
from sqlalchemy.orm import Session
from app.models.evidencia import Evidencia
from app.models.incidente import Incidente

load_dotenv()

cliente_anthropic = anthropic.Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))
cliente_groq = Groq(api_key=os.getenv("GROQ_API_KEY"))


def analizar_texto(descripcion: str) -> dict:
    """Analiza el texto descriptivo del conductor y extrae información relevante."""
    if not descripcion:
        return {"resumen": "", "tipo_detectado": "desconocido"}

    respuesta = cliente_anthropic.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=500,
        messages=[
            {
                "role": "user",
                "content": f"""Eres un asistente especializado en emergencias vehiculares.
Analiza la siguiente descripción de un incidente vehicular y extrae:
1. Tipo de problema (batería, llanta, motor, choque, grúa, u otro)
2. Un resumen breve en 2 oraciones

Descripción: {descripcion}

Responde SOLO en este formato JSON:
{{"tipo": "...", "resumen": "..."}}"""
            }
        ]
    )

    import json
    texto = respuesta.content[0].text.strip()
    try:
        return json.loads(texto)
    except Exception:
        return {"tipo": "desconocido", "resumen": texto}


def transcribir_audio(ruta_audio: str) -> str:
    """Transcribe un archivo de audio usando Groq Whisper."""
    ruta_completa = ruta_audio.lstrip("/")

    if not os.path.exists(ruta_completa):
        return ""

    with open(ruta_completa, "rb") as archivo:
        transcripcion = cliente_groq.audio.transcriptions.create(
            file=(os.path.basename(ruta_completa), archivo.read()),
            model="whisper-large-v3",
            language="es"
        )

    return transcripcion.text


def analizar_imagen(ruta_imagen: str) -> str:
    """Analiza una imagen del vehículo usando Claude Vision."""
    ruta_completa = ruta_imagen.lstrip("/")

    if not os.path.exists(ruta_completa):
        return ""

    extension = ruta_imagen.split(".")[-1].lower()
    media_types = {
        "jpg": "image/jpeg",
        "jpeg": "image/jpeg",
        "png": "image/png",
        "webp": "image/webp",
        "gif": "image/gif"
    }
    media_type = media_types.get(extension, "image/jpeg")

    with open(ruta_completa, "rb") as f:
        imagen_base64 = base64.standard_b64encode(f.read()).decode("utf-8")

    respuesta = cliente_anthropic.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=300,
        messages=[
            {
                "role": "user",
                "content": [
                    {
                        "type": "image",
                        "source": {
                            "type": "base64",
                            "media_type": media_type,
                            "data": imagen_base64
                        }
                    },
                    {
                        "type": "text",
                        "text": """Eres un experto en daños vehiculares.
Describe brevemente en 1-2 oraciones qué daños o problemas visibles tiene el vehículo en la imagen.
Si no hay daños visibles o la imagen no muestra un vehículo, indicalo."""
                    }
                ]
            }
        ]
    )

    return respuesta.content[0].text.strip()


def analizar_incidente(db: Session, incidente_id: int):
    """
    Función principal que analiza todas las evidencias de un incidente
    y genera un resumen estructurado. Se ejecuta en background tras el CU05.
    """
    incidente = db.query(Incidente).filter(Incidente.id == incidente_id).first()
    if not incidente:
        return

    evidencias = db.query(Evidencia).filter(Evidencia.incidente_id == incidente_id).all()

    resumen_texto = {}
    transcripciones = []
    analisis_imagenes = []

    # Analizar texto descriptivo del incidente
    if incidente.descripcion:
        resumen_texto = analizar_texto(incidente.descripcion)

    # Procesar cada evidencia según su tipo
    for evidencia in evidencias:
        if evidencia.tipo == "audio":
            transcripcion = transcribir_audio(evidencia.url)
            if transcripcion:
                transcripciones.append(transcripcion)

        elif evidencia.tipo in ("imagen", "foto"):
            analisis = analizar_imagen(evidencia.url)
            if analisis:
                analisis_imagenes.append(analisis)

    # Consolidar todo en un resumen final
    partes_resumen = []

    if resumen_texto.get("resumen"):
        partes_resumen.append(f"Descripción: {resumen_texto['resumen']}")

    if transcripciones:
        partes_resumen.append(f"Audio: {' '.join(transcripciones)}")

    if analisis_imagenes:
        partes_resumen.append(f"Imágenes: {' '.join(analisis_imagenes)}")

    resumen_final = " | ".join(partes_resumen) if partes_resumen else "Sin información adicional"
    tipo_detectado = resumen_texto.get("tipo", incidente.tipo or "desconocido")

    # Actualizar el incidente con el análisis de IA
    incidente.descripcion = resumen_final
    incidente.tipo = tipo_detectado
    db.commit()
    db.refresh(incidente)

    return {
        "resumen": resumen_final,
        "tipo_detectado": tipo_detectado,
        "transcripciones": transcripciones,
        "analisis_imagenes": analisis_imagenes
    }