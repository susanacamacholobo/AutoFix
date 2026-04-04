from fastapi import FastAPI
from app.db.database import engine

app = FastAPI()

@app.get("/")
def root():
    return {"mensaje": "AutoFix API funcionando! 🚀"}

@app.get("/test-db")
def test_db():
    try:
        with engine.connect() as conn:
            return {"mensaje": "Conexion a la base de datos exitosa!"}
    except Exception as e:
        return {"error": str(e)}