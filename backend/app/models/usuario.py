from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.database import Base

class Usuario(Base):
    __tablename__ = "usuarios"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(100), nullable=False)
    apellido = Column(String(100), nullable=False)
    email = Column(String(150), unique=True, nullable=False)
    telefono = Column(String(20))
    contrasena = Column(String(255), nullable=False)
    fecha_registro = Column(DateTime, server_default=func.now())
    activo = Column(Boolean, default=True)
    rol_id = Column(Integer, ForeignKey("roles.id"))

    rol = relationship("Rol", back_populates="usuarios")
    vehiculos = relationship("Vehiculo", back_populates="usuario")
    fcm_token = Column(String(255), nullable=True)