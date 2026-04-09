from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class PermisoBase(BaseModel):
    nombre: str
    descripcion: Optional[str] = None

class PermisoCreate(PermisoBase):
    pass

class PermisoResponse(PermisoBase):
    id: int
    activo: bool
    fecha_creacion: datetime

    class Config:
        from_attributes = True

class RolPermisoCreate(BaseModel):
    rol_id: int
    permiso_id: int

class RolPermisoResponse(BaseModel):
    id: int
    rol_id: int
    permiso_id: int

    class Config:
        from_attributes = True