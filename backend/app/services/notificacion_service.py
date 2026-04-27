import os
import json
import firebase_admin
from firebase_admin import credentials, messaging

if not firebase_admin._apps:
    firebase_json = os.getenv("FIREBASE_CREDENTIALS_JSON")
    if firebase_json:
        cred_dict = json.loads(firebase_json)
        cred = credentials.Certificate(cred_dict)
    else:
        cred = credentials.Certificate("firebase-credentials.json")
    firebase_admin.initialize_app(cred)

def enviar_notificacion(fcm_token: str, titulo: str, cuerpo: str, datos: dict = None):
    """Envía una notificación push a un dispositivo específico."""
    try:
        message = messaging.Message(
            notification=messaging.Notification(
                title=titulo,
                body=cuerpo,
            ),
            data=datos or {},
            token=fcm_token,
        )
        response = messaging.send(message)
        print(f"Notificación enviada: {response}")
        return True
    except Exception as e:
        print(f"Error enviando notificación: {e}")
        return False


def notificar_taller_aceptado(fcm_token: str, taller_nombre: str):
    """CU12 - Notifica al conductor que el taller aceptó su solicitud."""
    return enviar_notificacion(
        fcm_token=fcm_token,
        titulo="🏪 Taller asignado",
        cuerpo=f"{taller_nombre} aceptó tu solicitud de asistencia.",
        datos={"tipo": "taller_aceptado"}
    )


def notificar_tecnico_asignado(fcm_token: str, tecnico_nombre: str, minutos: int = None):
    """CU12 - Notifica al conductor que se le asignó un técnico."""
    cuerpo = f"{tecnico_nombre} está en camino para asistirte."
    if minutos:
        cuerpo += f" Llegada estimada: {minutos} minutos."
    return enviar_notificacion(
        fcm_token=fcm_token,
        titulo="👨‍🔧 Técnico en camino",
        cuerpo=cuerpo,
        datos={"tipo": "tecnico_asignado"}
    )


def notificar_servicio_completado(fcm_token: str):
    """CU12 - Notifica al conductor que el servicio fue completado."""
    return enviar_notificacion(
        fcm_token=fcm_token,
        titulo="✅ Servicio completado",
        cuerpo="Tu vehículo ha sido atendido correctamente.",
        datos={"tipo": "servicio_completado"}
    )