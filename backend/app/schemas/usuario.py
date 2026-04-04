from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import Optional

# Base con los campos comunes
class UsuarioBase(BaseModel):
    nombre: str
    apellido: str
    email: EmailStr
    telefono: Optional[str] = None

# Para crear un usuario (incluye contraseña)
class UsuarioCreate(UsuarioBase):
    contrasena: str

# Para responder al cliente (nunca incluye contraseña)
class UsuarioResponse(UsuarioBase):
    id: int
    activo: bool
    fecha_registro: datetime

    class Config:
        from_attributes = True