import math
from sqlalchemy.orm import Session
from app.models.taller import Taller
from app.models.incidente import Incidente


def calcular_distancia(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Calcula la distancia en kilómetros entre dos coordenadas
    usando la fórmula de Haversine.
    """
    R = 6371  # Radio de la Tierra en km

    lat1_rad = math.radians(lat1)
    lat2_rad = math.radians(lat2)
    delta_lat = math.radians(lat2 - lat1)
    delta_lon = math.radians(lon2 - lon1)

    a = math.sin(delta_lat / 2) ** 2 + \
        math.cos(lat1_rad) * math.cos(lat2_rad) * \
        math.sin(delta_lon / 2) ** 2

    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c


def obtener_talleres_candidatos(db: Session, incidente_id: int) -> list:
    """
    CU08 - Obtiene y ordena los talleres según distancia al incidente.
    Retorna lista de talleres con su distancia calculada.
    """
    incidente = db.query(Incidente).filter(Incidente.id == incidente_id).first()
    if not incidente:
        return []

    if not incidente.latitud or not incidente.longitud:
        talleres = db.query(Taller).filter(Taller.activo == True).all()
        return [{"taller": t, "distancia_km": None} for t in talleres]

    lat_incidente = float(incidente.latitud)
    lon_incidente = float(incidente.longitud)

    talleres = db.query(Taller).filter(Taller.activo == True).all()

    candidatos = []
    for taller in talleres:
        if taller.latitud and taller.longitud:
            distancia = calcular_distancia(
                lat_incidente, lon_incidente,
                float(taller.latitud), float(taller.longitud)
            )
            candidatos.append({
                "taller": taller,
                "distancia_km": round(distancia, 2)
            })
        else:
            candidatos.append({
                "taller": taller,
                "distancia_km": None
            })

    candidatos.sort(key=lambda x: x["distancia_km"] if x["distancia_km"] is not None else 9999)

    return candidatos


def asignar_taller_cercano(db: Session, incidente_id: int) -> Taller | None:
    """
    CU08 - Asigna automáticamente el taller más cercano al incidente.
    """
    candidatos = obtener_talleres_candidatos(db, incidente_id)
    if not candidatos:
        return None

    taller_seleccionado = candidatos[0]["taller"]
    distancia = candidatos[0]["distancia_km"]

    incidente = db.query(Incidente).filter(Incidente.id == incidente_id).first()
    if incidente:
        incidente.taller_id = taller_seleccionado.id
        db.commit()
        db.refresh(incidente)

    print(f"Taller asignado: {taller_seleccionado.nombre} a {distancia} km")

    return taller_seleccionado