from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.database import Base

class Tecnico(Base):
    __tablename__ = "tecnicos"

    id = Column(Integer, primary_key=True, index=True)
    taller_id = Column(Integer, ForeignKey("talleres.id"))
    nombre = Column(String(100), nullable=False)
    apellido = Column(String(100), nullable=False)
    telefono = Column(String(20))
    especialidad = Column(String(100))
    disponible = Column(Boolean, default=True)
    activo = Column(Boolean, default=True)
    fecha_registro = Column(DateTime, server_default=func.now())

    taller = relationship("Taller", back_populates="tecnicos")