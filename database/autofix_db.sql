-- ============================================
-- AutoFix - Script de Base de Datos
-- PostgreSQL 17
-- ============================================

-- Crear base de datos (ejecutar como superusuario)
-- CREATE DATABASE autofix;

-- ============================================
-- TABLA: usuarios
-- ============================================
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    contrasena VARCHAR(255) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- ============================================
-- TABLA: vehiculos
-- ============================================
CREATE TABLE vehiculos (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER REFERENCES usuarios(id),
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    anio INTEGER,
    placa VARCHAR(20) UNIQUE NOT NULL,
    color VARCHAR(30),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLA: talleres
-- ============================================
CREATE TABLE talleres (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    direccion VARCHAR(255),
    latitud DECIMAL(9,6),
    longitud DECIMAL(9,6),
    contrasena VARCHAR(255) NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLA: tecnicos
-- ============================================
CREATE TABLE tecnicos (
    id SERIAL PRIMARY KEY,
    taller_id INTEGER REFERENCES talleres(id),
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    especialidad VARCHAR(100),
    disponible BOOLEAN DEFAULT TRUE,
    activo BOOLEAN DEFAULT TRUE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLA: incidentes
-- ============================================
CREATE TABLE incidentes (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER REFERENCES usuarios(id),
    vehiculo_id INTEGER REFERENCES vehiculos(id),
    taller_id INTEGER REFERENCES talleres(id),
    tecnico_id INTEGER REFERENCES tecnicos(id),
    descripcion TEXT,
    latitud DECIMAL(9,6),
    longitud DECIMAL(9,6),
    tipo VARCHAR(50),
    prioridad VARCHAR(20) DEFAULT 'media',
    estado VARCHAR(20) DEFAULT 'pendiente',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_atencion TIMESTAMP
);

-- ============================================
-- TABLA: evidencias
-- ============================================
CREATE TABLE evidencias (
    id SERIAL PRIMARY KEY,
    incidente_id INTEGER REFERENCES incidentes(id),
    tipo VARCHAR(20) NOT NULL,
    url VARCHAR(255) NOT NULL,
    descripcion TEXT,
    fecha_subida TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLA: historial
-- ============================================
CREATE TABLE historial (
    id SERIAL PRIMARY KEY,
    incidente_id INTEGER REFERENCES incidentes(id),
    estado_anterior VARCHAR(20),
    estado_nuevo VARCHAR(20),
    observacion TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLA: roles
-- ============================================
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- RELACION: usuarios con roles
-- ============================================
ALTER TABLE usuarios ADD COLUMN rol_id INTEGER REFERENCES roles(id);

-- ============================================
-- ROLES BASE DEL SISTEMA
-- ============================================
INSERT INTO roles (nombre, descripcion) VALUES
('administrador', 'Responsable de supervisar el funcionamiento general del sistema'),
('conductor', 'Conductor que registra vehículos y reporta emergencias'),
('taller', 'Taller mecánico que atiende solicitudes de emergencia'),
('tecnico', 'Personal asignado por el taller para atender al conductor');