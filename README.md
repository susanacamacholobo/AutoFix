# AutoFix
> Plataforma Inteligente de Atención de Emergencias Vehiculares

AutoFix conecta a conductores con problemas mecánicos con talleres y mecánicos cercanos en tiempo real. El usuario envía una solicitud de emergencia con fotos, audio y ubicación, y el sistema utiliza inteligencia artificial para clasificar el incidente, asignar prioridad y recomendar el taller más adecuado.

---

## ¿Qué hace AutoFix?

- **Geolocalización en tiempo real** — Ubica el incidente y encuentra talleres cercanos.
- **Inteligencia Artificial** — Transcribe audio, clasifica incidentes y analiza imágenes automáticamente con Claude (Anthropic) y Groq Whisper.
- **Reporte multimodal** — El usuario puede enviar fotos, audios y texto describiendo su emergencia.
- **Asignación inteligente** — El sistema selecciona el taller más adecuado según distancia y disponibilidad usando la fórmula de Haversine.
- **Gestión de técnicos** — El taller asigna técnicos y el sistema gestiona su disponibilidad automáticamente.
- **Almacenamiento en la nube** — Las evidencias (fotos y audios) se almacenan en Cloudinary.

---

## Actores del sistema

| Actor | Rol |
|-------|-----|
| Administrador | Supervisa el funcionamiento general del sistema, gestiona roles y permisos |
| Cliente | Registra vehículos, reporta emergencias |
| Taller | Recibe solicitudes, asigna técnicos, actualiza estados |
| Técnico | Es asignado por el taller para atender al cliente |
| Sistema IA | Clasifica incidentes, transcribe audio, analiza imágenes y asigna prioridad |

---

## Stack Tecnológico

| Capa | Tecnología |
|------|------------|
| Frontend Web | Angular + Vercel |
| Backend | FastAPI (Python) + Railway |
| Base de datos | PostgreSQL 17 |
| App Móvil | Flutter |
| IA — Texto e Imágenes | Claude Sonnet (Anthropic) |
| IA — Audio | Groq Whisper |
| Almacenamiento | Cloudinary |
| Mapas | Google Maps API |

---

## Estructura del Proyecto

```
AutoFix/
├── web/
│   └── autofix-web/        # Aplicación web para talleres (Angular)
├── backend/
│   ├── main.py             # API REST con FastAPI
│   └── app/
│       ├── routers/        # Endpoints: auth, usuarios, incidentes, ia, etc.
│       ├── services/       # Lógica: ia_service, asignacion_service, etc.
│       └── models/         # Modelos SQLAlchemy
├── mobile/
│   └── autofix_mobile/     # App móvil para clientes (Flutter)
├── database/
│   └── autofix_db.sql      # Script de base de datos PostgreSQL
└── README.md
```

---

## Casos de Uso Implementados

| CU | Descripción | Estado |
|----|-------------|--------|
| CU01 | Gestionar Inicio y Cierre de Sesión | ✅ Implementado |
| CU02 | Gestionar Roles y Permisos | ✅ Implementado |
| CU03 | Gestionar Conductor y sus Vehículos | ✅ Implementado |
| CU04 | Gestionar Taller Mecánico y Técnicos | ✅ Implementado |
| CU05 | Registrar Emergencia Vehicular | ✅ Implementado |
| CU06 | Analizar y Procesar Incidente con IA | ✅ Implementado |
| CU07 | Clasificar y Asignar Prioridad al Incidente | ✅ Implementado |
| CU08 | Asignar Taller según Disponibilidad y Ubicación | ✅ Implementado |
| CU09 | Gestionar Solicitud de Asistencia en el Taller | ✅ Implementado |
| CU10 | Asignar Técnico y Gestionar Disponibilidad | ✅ Implementado |
| CU11 | Realizar Seguimiento del Servicio en Tiempo Real | 🔄 Pendiente |
| CU12 | Gestionar Notificaciones Push | 🔄 Pendiente |
| CU13 | Gestionar Pago del Servicio | 🔄 Pendiente |
| CU14 | Visualizar Historial de Atenciones | 🔄 Pendiente |

---

## Funcionalidades — App Móvil (Cliente)

**Registro**
- Registro de usuario y vehículos

**Reporte de emergencia**
- Descripción libre del problema (la IA clasifica automáticamente)
- Envío de ubicación en tiempo real
- Adjuntar fotos del vehículo
- Grabación de audio describiendo el problema

**Seguimiento**
- Estado de solicitud: Pendiente / En proceso / Atendido
- Taller asignado automáticamente por el sistema

---

## Funcionalidades — App Web (Taller)

**Registro**
- Registro del taller con ubicación en mapa (Google Maps)
- Registro de técnicos

**Gestión de solicitudes**
- Ver solicitudes disponibles con información estructurada
- Aceptar o rechazar solicitudes
- Asignar técnico según disponibilidad
- Historial de rechazos

**Operación**
- Actualizar estado del servicio
- Gestionar disponibilidad de técnicos automáticamente
- Ver fotos y audio enviados por el conductor
- Ver ubicación del conductor en Google Maps
- Ver historial de atenciones

**Información IA**
- Resumen automático del incidente (texto + audio + imagen)
- Clasificación del tipo de problema
- Nivel de prioridad asignado automáticamente

---

## Módulos de Inteligencia Artificial

| Módulo | Tecnología | Estado |
|--------|------------|--------|
| Transcripción de audio | Groq Whisper | ✅ Activo |
| Análisis de texto | Claude Sonnet (Anthropic) | ✅ Activo |
| Análisis de imágenes | Claude Sonnet Vision | ✅ Activo |
| Clasificación de incidentes | Claude Sonnet | ✅ Activo |
| Asignación de prioridad | Lógica basada en tipo | ✅ Activo |

---

## Sistema de Asignación Inteligente

Considera los siguientes factores:
- Ubicación del incidente (latitud/longitud)
- Distancia al taller (fórmula de Haversine)
- Disponibilidad del taller (activo en el sistema)

---

## Modelo de Datos (PostgreSQL)

El modelo contempla las siguientes entidades:
`usuarios` · `talleres` · `técnicos` · `vehículos` · `incidentes` · `evidencias` · `historial` · `roles` · `permisos`

Script completo disponible en: `database/autofix_db.sql`

---

## Links de Producción

| Plataforma | URL |
|-----------|-----|
| 🌐 Frontend Web | https://autofix-web.vercel.app |
| ⚙️ Backend API | https://autofix-production-0c6c.up.railway.app |
| 📚 Documentación API | https://autofix-production-0c6c.up.railway.app/docs |
| 📱 App Móvil (APK) | https://github.com/susanacamacholobo/AutoFix/releases/download/v1.0/app-release.apk |

---

## Instalación y configuración

### Requisitos previos
- Node.js v18+
- Python 3.10+
- Flutter SDK 3.0+
- PostgreSQL 17+

### Variables de entorno (backend/.env)
DATABASE_URL=postgresql://...
ANTHROPIC_API_KEY=sk-ant-...
GROQ_API_KEY=gsk_...
CLOUDINARY_CLOUD_NAME=...
CLOUDINARY_API_KEY=...
CLOUDINARY_API_SECRET=...

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