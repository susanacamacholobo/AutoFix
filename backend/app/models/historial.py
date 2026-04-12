from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.db.database import Base

class Historial(Base):
    __tablename__ = "historial"

    id = Column(Integer, primary_key=True, index=True)
    incidente_id = Column(Integer, ForeignKey("incidentes.id"))
    taller_id = Column(Integer, ForeignKey("talleres.id"), nullable=True)
    estado_anterior = Column(String(20))
    estado_nuevo = Column(String(20))
    observacion = Column(Text)
    fecha = Column(DateTime, server_default=func.now())