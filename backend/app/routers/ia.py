from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.core.dependencies import get_current_user
from app.models.usuario import Usuario
from app.models.incidente import Incidente
from app.services import ia_service

router = APIRouter(
    prefix="/ia",
    tags=["inteligencia artificial"]
)


@router.post("/analizar/{incidente_id}")
def analizar_incidente(
    incidente_id: int,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    """
    Dispara el análisis de IA para un incidente específico.
    Se ejecuta en background para no bloquear la respuesta.
    """
    incidente = db.query(Incidente).filter(Incidente.id == incidente_id).first()
    if not incidente:
        raise HTTPException(status_code=404, detail="Incidente no encontrado")

    background_tasks.add_task(ia_service.analizar_incidente, db, incidente_id)

    return {"mensaje": f"Análisis iniciado para el incidente {incidente_id}"}


@router.get("/resumen/{incidente_id}")
def obtener_resumen(
    incidente_id: int,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    """
    Devuelve el resumen generado por la IA para un incidente.
    Lo consulta el panel web del taller.
    """
    incidente = db.query(Incidente).filter(Incidente.id == incidente_id).first()
    if not incidente:
        raise HTTPException(status_code=404, detail="Incidente no encontrado")

    return {
        "incidente_id": incidente_id,
        "tipo": incidente.tipo,
        "prioridad": incidente.prioridad,
        "estado": incidente.estado,
        "resumen": incidente.resumen_ia
    }