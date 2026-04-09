-- migrate:up

INSERT INTO industries (id, name) VALUES
(1, 'Tecnología de la Información'),
(2, 'Biotecnología'),
(3, 'Energías Renovables'),
(4, 'Educación'),
(5, 'Salud y Medicina'),
(6, 'Agricultura'),
(7, 'Robótica'),
(8, 'Medios y Comunicación'),
(9, 'Manufactura avanzada'),
(10, 'Fintech'),
(11, 'Automotriz'),
(12, 'Turismo y Hospitalidad'),
(13, 'Química'),
(14, 'Servicios Profesionales'),
(15, 'Construcción y Arquitectura');

-- migrate:down

DELETE FROM industries;