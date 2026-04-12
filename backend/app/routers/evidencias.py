from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from fastapi.staticfiles import StaticFiles
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.core.dependencies import get_current_user
from app.models.usuario import Usuario
from app.models.evidencia import Evidencia
import aiofiles
import os
import uuid

router = APIRouter(
    prefix="/evidencias",
    tags=["evidencias"]
)

UPLOAD_DIR = "uploads"

@router.post("/subir/{incidente_id}")
async def subir_evidencia(
    incidente_id: int,
    tipo: str = Form(...),
    archivo: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    extension = archivo.filename.split(".")[-1]
    nombre_archivo = f"{uuid.uuid4()}.{extension}"
    ruta = os.path.join(UPLOAD_DIR, nombre_archivo)

    async with aiofiles.open(ruta, 'wb') as f:
        contenido = await archivo.read()
        await f.write(contenido)

    url = f"/uploads/{nombre_archivo}"

    db_evidencia = Evidencia(
        incidente_id=incidente_id,
        tipo=tipo,
        url=url,
        descripcion=archivo.filename
    )
    db.add(db_evidencia)
    db.commit()
    db.refresh(db_evidencia)

    return {"url": url, "id": db_evidencia.id}

@router.get("/{incidente_id}")
def listar_evidencias(
    incidente_id: int,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    evidencias = db.query(Evidencia).filter(Evidencia.incidente_id == incidente_id).all()
    return evidencias