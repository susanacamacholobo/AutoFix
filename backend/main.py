from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from app.db.database import engine
from app.routers import usuarios, auth, roles, permisos, vehiculos, talleres, incidentes, evidencias
import os

app = FastAPI(
    title="AutoFix API",
    description="Plataforma Inteligente de Atención de Emergencias Vehiculares",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:4200",
        "https://autofix-web.vercel.app",
        "https://autofix-hvxp84eki-susanacamacholobos-projects.vercel.app"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

os.makedirs("uploads", exist_ok=True)
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

app.include_router(auth.router)
app.include_router(usuarios.router)
app.include_router(roles.router)
app.include_router(permisos.router)
app.include_router(vehiculos.router)
app.include_router(talleres.router)
app.include_router(incidentes.router)
app.include_router(evidencias.router)

@app.get("/")
def root():
    return {"mensaje": "AutoFix API funcionando!"}

@app.get("/test-db")
def test_db():
    try:
        with engine.connect() as conn:
            return {"mensaje": "Conexion a la base de datos exitosa!"}
    except Exception as e:
        return {"error": str(e)}