from sqlalchemy import Column, Integer, String, Boolean, DateTime, Numeric
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.database import Base

class Taller(Base):
    __tablename__ = "talleres"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(150), nullable=False)
    email = Column(String(150), unique=True, nullable=False)
    telefono = Column(String(20))
    direccion = Column(String(255))
    especialidad = Column(String(150))
    latitud = Column(Numeric(9,6))
    longitud = Column(Numeric(9,6))
    contrasena = Column(String(255), nullable=False)
    activo = Column(Boolean, default=True)
    fecha_registro = Column(DateTime, server_default=func.now())

    tecnicos = relationship("Tecnico", back_populates="taller")