# AutoFix
> Plataforma Inteligente de Atención de Emergencias Vehiculares

AutoFix conecta a conductores con problemas mecánicos con talleres y mecánicos cercanos en tiempo real. El usuario envía una solicitud de emergencia con fotos, audio y ubicación, y el sistema utiliza inteligencia artificial para clasificar el incidente, asignar prioridad y recomendar el taller más adecuado.

---

## ¿Qué hace AutoFix?

- **Geolocalización en tiempo real** — Ubica el incidente y encuentra talleres cercanos.
- **Inteligencia Artificial** — Transcribe audio, clasifica incidentes y analiza imágenes automáticamente.
- **Reporte multimodal** — El usuario puede enviar fotos, audios o texto describiendo su emergencia.
- **Asignación inteligente** — El sistema selecciona el taller más adecuado según tipo de problema, distancia y disponibilidad.
- **Notificaciones push** — Actualizaciones en tiempo real para clientes y talleres.
- **Pagos integrados** — El cliente paga desde la app; el taller paga 10% de comisión a la plataforma.

---

## Actores del sistema

| Actor | Rol |
|-------|-----|
| Administrador | Supervisa el funcionamiento general del sistema, gestiona roles y permisos |
| Cliente | Registra vehículos, reporta emergencias, realiza pagos |
| Taller | Recibe solicitudes, asigna técnicos, actualiza estados |
| Técnico | Es asignado por el taller para atender al cliente |
| Sistema IA | Clasifica incidentes, transcribe audio, analiza imágenes |

---

## Stack Tecnológico

| Capa | Tecnología |
|------|------------|
| Frontend Web | Angular |
| Backend | FastAPI (Python) |
| Base de datos | PostgreSQL |
| App Móvil | Flutter |

---

## Estructura del Proyecto

```
AutoFix/
├── web/
│   └── autofix-web/        # Aplicación web para talleres (Angular)
├── backend/
│   └── main.py             # API REST con FastAPI
├── mobile/
│   └── autofix_mobile/     # App móvil para clientes (Flutter)
├── database/
│   └── autofix_db.sql      # Script de base de datos PostgreSQL
└── README.md
```

---

## Funcionalidades — App Móvil (Cliente)

**Registro**
- Registro de usuario y vehículos

**Reporte de emergencia**
- Tipos rápidos: batería, llanta pinchada, grúa, otra emergencia
- Envío de ubicación en tiempo real
- Adjuntar fotos del vehículo
- Texto adicional opcional

**Seguimiento**
- Estado de solicitud: Pendiente / En proceso / Atendido
- Taller asignado y tiempo estimado de llegada
- Notificaciones push
- Pago desde la app

---

## Funcionalidades — App Web (Taller)

**Registro**
- Registro del taller y sus técnicos

**Gestión de solicitudes**
- Ver solicitudes disponibles con información estructurada
- Aceptar o rechazar solicitudes
- Asignar técnico según disponibilidad y tipo de percance
- Historial de rechazos

**Operación**
- Actualizar estado del servicio
- Gestionar disponibilidad de técnicos
- Ver fotos enviadas por el conductor
- Ver ubicación del conductor en Google Maps
- Ver historial de atenciones

**Información IA** *(próximamente)*
- Resumen automático del incidente
- Clasificación del problema
- Nivel de prioridad

---

## Módulos de Inteligencia Artificial *(en desarrollo)*

| Módulo | Descripción |
|--------|-------------|
| Transcripción de audio | Convierte audio a texto y extrae información relevante |
| Clasificación de incidentes | Categoriza el problema: batería, llanta, choque, motor, otros |
| Análisis de imágenes | Identifica daños visibles y apoya la clasificación |
| Generación de resumen | Crea una ficha estructurada automática del incidente |

---

## Sistema de Asignación Inteligente *(en desarrollo)*

Considera los siguientes factores para recomendar talleres:
- Ubicación del incidente
- Tipo de problema
- Disponibilidad y capacidad del taller
- Distancia
- Prioridad del caso

---

## Modelo de Datos (PostgreSQL)

El modelo contempla las siguientes entidades:
`usuarios` · `talleres` · `técnicos` · `vehículos` · `incidentes` · `evidencias` · `historial` · `roles` · `permisos`

Script completo disponible en: `database/autofix_db.sql`

---

## Instalación y configuración

### Requisitos previos
- Node.js v18+
- Python 3.10+
- Flutter SDK 3.0+
- PostgreSQL 17+

### Frontend Web (Angular)
```bash
cd web/autofix-web
npm install
ng serve
```
Disponible en: `http://localhost:4200`

### Backend (FastAPI)
```bash
cd backend
python -m venv venv
venv\Scripts\activate      # Windows
source venv/bin/activate   # Mac/Linux
pip install -r requirements.txt
uvicorn main:app --reload
```
Disponible en: `http://localhost:8000`  
Documentación: `http://localhost:8000/docs`

### App Móvil (Flutter)
```bash
cd mobile/autofix_mobile
flutter pub get
flutter run
```

---

## Licencia

Proyecto académico — Todos los derechos reservados.