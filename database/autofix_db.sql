-- ============================================
-- AutoFix - Script de Base de Datos
-- PostgreSQL 17
-- ============================================

-- Crear base de datos (ejecutar como superusuario)
-- CREATE DATABASE autofix;

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
    activo BOOLEAN DEFAULT TRUE,
    rol_id INTEGER REFERENCES roles(id)
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
    especialidad VARCHAR(150),
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
-- TABLA: incidentes
-- ============================================
CREATE TABLE incidentes (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER REFERENCES usuarios(id),
    vehiculo_id INTEGER REFERENCES vehiculos(id),
    taller_id INTEGER REFERENCES talleres(id),
    tecnico_id INTEGER REFERENCES tecnicos(id),
    descripcion TEXT,
    resumen_ia TEXT,
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
    taller_id INTEGER REFERENCES talleres(id),
    estado_anterior VARCHAR(20),
    estado_nuevo VARCHAR(20),
    observacion TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLA: permisos
-- ============================================
CREATE TABLE permisos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLA: rol_permisos
-- ============================================
CREATE TABLE rol_permisos (
    id SERIAL PRIMARY KEY,
    rol_id INTEGER REFERENCES roles(id),
    permiso_id INTEGER REFERENCES permisos(id),
    UNIQUE(rol_id, permiso_id)
);

-- ============================================
-- ROLES BASE DEL SISTEMA
-- ============================================
INSERT INTO roles (nombre, descripcion) VALUES
('Administrador', 'Responsable de supervisar el funcionamiento general del sistema'),
('Conductor', 'Conductor que registra vehículos y reporta emergencias'),
('Taller', 'Taller mecánico que atiende solicitudes de emergencia'),
('Tecnico', 'Personal asignado por el taller para atender al conductor'),
('Inteligencia Artificial', 'Clasifica el tipo de incidente, asigna un nivel de prioridad y genera un resumen del incidente');

-- ============================================
-- PERMISOS BASE DEL SISTEMA
-- ============================================
INSERT INTO permisos (nombre, descripcion) VALUES
('ver_dashboard', 'Acceso al panel principal'),
('gestionar_roles', 'Crear, editar y desactivar roles'),
('gestionar_usuarios', 'Ver y gestionar usuarios del sistema'),
('reportar_emergencia', 'Reportar una emergencia vehicular'),
('ver_emergencias', 'Ver lista de emergencias'),
('gestionar_emergencias', 'Aceptar, rechazar y gestionar emergencias'),
('gestionar_tecnicos', 'Registrar y gestionar técnicos del taller'),
('ver_historial', 'Ver historial de atenciones'),
('gestionar_pagos', 'Realizar y gestionar pagos'),
('asignar_tecnico', 'Asignar técnico a una emergencia');

-- ============================================
-- ASIGNACION DE PERMISOS POR ROL
-- ============================================
-- Administrador
INSERT INTO rol_permisos (rol_id, permiso_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9), (1, 10);

-- Conductor
INSERT INTO rol_permisos (rol_id, permiso_id) VALUES
(2, 1), (2, 4), (2, 5), (2, 8), (2, 9);

-- Taller
INSERT INTO rol_permisos (rol_id, permiso_id) VALUES
(3, 1), (3, 5), (3, 6), (3, 7), (3, 8), (3, 10);

-- Tecnico
INSERT INTO rol_permisos (rol_id, permiso_id) VALUES
(4, 1), (4, 5), (4, 8);