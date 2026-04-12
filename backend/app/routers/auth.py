from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.schemas.auth import Token
from app.services import usuario_service
from app.core.security import verificar_contrasena, crear_token

router = APIRouter(
    prefix="/auth",
    tags=["autenticación"]
)

@router.post("/login", response_model=Token)
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    usuario = usuario_service.get_usuario_por_email(db, form_data.username)
    if not usuario:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email o contraseña incorrectos"
        )
    if not verificar_contrasena(form_data.password, usuario.contrasena):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email o contraseña incorrectos"
        )
    if not usuario.activo:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Usuario inactivo"
        )
    token = crear_token({
        "sub": usuario.email,
        "rol": usuario.rol.nombre if usuario.rol else "conductor",
        "id": usuario.id,
        "nombre": usuario.nombre
    })
    return {"access_token": token, "token_type": "bearer"}

@router.post("/logout")
def logout():
    return {"mensaje": "Sesión cerrada correctamente"}