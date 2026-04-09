from sqlalchemy.orm import Session
from app.models.permiso import Permiso, RolPermiso
from app.schemas.permiso import PermisoCreate

def get_permisos(db: Session):
    return db.query(Permiso).all()

def get_permiso_por_id(db: Session, id: int):
    return db.query(Permiso).filter(Permiso.id == id).first()

def crear_permiso(db: Session, permiso: PermisoCreate):
    db_permiso = Permiso(
        nombre=permiso.nombre,
        descripcion=permiso.descripcion
    )
    db.add(db_permiso)
    db.commit()
    db.refresh(db_permiso)
    return db_permiso

def get_permisos_por_rol(db: Session, rol_id: int):
    return db.query(Permiso).join(RolPermiso).filter(RolPermiso.rol_id == rol_id).all()

def asignar_permiso_a_rol(db: Session, rol_id: int, permiso_id: int):
    db_rol_permiso = RolPermiso(rol_id=rol_id, permiso_id=permiso_id)
    db.add(db_rol_permiso)
    db.commit()
    db.refresh(db_rol_permiso)
    return db_rol_permiso

def remover_permiso_de_rol(db: Session, rol_id: int, permiso_id: int):
    db_rol_permiso = db.query(RolPermiso).filter(
        RolPermiso.rol_id == rol_id,
        RolPermiso.permiso_id == permiso_id
    ).first()
    if db_rol_permiso:
        db.delete(db_rol_permiso)
        db.commit()
    return db_rol_permiso