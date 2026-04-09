from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.schemas.permiso import PermisoCreate, PermisoResponse
from app.services import permiso_service
from app.core.dependencies import get_current_user
from app.models.usuario import Usuario
from typing import List

router = APIRouter(
    prefix="/permisos",
    tags=["permisos"]
)

@router.get("/", response_model=List[PermisoResponse])
def listar_permisos(
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    return permiso_service.get_permisos(db)

@router.post("/", response_model=PermisoResponse)
def crear_permiso(
    permiso: PermisoCreate,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    return permiso_service.crear_permiso(db, permiso)

@router.get("/rol/{rol_id}", response_model=List[PermisoResponse])
def listar_permisos_por_rol(
    rol_id: int,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    return permiso_service.get_permisos_por_rol(db, rol_id)

@router.post("/rol/{rol_id}/asignar/{permiso_id}")
def asignar_permiso(
    rol_id: int,
    permiso_id: int,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    try:
        permiso_service.asignar_permiso_a_rol(db, rol_id, permiso_id)
        return {"mensaje": "Permiso asignado correctamente"}
    except Exception:
        raise HTTPException(status_code=400, detail="El permiso ya está asignado a este rol")

@router.delete("/rol/{rol_id}/remover/{permiso_id}")
def remover_permiso(
    rol_id: int,
    permiso_id: int,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    result = permiso_service.remover_permiso_de_rol(db, rol_id, permiso_id)
    if not result:
        raise HTTPException(status_code=404, detail="Permiso no encontrado en este rol")
    return {"mensaje": "Permiso removido correctamente"}