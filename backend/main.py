from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.db.database import engine
from app.routers import usuarios, auth

app = FastAPI(
    title="AutoFix API",
    description="Plataforma Inteligente de Atención de Emergencias Vehiculares",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:4200"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(usuarios.router)

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