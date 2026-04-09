from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.database import Base

class Vehiculo(Base):
    __tablename__ = "vehiculos"

    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id"))
    marca = Column(String(50), nullable=False)
    modelo = Column(String(50), nullable=False)
    anio = Column(Integer)
    placa = Column(String(20), unique=True, nullable=False)
    color = Column(String(30))
    fecha_registro = Column(DateTime, server_default=func.now())

    usuario = relationship("Usuario", back_populates="vehiculos")