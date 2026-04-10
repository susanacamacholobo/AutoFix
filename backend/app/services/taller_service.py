from sqlalchemy.orm import Session
from app.models.taller import Taller
from app.schemas.taller import TallerCreate
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_talleres(db: Session):
    return db.query(Taller).all()

def get_taller_por_id(db: Session, id: int):
    return db.query(Taller).filter(Taller.id == id).first()

def get_taller_por_email(db: Session, email: str):
    return db.query(Taller).filter(Taller.email == email).first()

def crear_taller(db: Session, taller: TallerCreate):
    contrasena_hash = pwd_context.hash(taller.contrasena)
    db_taller = Taller(
        nombre=taller.nombre,
        email=taller.email,
        telefono=taller.telefono,
        direccion=taller.direccion,
        especialidad=taller.especialidad,
        latitud=taller.latitud,
        longitud=taller.longitud,
        contrasena=contrasena_hash
    )
    db.add(db_taller)
    db.commit()
    db.refresh(db_taller)
    return db_taller

def actualizar_taller(db: Session, id: int, datos: dict):
    db_taller = get_taller_por_id(db, id)
    if not db_taller:
        return None
    for key, value in datos.items():
        setattr(db_taller, key, value)
    db.commit()
    db.refresh(db_taller)
    return db_taller