from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class RolBase(BaseModel):
    nombre: str
    descripcion: Optional[str] = None

class RolCreate(RolBase):
    pass

class RolUpdate(BaseModel):
    nombre: Optional[str] = None
    descripcion: Optional[str] = None
    activo: Optional[bool] = None

class RolResponse(RolBase):
    id: int
    activo: bool
    fecha_creacion: datetime

    class Config:
        from_attributes = True