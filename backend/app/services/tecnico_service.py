from sqlalchemy.orm import Session
from app.models.tecnico import Tecnico
from app.schemas.tecnico import TecnicoCreate, TecnicoUpdate

def get_tecnicos_por_taller(db: Session, taller_id: int):
    return db.query(Tecnico).filter(Tecnico.taller_id == taller_id).all()

def get_tecnico_por_id(db: Session, id: int):
    return db.query(Tecnico).filter(Tecnico.id == id).first()

def crear_tecnico(db: Session, tecnico: TecnicoCreate):
    db_tecnico = Tecnico(
        taller_id=tecnico.taller_id,
        nombre=tecnico.nombre,
        apellido=tecnico.apellido,
        telefono=tecnico.telefono,
        especialidad=tecnico.especialidad
    )
    db.add(db_tecnico)
    db.commit()
    db.refresh(db_tecnico)
    return db_tecnico

def actualizar_tecnico(db: Session, id: int, tecnico: TecnicoUpdate):
    db_tecnico = get_tecnico_por_id(db, id)
    if not db_tecnico:
        return None
    for key, value in tecnico.model_dump(exclude_unset=True).items():
        setattr(db_tecnico, key, value)
    db.commit()
    db.refresh(db_tecnico)
    return db_tecnico

def eliminar_tecnico(db: Session, id: int):
    db_tecnico = get_tecnico_por_id(db, id)
    if db_tecnico:
        db_tecnico.activo = False
        db.commit()
        db.refresh(db_tecnico)
    return db_tecnico