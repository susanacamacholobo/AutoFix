import os
import base64
import httpx
import anthropic
from groq import Groq
from sqlalchemy.orm import Session
from app.models.evidencia import Evidencia
from app.models.incidente import Incidente


def descargar_archivo(url: str) -> bytes:
    with httpx.Client() as client:
        respuesta = client.get(url, timeout=30)
        respuesta.raise_for_status()
        return respuesta.content


def asignar_prioridad(tipo: str) -> str:
    """CU07 - Asigna prioridad automáticamente según el tipo de incidente."""
    prioridades = {
        "choque": "alta",
        "motor": "alta",
        "grua": "alta",
        "bateria": "media",
        "llanta": "media",
        "otro": "media",
        "desconocido": "baja"
    }
    return prioridades.get(tipo.lower(), "media")


def analizar_texto(descripcion: str) -> dict:
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
        cliente = anthropic.Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))
        respuesta = cliente.messages.create(
            model="claude-sonnet-4-5",
            max_tokens=500,
            messages=[{"role": "user", "content": prompt}]
        )
        texto = respuesta.content[0].text.strip()
        return json.loads(texto)
    except Exception as e:
        print(f"Error analizando texto: {e}")
        return {"tipo": "desconocido", "resumen": descripcion}


def transcribir_audio(url_audio: str) -> str:
    try:
        contenido = descargar_archivo(url_audio)
        nombre_archivo = url_audio.split("/")[-1]
        cliente = Groq(api_key=os.getenv("GROQ_API_KEY"))
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
        imagen_base64 = base64.standard_b64encode(contenido).decode("utf-8")

        cliente = anthropic.Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))
        respuesta = cliente.messages.create(
            model="claude-sonnet-4-5",
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
Si no hay daños visibles o la imagen no muestra un vehículo, indicalo.
No uses markdown, asteriscos, ni símbolos de formato. Solo texto plano."""
                        }
                    ]
                }
            ]
        )
        texto = respuesta.content[0].text.strip()
        texto = texto.replace("**", "").replace("# ", "").replace("##", "").replace("#", "")
        return texto
    except Exception as e:
        print(f"Error analizando imagen: {e}")
        return ""


def analizar_incidente(db: Session, incidente_id: int):
    """CU06 + CU07 - Analiza el incidente y asigna tipo y prioridad automáticamente."""
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
    prioridad_asignada = asignar_prioridad(tipo_detectado)

    incidente.resumen_ia = resumen_final
    incidente.tipo = tipo_detectado
    incidente.prioridad = prioridad_asignada
    db.commit()
    db.refresh(incidente)

    # CU08 - Asignar taller más cercano automáticamente
    from app.services import asignacion_service
    taller_asignado = asignacion_service.asignar_taller_cercano(db, incidente_id)

    return {
        "resumen": resumen_final,
        "tipo_detectado": tipo_detectado,
        "prioridad_asignada": prioridad_asignada,
        "taller_asignado": taller_asignado.nombre if taller_asignado else None,
        "transcripciones": transcripciones,
        "analisis_imagenes": analisis_imagenes
    }