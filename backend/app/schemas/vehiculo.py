from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class VehiculoBase(BaseModel):
    marca: str
    modelo: str
    anio: Optional[int] = None
    placa: str
    color: Optional[str] = None

class VehiculoCreate(VehiculoBase):
    usuario_id: int

class VehiculoResponse(VehiculoBase):
    id: int
    usuario_id: int
    fecha_registro: datetime

    class Config:
        from_attributes = True