from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.schemas.incidente import IncidenteCreate, IncidenteUpdate, IncidenteResponse
from app.services import incidente_service
from app.services import ia_service
from app.core.dependencies import get_current_user
from app.models.usuario import Usuario
from app.models.historial import Historial
from app.services import taller_service
from typing import List

router = APIRouter(
    prefix="/incidentes",
    tags=["incidentes"]
)

@router.post("/", response_model=IncidenteResponse)
def crear_incidente(
    incidente: IncidenteCreate,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    db_incidente = incidente_service.crear_incidente(db, incidente)
    background_tasks.add_task(ia_service.analizar_incidente, db, db_incidente.id)
    return db_incidente

@router.get("/", response_model=List[IncidenteResponse])
def listar_incidentes(
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    return incidente_service.get_incidentes(db)

@router.get("/pendientes", response_model=List[IncidenteResponse])
def listar_incidentes_pendientes(
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    return incidente_service.get_incidentes_pendientes(db)

@router.get("/mis-incidentes", response_model=List[IncidenteResponse])
def listar_mis_incidentes(
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    return incidente_service.get_incidentes_por_usuario(db, current_user.id)

@router.get("/historial-rechazos/{taller_id}")
def historial_rechazos(
    taller_id: int,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    rechazos = db.query(Historial).filter(
        Historial.taller_id == taller_id,
        Historial.estado_nuevo == 'rechazado'
    ).all()

    resultado = []
    for rechazo in rechazos:
        incidente = incidente_service.get_incidente_por_id(db, rechazo.incidente_id)
        if incidente:
            resultado.append({
                'historial_id': rechazo.id,
                'incidente_id': rechazo.incidente_id,
                'tipo': incidente.tipo,
                'descripcion': incidente.descripcion,
                'fecha_rechazo': rechazo.fecha,
                'estado_actual': incidente.estado
            })
    return resultado

@router.get("/{id}", response_model=IncidenteResponse)
def obtener_incidente(
    id: int,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    db_incidente = incidente_service.get_incidente_por_id(db, id)
    if not db_incidente:
        raise HTTPException(status_code=404, detail="Incidente no encontrado")
    return db_incidente

@router.put("/{id}", response_model=IncidenteResponse)
def actualizar_incidente(
    id: int,
    datos: IncidenteUpdate,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    taller_id = None
    taller = taller_service.get_taller_por_email(db, current_user.email)
    if taller:
        taller_id = taller.id

    db_incidente = incidente_service.actualizar_incidente(db, id, datos, taller_id)
    if not db_incidente:
        raise HTTPException(status_code=404, detail="Incidente no encontrado")
    return db_incidente