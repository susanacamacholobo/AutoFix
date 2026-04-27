from pydantic import BaseModel
from datetime import datetime
from typing import Optional
from decimal import Decimal

class IncidenteBase(BaseModel):
    descripcion: Optional[str] = None
    latitud: Optional[float] = None
    longitud: Optional[float] = None
    tipo: Optional[str] = None

class IncidenteCreate(IncidenteBase):
    usuario_id: int
    vehiculo_id: int

class IncidenteUpdate(BaseModel):
    estado: Optional[str] = None
    taller_id: Optional[int] = None
    tecnico_id: Optional[int] = None
    prioridad: Optional[str] = None

class IncidenteResponse(IncidenteBase):
    id: int
    usuario_id: int
    vehiculo_id: int
    taller_id: Optional[int] = None
    tecnico_id: Optional[int] = None
    prioridad: str
    estado: str
    fecha_creacion: datetime
    fecha_atencion: Optional[datetime] = None
    resumen_ia: Optional[str] = None
    monto: Optional[Decimal] = None
    comision: Optional[Decimal] = None
    estado_pago: Optional[str] = 'pendiente'

    class Config:
        from_attributes = True