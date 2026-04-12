from sqlalchemy.orm import Session
from app.models.incidente import Incidente
from app.schemas.incidente import IncidenteCreate, IncidenteUpdate

def get_incidentes(db: Session):
    return db.query(Incidente).all()

def get_incidente_por_id(db: Session, id: int):
    return db.query(Incidente).filter(Incidente.id == id).first()

def get_incidentes_por_usuario(db: Session, usuario_id: int):
    return db.query(Incidente).filter(Incidente.usuario_id == usuario_id).all()

def get_incidentes_pendientes(db: Session):
    return db.query(Incidente).filter(Incidente.estado == 'pendiente').all()

def crear_incidente(db: Session, incidente: IncidenteCreate):
    db_incidente = Incidente(
        usuario_id=incidente.usuario_id,
        vehiculo_id=incidente.vehiculo_id,
        descripcion=incidente.descripcion,
        latitud=incidente.latitud,
        longitud=incidente.longitud,
        tipo=incidente.tipo,
        estado='pendiente',
        prioridad='media'
    )
    db.add(db_incidente)
    db.commit()
    db.refresh(db_incidente)
    return db_incidente

def actualizar_incidente(db: Session, id: int, datos: IncidenteUpdate):
    db_incidente = get_incidente_por_id(db, id)
    if not db_incidente:
        return None
    for key, value in datos.model_dump(exclude_unset=True).items():
        setattr(db_incidente, key, value)
    db.commit()
    db.refresh(db_incidente)
    return db_incidente