-- migrate:up

-- Abril 2026 (días 1, 5, 10, 15)
INSERT INTO tasks (name, description, data, zip_path, status, user_id, task_type_id, period_id, created_at) VALUES 
('Tarea A1', 'Descripción tarea abril 1', '[{"codigo":"2020001","nombrecompleto":"BENÍTEZ ROJAS, MATEO FRANCO","alumno":"BENÍTEZ, MATEO","seccion":"123","nota":"15","p1":"3","p2":"3","p3":"4","p4":"2","p5":"3"}]', 'tmp/abet/1780781265/folders.zip', 'Success', 1, 2, 1, '2026-04-01 08:30:00'),
('Tarea A2', 'Descripción tarea abril 5', '[{"codigo":"2020002","nombrecompleto":"OLMEDO GARCÍA, VALENTINA JULIA","alumno":"OLMEDO, VALENTINA","seccion":"123","nota":"14","p1":"3","p2":"3","p3":"3","p4":"2","p5":"3"}]', 'tmp/abet/1780781265/folders.zip', 'Success', 1, 2, 1, '2026-04-05 10:15:00'),
('Tarea A3', 'Descripción tarea abril 10', '[{"codigo":"2020003","nombrecompleto":"CASTILLO PÉREZ, ADRIÁN JOSÉ","alumno":"CASTILLO, ADRIÁN","seccion":"123","nota":"20","p1":"4","p2":"4","p3":"4","p4":"4","p5":"4"}]', 'tmp/abet/1780781265/folders.zip', 'Pending', 1, 1, 1, '2026-04-10 14:20:00'),
('Tarea A4', 'Descripción tarea abril 15', '[{"codigo":"2020004","nombrecompleto":"NAVARRO LÓPEZ, CAMILA SIXTINA","alumno":"NAVARRO, CAMILA","seccion":"123","nota":"6","p1":"2","p2":"2","p3":"1","p4":"1","p5":"0"}]', 'tmp/abet/1780781265/folders.zip', 'Success', 1, 2, 1, '2026-04-15 09:45:00'),

-- Mayo 2026 (días 2, 8, 12, 20, 25)
('Tarea M1', 'Descripción tarea mayo 2', '[{"codigo":"2020005","nombrecompleto":"VEGA RAMÍREZ, JULIÁN ELEUTERIO","alumno":"VEGA, JULIÁN","seccion":"123","nota":"17","p1":"4","p2":"4","p3":"3","p4":"3","p5":"3"}]', 'tmp/abet/1780781265/folders.zip', 'Success', 1, 2, 1, '2026-05-02 11:00:00'),
('Tarea M2', 'Descripción tarea mayo 8', '[{"codigo":"2020001","nombrecompleto":"BENÍTEZ ROJAS, MATEO FRANCO","alumno":"BENÍTEZ, MATEO","seccion":"456","nota":"18","p1":"4","p2":"4","p3":"3","p4":"4","p5":"3"}]', 'tmp/abet/1780781265/folders.zip', 'Processing', 1, 1, 1, '2026-05-08 13:30:00'),
('Tarea M3', 'Descripción tarea mayo 12', '[{"codigo":"2020002","nombrecompleto":"OLMEDO GARCÍA, VALENTINA JULIA","alumno":"OLMEDO, VALENTINA","seccion":"456","nota":"16","p1":"3","p2":"4","p3":"3","p4":"3","p5":"3"}]', 'tmp/abet/1780781265/folders.zip', 'Success', 1, 2, 1, '2026-05-12 15:45:00'),
('Tarea M4', 'Descripción tarea mayo 20', '[{"codigo":"2020003","nombrecompleto":"CASTILLO PÉREZ, ADRIÁN JOSÉ","alumno":"CASTILLO, ADRIÁN","seccion":"456","nota":"19","p1":"4","p2":"4","p3":"4","p4":"3","p5":"4"}]', 'tmp/abet/1780781265/folders.zip', 'Success', 1, 1, 1, '2026-05-20 10:00:00'),
('Tarea M5', 'Descripción tarea mayo 25', '[{"codigo":"2020004","nombrecompleto":"NAVARRO LÓPEZ, CAMILA SIXTINA","alumno":"NAVARRO, CAMILA","seccion":"456","nota":"8","p1":"2","p2":"2","p3":"2","p4":"1","p5":"1"}]', 'tmp/abet/1780781265/folders.zip', 'Failed', 1, 2, 1, '2026-05-25 16:20:00'),

-- Junio 2026 (días 1, 10, 18, 25)
('Tarea J1', 'Descripción tarea junio 1', '[{"codigo":"2020005","nombrecompleto":"VEGA RAMÍREZ, JULIÁN ELEUTERIO","alumno":"VEGA, JULIÁN","seccion":"456","nota":"15","p1":"3","p2":"3","p3":"3","p4":"3","p5":"3"}]', 'tmp/abet/1780781265/folders.zip', 'Success', 1, 2, 1, '2026-06-01 09:15:00'),
('Tarea J2', 'Descripción tarea junio 10', '[{"codigo":"2020001","nombrecompleto":"BENÍTEZ ROJAS, MATEO FRANCO","alumno":"BENÍTEZ, MATEO","seccion":"789","nota":"14","p1":"3","p2":"3","p3":"3","p4":"2","p5":"3"}]', 'tmp/abet/1780781265/folders.zip', 'Success', 1, 2, 1, '2026-06-10 12:00:00'),
('Tarea J3', 'Descripción tarea junio 18', '[{"codigo":"2020002","nombrecompleto":"OLMEDO GARCÍA, VALENTINA JULIA","alumno":"OLMEDO, VALENTINA","seccion":"789","nota":"20","p1":"4","p2":"4","p3":"4","p4":"4","p5":"4"}]', 'tmp/abet/1780781265/folders.zip', 'Pending', 1, 1, 1, '2026-06-18 14:30:00'),

-- Julio 2026 (días 5, 12, 20)
('Tarea JL1', 'Descripción tarea julio 5', '[{"codigo":"2020003","nombrecompleto":"CASTILLO PÉREZ, ADRIÁN JOSÉ","alumno":"CASTILLO, ADRIÁN","seccion":"789","nota":"17","p1":"4","p2":"3","p3":"4","p4":"3","p5":"3"}]', 'tmp/abet/1780781265/folders.zip', 'Success', 1, 2, 1, '2026-07-05 11:30:00'),
('Tarea JL2', 'Descripción tarea julio 12', '[{"codigo":"2020004","nombrecompleto":"NAVARRO LÓPEZ, CAMILA SIXTINA","alumno":"NAVARRO, CAMILA","seccion":"789","nota":"5","p1":"1","p2":"1","p3":"1","p4":"1","p5":"1"}]', 'tmp/abet/1780781265/folders.zip', 'Success', 1, 1, 1, '2026-07-12 08:45:00'),
('Tarea JL3', 'Descripción tarea julio 20', '[{"codigo":"2020005","nombrecompleto":"VEGA RAMÍREZ, JULIÁN ELEUTERIO","alumno":"VEGA, JULIÁN","seccion":"789","nota":"18","p1":"4","p2":"4","p3":"3","p4":"4","p5":"3"}]', 'tmp/abet/1780781265/folders.zip', 'Processing', 1, 2, 1, '2026-07-20 17:00:00');

-- migrate:down

DELETE FROM tasks;