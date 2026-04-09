from sqlalchemy.orm import Session
from app.models.rol import Rol
from app.schemas.rol import RolCreate, RolUpdate

def get_roles(db: Session):
    return db.query(Rol).all()

def get_rol_por_id(db: Session, id: int):
    return db.query(Rol).filter(Rol.id == id).first()

def get_rol_por_nombre(db: Session, nombre: str):
    return db.query(Rol).filter(Rol.nombre == nombre).first()

def crear_rol(db: Session, rol: RolCreate):
    db_rol = Rol(
        nombre=rol.nombre,
        descripcion=rol.descripcion
    )
    db.add(db_rol)
    db.commit()
    db.refresh(db_rol)
    return db_rol

def actualizar_rol(db: Session, id: int, rol: RolUpdate):
    db_rol = get_rol_por_id(db, id)
    if not db_rol:
        return None
    if rol.nombre is not None:
        db_rol.nombre = rol.nombre
    if rol.descripcion is not None:
        db_rol.descripcion = rol.descripcion
    if rol.activo is not None:
        db_rol.activo = rol.activo
    db.commit()
    db.refresh(db_rol)
    return db_rol

def asignar_rol_a_usuario(db: Session, usuario_id: int, rol_id: int):
    from app.models.usuario import Usuario
    usuario = db.query(Usuario).filter(Usuario.id == usuario_id).first()
    if not usuario:
        return None
    usuario.rol_id = rol_id
    db.commit()
    db.refresh(usuario)
    return usuario