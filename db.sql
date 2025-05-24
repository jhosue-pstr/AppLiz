CREATE DATABASE AppLiz;

USE AppLiz;

CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    rol ENUM('free', 'premium') DEFAULT 'free',
    monedas INT DEFAULT 0,
    ultimo_acceso DATE
);
CREATE TABLE notas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    titulo VARCHAR(255),
    contenido TEXT NOT NULL,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);
CREATE TABLE diario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    titulo VARCHAR(255),
    contenido TEXT NOT NULL,
    fecha DATE NOT NULL,
    hora TIME DEFAULT CURRENT_TIME,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

ALTER TABLE usuarios
MODIFY email VARCHAR(100) NOT NULL UNIQUE,
ADD trabaja_actualmente ENUM('Sí', 'No'),
ADD horas_trabajo_estudio VARCHAR(50),
ADD frecuencia_estres VARCHAR(100),
ADD acepta_terminos BOOLEAN DEFAULT FALSE;
