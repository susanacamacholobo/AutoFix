from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.schemas.rol import RolCreate, RolUpdate, RolResponse
from app.services import rol_service
from app.core.dependencies import get_current_user
from app.models.usuario import Usuario
from typing import List

router = APIRouter(
    prefix="/roles",
    tags=["roles"]
)

@router.get("/", response_model=List[RolResponse])
def listar_roles(
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    return rol_service.get_roles(db)

@router.post("/", response_model=RolResponse)
def crear_rol(
    rol: RolCreate,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    db_rol = rol_service.get_rol_por_nombre(db, rol.nombre)
    if db_rol:
        raise HTTPException(status_code=400, detail="El rol ya existe")
    return rol_service.crear_rol(db, rol)

@router.put("/{id}", response_model=RolResponse)
def actualizar_rol(
    id: int,
    rol: RolUpdate,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    db_rol = rol_service.actualizar_rol(db, id, rol)
    if not db_rol:
        raise HTTPException(status_code=404, detail="Rol no encontrado")
    return db_rol

@router.post("/{usuario_id}/asignar/{rol_id}")
def asignar_rol(
    usuario_id: int,
    rol_id: int,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    usuario = rol_service.asignar_rol_a_usuario(db, usuario_id, rol_id)
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return {"mensaje": f"Rol asignado correctamente al usuario {usuario.email}"}