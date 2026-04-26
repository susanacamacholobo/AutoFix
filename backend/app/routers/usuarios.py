from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.schemas.usuario import UsuarioCreate, UsuarioResponse
from app.services import usuario_service
from app.core.dependencies import get_current_user
from app.models.usuario import Usuario
from typing import List

router = APIRouter(
    prefix="/usuarios",
    tags=["usuarios"]
)

@router.post("/registro", response_model=UsuarioResponse)
def registrar_conductor(usuario: UsuarioCreate, db: Session = Depends(get_db)):
    db_usuario = usuario_service.get_usuario_por_email(db, usuario.email)
    if db_usuario:
        raise HTTPException(status_code=400, detail="El email ya está registrado")
    nuevo_usuario = usuario_service.crear_usuario(db, usuario)
    # Asignar rol de conductor automáticamente (rol_id=2)
    nuevo_usuario.rol_id = 2
    db.commit()
    db.refresh(nuevo_usuario)
    return nuevo_usuario

@router.post("/", response_model=UsuarioResponse)
def crear_usuario(usuario: UsuarioCreate, db: Session = Depends(get_db)):
    db_usuario = usuario_service.get_usuario_por_email(db, usuario.email)
    if db_usuario:
        raise HTTPException(status_code=400, detail="El email ya está registrado")
    return usuario_service.crear_usuario(db, usuario)

@router.get("/", response_model=List[UsuarioResponse])
def listar_usuarios(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    return usuario_service.get_usuarios(db, skip=skip, limit=limit)

@router.get("/me", response_model=UsuarioResponse)
def obtener_mi_perfil(current_user: Usuario = Depends(get_current_user)):
    return current_user

@router.get("/{id}", response_model=UsuarioResponse)
def obtener_usuario(
    id: int,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    db_usuario = usuario_service.get_usuario_por_id(db, id)
    if not db_usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return db_usuario

@router.post("/fcm-token")
def actualizar_fcm_token(
    datos: dict,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    """Guarda el token FCM del conductor para notificaciones push."""
    current_user.fcm_token = datos.get("fcm_token")
    db.commit()
    return {"mensaje": "Token FCM actualizado correctamente"}