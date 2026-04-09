from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.schemas.vehiculo import VehiculoCreate, VehiculoResponse
from app.services import vehiculo_service
from app.core.dependencies import get_current_user
from app.models.usuario import Usuario
from typing import List

router = APIRouter(
    prefix="/vehiculos",
    tags=["vehículos"]
)

@router.post("/", response_model=VehiculoResponse)
def crear_vehiculo(
    vehiculo: VehiculoCreate,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    db_vehiculo = vehiculo_service.get_vehiculo_por_placa(db, vehiculo.placa)
    if db_vehiculo:
        raise HTTPException(status_code=400, detail="La placa ya está registrada")
    return vehiculo_service.crear_vehiculo(db, vehiculo)

@router.get("/mis-vehiculos", response_model=List[VehiculoResponse])
def listar_mis_vehiculos(
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    return vehiculo_service.get_vehiculos_por_usuario(db, current_user.id)

@router.get("/{id}", response_model=VehiculoResponse)
def obtener_vehiculo(
    id: int,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    db_vehiculo = vehiculo_service.get_vehiculo_por_id(db, id)
    if not db_vehiculo:
        raise HTTPException(status_code=404, detail="Vehículo no encontrado")
    return db_vehiculo

@router.delete("/{id}")
def eliminar_vehiculo(
    id: int,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    db_vehiculo = vehiculo_service.eliminar_vehiculo(db, id)
    if not db_vehiculo:
        raise HTTPException(status_code=404, detail="Vehículo no encontrado")
    return {"mensaje": "Vehículo eliminado correctamente"}