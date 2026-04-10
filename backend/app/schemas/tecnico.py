from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class TecnicoBase(BaseModel):
    nombre: str
    apellido: str
    telefono: Optional[str] = None
    especialidad: Optional[str] = None

class TecnicoCreate(TecnicoBase):
    taller_id: int

class TecnicoUpdate(BaseModel):
    nombre: Optional[str] = None
    apellido: Optional[str] = None
    telefono: Optional[str] = None
    especialidad: Optional[str] = None
    disponible: Optional[bool] = None
    activo: Optional[bool] = None

class TecnicoResponse(TecnicoBase):
    id: int
    taller_id: int
    disponible: bool
    activo: bool
    fecha_registro: datetime

    class Config:
        from_attributes = True