from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.db.database import Base

class Evidencia(Base):
    __tablename__ = "evidencias"

    id = Column(Integer, primary_key=True, index=True)
    incidente_id = Column(Integer, ForeignKey("incidentes.id"))
    tipo = Column(String(20), nullable=False)
    url = Column(String(255), nullable=False)
    descripcion = Column(Text)
    fecha_subida = Column(DateTime, server_default=func.now())