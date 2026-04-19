from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.core.dependencies import get_current_user
from app.models.usuario import Usuario
from app.models.evidencia import Evidencia
from dotenv import load_dotenv
import cloudinary
import cloudinary.uploader
import os

load_dotenv()

cloudinary.config(
    cloud_name=os.getenv("CLOUDINARY_CLOUD_NAME"),
    api_key=os.getenv("CLOUDINARY_API_KEY"),
    api_secret=os.getenv("CLOUDINARY_API_SECRET")
)

router = APIRouter(
    prefix="/evidencias",
    tags=["evidencias"]
)


@router.post("/subir/{incidente_id}")
async def subir_evidencia(
    incidente_id: int,
    tipo: str = Form(...),
    archivo: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_user)
):
    contenido = await archivo.read()

    extension = archivo.filename.split(".")[-1].lower()

    # Determinar el resource_type según el tipo de archivo
    if tipo == "audio" or extension in ("mp3", "wav", "ogg", "m4a", "aac"):
        resource_type = "video"  # Cloudinary usa "video" para audio también
    elif tipo in ("imagen", "foto") or extension in ("jpg", "jpeg", "png", "webp", "gif"):
        resource_type = "image"
    else:
        resource_type = "auto"

    # Subir a Cloudinary
    resultado = cloudinary.uploader.upload(
        contenido,
        folder=f"autofix/incidente_{incidente_id}",
        resource_type=resource_type
    )

    url = resultado.get("secure_url")

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