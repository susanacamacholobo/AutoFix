import os
import base64
import httpx
from groq import Groq
from google import genai
from google.genai import types
from sqlalchemy.orm import Session
from app.models.evidencia import Evidencia
from app.models.incidente import Incidente


def descargar_archivo(url: str) -> bytes:
    """Descarga un archivo desde una URL y retorna su contenido en bytes."""
    with httpx.Client() as client:
        respuesta = client.get(url, timeout=30)
        respuesta.raise_for_status()
        return respuesta.content


def analizar_texto(descripcion: str) -> dict:
    """Analiza el texto descriptivo del conductor y extrae información relevante."""
    if not descripcion:
        return {"tipo": "desconocido", "resumen": ""}

    import json
    prompt = f"""Eres un asistente especializado en emergencias vehiculares.
Analiza la siguiente descripción de un incidente vehicular y extrae:
1. Tipo de problema (batería, llanta, motor, choque, grúa, u otro)
2. Un resumen breve en 2 oraciones

Descripción: {descripcion}

Responde SOLO en este formato JSON sin bloques de código:
{{"tipo": "...", "resumen": "..."}}"""

    try:
        cliente = genai.Client(api_key=os.environ["GEMINI_API_KEY"])
        respuesta = cliente.models.generate_content(
            model="gemini-1.5-flash",
            contents=prompt
        )
        texto = respuesta.text.strip().replace("```json", "").replace("```", "").strip()
        return json.loads(texto)
    except Exception as e:
        print(f"Error analizando texto: {e}")
        return {"tipo": "desconocido", "resumen": descripcion}


def transcribir_audio(url_audio: str) -> str:
    """Descarga un audio desde Cloudinary y lo transcribe con Groq Whisper."""
    try:
        contenido = descargar_archivo(url_audio)
        nombre_archivo = url_audio.split("/")[-1]
        cliente = Groq(api_key=os.environ["GROQ_API_KEY"])
        transcripcion = cliente.audio.transcriptions.create(
            file=(nombre_archivo, contenido),
            model="whisper-large-v3",
            language="es"
        )
        return transcripcion.text
    except Exception as e:
        print(f"Error transcribiendo audio: {e}")
        return ""


def analizar_imagen(url_imagen: str) -> str:
    """Descarga una imagen desde Cloudinary y la analiza con Gemini Vision."""
    try:
        contenido = descargar_archivo(url_imagen)
        extension = url_imagen.split(".")[-1].lower().split("?")[0]

        media_types = {
            "jpg": "image/jpeg",
            "jpeg": "image/jpeg",
            "png": "image/png",
            "webp": "image/webp",
            "gif": "image/gif"
        }
        media_type = media_types.get(extension, "image/jpeg")

        cliente = genai.Client(api_key=os.environ["GEMINI_API_KEY"])
        respuesta = cliente.models.generate_content(
            model="gemini-1.5-flash",
            contents=[
                types.Part.from_bytes(data=contenido, mime_type=media_type),
                """Eres un experto en daños vehiculares.
Describe brevemente en 1-2 oraciones qué daños o problemas visibles tiene el vehículo en la imagen.
Si no hay daños visibles o la imagen no muestra un vehículo, indicalo."""
            ]
        )
        return respuesta.text.strip()
    except Exception as e:
        print(f"Error analizando imagen: {e}")
        return ""


def analizar_incidente(db: Session, incidente_id: int):
    """
    Función principal que analiza todas las evidencias de un incidente
    y genera un resumen estructurado. Se ejecuta en background tras el CU05.
    """
    incidente = db.query(Incidente).filter(Incidente.id == incidente_id).first()
    if not incidente:
        return

    if incidente.resumen_ia:
        return

    evidencias = db.query(Evidencia).filter(Evidencia.incidente_id == incidente_id).all()

    resumen_texto = {}
    transcripciones = []
    analisis_imagenes = []

    if incidente.descripcion:
        resumen_texto = analizar_texto(incidente.descripcion)

    for evidencia in evidencias:
        if evidencia.tipo == "audio":
            transcripcion = transcribir_audio(evidencia.url)
            if transcripcion:
                transcripciones.append(transcripcion)

        elif evidencia.tipo in ("imagen", "foto"):
            analisis = analizar_imagen(evidencia.url)
            if analisis:
                analisis_imagenes.append(analisis)

    partes_resumen = []

    if resumen_texto.get("resumen"):
        partes_resumen.append(f"Descripción: {resumen_texto['resumen']}")

    if transcripciones:
        partes_resumen.append(f"Audio: {transcripciones[0]}")

    if analisis_imagenes:
        partes_resumen.append(f"Imágenes: {analisis_imagenes[0]}")

    resumen_final = " | ".join(partes_resumen) if partes_resumen else "Sin información adicional"
    tipo_detectado = resumen_texto.get("tipo", incidente.tipo or "desconocido")

    incidente.resumen_ia = resumen_final
    incidente.tipo = tipo_detectado
    db.commit()
    db.refresh(incidente)

    return {
        "resumen": resumen_final,
        "tipo_detectado": tipo_detectado,
        "transcripciones": transcripciones,
        "analisis_imagenes": analisis_imagenes
    }