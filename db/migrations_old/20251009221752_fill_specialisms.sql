-- migrate:up

INSERT INTO specialisms (id, name) VALUES
(1, 'Administración'),
(2, 'Asesoría legal'),
(3, 'Canales de distribución'),
(4, 'Comportamiento del consumidor'),
(5, 'Derecho comercial'),
(6, 'Derecho laboral'),
(7, 'Derecho tecnológico'),
(8, 'E-commerce'),
(9, 'Emprendimiento'),
(10, 'Estrategia comercial'),
(11, 'Estrategia y modelos de negocio'),
(12, 'Evaluación de proyectos'),
(13, 'Executive Branding'),
(14, 'Flujo de caja y proyección'),
(15, 'Gestión de marca'),
(16, 'Gestión de proyectos'),
(17, 'Marketing de servicios'),
(18, 'Marketing digital'),
(19, 'Marketing estratégico'),
(20, 'Modelo predictivo'),
(21, 'Narrativas transmedia y audiovisuales'),
(22, 'Operaciones/logística'),
(23, 'Planeamiento comercial y marketing'),
(24, 'Planeamiento estratégico y financiero'),
(25, 'Producción y realización publicitaria'),
(26, 'Prototipado de apps y websites'),
(27, 'Propiedad intelectual'),
(28, 'Protección de datos personales'),
(29, 'Sostenibilidad e impacto'),
(30, 'Storytelling'),
(31, 'Técnicas audiovisuales'),
(32, 'Transformación digital'),
(33, 'Valorización de startups e innovación'),
(34, 'Ventas B2B/B2C, adquisición de clientes');

-- migrate:down

DELETE FROM specialisms;