# 🔧 AutoFix

> Plataforma de asistencia mecánica de emergencia — web y móvil.

AutoFix conecta a conductores con problemas mecánicos con talleres y mecánicos cercanos en tiempo real. El usuario envía una solicitud de emergencia desde la app y el taller más cercano o especializado puede aceptarla para ir a socorrer.

---

## 🚀 ¿Qué hace AutoFix?

- 📍 **Localización en tiempo real** — Recomienda los talleres mecánicos más cercanos a la ubicación del usuario.
- 🔩 **Especialización** — Filtra talleres según el tipo de emergencia mecánica.
- 📸 **Multimedia** — El usuario puede enviar fotos, audios o texto describiendo su problema.
- ⚡ **Solicitudes de emergencia** — El taller recibe la solicitud y puede aceptarla para asistir al usuario.

---

## 🛠️ Stack Tecnológico

| Capa | Tecnología |
|------|------------|
| Frontend Web | Angular |
| Backend | FastAPI (Python) |
| Base de datos | PostgreSQL |
| App Móvil | Flutter |

---

## 📁 Estructura del Proyecto

```
AutoFix/
├── web/
│   └── autofix-web/        # Aplicación web en Angular
├── backend/
│   └── main.py             # API REST con FastAPI
├── mobile/
│   └── autofix_mobile/     # App móvil en Flutter
└── README.md
```

---

## ⚙️ Instalación y configuración

### Requisitos previos

- Node.js v18+
- Python 3.10+
- Flutter SDK 3.0+
- PostgreSQL 14+

---

### 🌐 Frontend Web (Angular)

```bash
cd web/autofix-web
npm install
ng serve
```
Disponible en: `http://localhost:4200`

---

### 🖥️ Backend (FastAPI)

```bash
cd backend
python -m venv venv
venv\Scripts\activate      # Windows
source venv/bin/activate   # Mac/Linux
pip install fastapi uvicorn
uvicorn main:app --reload
```
Disponible en: `http://localhost:8000`

Documentación automática: `http://localhost:8000/docs`

---

### 📱 App Móvil (Flutter)

```bash
cd mobile/autofix_mobile
flutter pub get
flutter run
```

---

## 👥 Equipo

Desarrollado como proyecto universitario.

---

## 📄 Licencia

Este proyecto es de uso académico.