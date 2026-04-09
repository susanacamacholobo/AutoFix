from sqlalchemy.orm import Session
from app.models.vehiculo import Vehiculo
from app.schemas.vehiculo import VehiculoCreate

def get_vehiculos_por_usuario(db: Session, usuario_id: int):
    return db.query(Vehiculo).filter(Vehiculo.usuario_id == usuario_id).all()

def get_vehiculo_por_id(db: Session, id: int):
    return db.query(Vehiculo).filter(Vehiculo.id == id).first()

def get_vehiculo_por_placa(db: Session, placa: str):
    return db.query(Vehiculo).filter(Vehiculo.placa == placa).first()

def crear_vehiculo(db: Session, vehiculo: VehiculoCreate):
    db_vehiculo = Vehiculo(
        usuario_id=vehiculo.usuario_id,
        marca=vehiculo.marca,
        modelo=vehiculo.modelo,
        anio=vehiculo.anio,
        placa=vehiculo.placa,
        color=vehiculo.color
    )
    db.add(db_vehiculo)
    db.commit()
    db.refresh(db_vehiculo)
    return db_vehiculo

def eliminar_vehiculo(db: Session, id: int):
    db_vehiculo = get_vehiculo_por_id(db, id)
    if db_vehiculo:
        db.delete(db_vehiculo)
        db.commit()
    return db_vehiculo