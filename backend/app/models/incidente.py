from sqlalchemy import Column, Integer, String, Text, DateTime, Numeric, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.database import Base

class Incidente(Base):
    __tablename__ = "incidentes"

    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id"))
    vehiculo_id = Column(Integer, ForeignKey("vehiculos.id"))
    taller_id = Column(Integer, ForeignKey("talleres.id"), nullable=True)
    tecnico_id = Column(Integer, ForeignKey("tecnicos.id"), nullable=True)
    descripcion = Column(Text)
    latitud = Column(Numeric(9,6))
    longitud = Column(Numeric(9,6))
    tipo = Column(String(50))
    prioridad = Column(String(20), default='media')
    estado = Column(String(20), default='pendiente')
    fecha_creacion = Column(DateTime, server_default=func.now())
    fecha_atencion = Column(DateTime, nullable=True)

    usuario = relationship("Usuario", foreign_keys=[usuario_id])
    vehiculo = relationship("Vehiculo", foreign_keys=[vehiculo_id])
    taller = relationship("Taller", foreign_keys=[taller_id])
    tecnico = relationship("Tecnico", foreign_keys=[tecnico_id])