from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.schemas.taller import TallerCreate, TallerResponse
from app.schemas.tecnico import TecnicoCreate, TecnicoUpdate, TecnicoResponse
from app.services import taller_service, tecnico_service
from app.core.dependencies import get_current_user
from app.models.usuario import Usuario
from typing import List

router = APIRouter(
    prefix="/talleres",
    tags=["talleres"]
)

@router.post("/registro", response_model=TallerResponse)
def registrar_taller(taller: TallerCreate, db: Session = Depends(get_db)):
    db_taller = taller_service.get_taller_por_email(db, taller.email)
    if db_taller:
        raise HTTPException(status_code=400, detail="El email ya está registrado")
    return taller_service.crear_taller(db, taller)

@router.get("/", response_model=List[TallerResponse])
def listar_talleres(
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    return taller_service.get_talleres(db)

@router.get("/{id}", response_model=TallerResponse)
def obtener_taller(
    id: int,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    db_taller = taller_service.get_taller_por_id(db, id)
    if not db_taller:
        raise HTTPException(status_code=404, detail="Taller no encontrado")
    return db_taller

@router.post("/{taller_id}/tecnicos", response_model=TecnicoResponse)
def crear_tecnico(
    taller_id: int,
    tecnico: TecnicoCreate,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    return tecnico_service.crear_tecnico(db, tecnico)

@router.get("/{taller_id}/tecnicos", response_model=List[TecnicoResponse])
def listar_tecnicos(
    taller_id: int,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    return tecnico_service.get_tecnicos_por_taller(db, taller_id)

@router.put("/{taller_id}/tecnicos/{tecnico_id}", response_model=TecnicoResponse)
def actualizar_tecnico(
    taller_id: int,
    tecnico_id: int,
    tecnico: TecnicoUpdate,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    db_tecnico = tecnico_service.actualizar_tecnico(db, tecnico_id, tecnico)
    if not db_tecnico:
        raise HTTPException(status_code=404, detail="Técnico no encontrado")
    return db_tecnico

@router.delete("/{taller_id}/tecnicos/{tecnico_id}")
def eliminar_tecnico(
    taller_id: int,
    tecnico_id: int,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    db_tecnico = tecnico_service.eliminar_tecnico(db, tecnico_id)
    if not db_tecnico:
        raise HTTPException(status_code=404, detail="Técnico no encontrado")
    return {"mensaje": "Técnico desactivado correctamente"}