from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import Optional

class TallerBase(BaseModel):
    nombre: str
    email: EmailStr
    telefono: Optional[str] = None
    direccion: Optional[str] = None
    especialidad: Optional[str] = None
    latitud: Optional[float] = None
    longitud: Optional[float] = None

class TallerCreate(TallerBase):
    contrasena: str

class TallerResponse(TallerBase):
    id: int
    activo: bool
    fecha_registro: datetime

    class Config:
        from_attributes = True