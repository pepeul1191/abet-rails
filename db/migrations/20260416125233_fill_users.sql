-- migrate:up

INSERT INTO users (id, username, email, password_digest, image_url, active, created_at, updated_at) VALUES
(1, 'jperez', 'juan.perez@ulima.edu.pe', 'hashed_password_1', 'https://randomuser.me/api/portraits/men/1.jpg', 1, datetime('now', '-30 days'), datetime('now', '-30 days')),
(2, 'mgarcia', 'maria.garcia@ulima.edu.pe', 'hashed_password_2', 'https://randomuser.me/api/portraits/women/2.jpg', 1, datetime('now', '-28 days'), datetime('now', '-28 days')),
(3, 'crodriguez', 'carlos.rodriguez@ulima.edu.pe', 'hashed_password_3', 'https://randomuser.me/api/portraits/men/3.jpg', 1, datetime('now', '-25 days'), datetime('now', '-25 days')),
(4, 'lfernandez', 'laura.fernandez@ulima.edu.pe', 'hashed_password_4', 'https://randomuser.me/api/portraits/women/4.jpg', 0, datetime('now', '-22 days'), datetime('now', '-22 days')), -- Inactivo
(5, 'asanchez', 'andres.sanchez@ulima.edu.pe', 'hashed_password_5', 'https://randomuser.me/api/portraits/men/5.jpg', 1, datetime('now', '-20 days'), datetime('now', '-20 days')),
(6, 'ctorres', 'camila.torres@ulima.edu.pe', 'hashed_password_6', 'https://randomuser.me/api/portraits/women/6.jpg', 1, datetime('now', '-18 days'), datetime('now', '-18 days')),
(7, 'dramirez', 'diego.ramirez@ulima.edu.pe', 'hashed_password_7', 'https://randomuser.me/api/portraits/men/7.jpg', 0, datetime('now', '-15 days'), datetime('now', '-15 days')), -- Inactivo
(8, 'vflores', 'valentina.flores@ulima.edu.pe', 'hashed_password_8', 'https://randomuser.me/api/portraits/women/8.jpg', 1, datetime('now', '-12 days'), datetime('now', '-12 days')),
(9, 'mvasquez', 'mateo.vasquez@ulima.edu.pe', 'hashed_password_9', 'https://randomuser.me/api/portraits/men/9.jpg', 1, datetime('now', '-10 days'), datetime('now', '-10 days')),
(10, 'isilva', 'isabella.silva@ulima.edu.pe', 'hashed_password_10', 'https://randomuser.me/api/portraits/women/10.jpg', 1, datetime('now', '-8 days'), datetime('now', '-8 days')),
(11, 'nrojas', 'nicolas.rojas@ulima.edu.pe', 'hashed_password_11', 'https://randomuser.me/api/portraits/men/11.jpg', 1, datetime('now', '-7 days'), datetime('now', '-7 days')),
(12, 'sreyes', 'sofia.reyes@ulima.edu.pe', 'hashed_password_12', 'https://randomuser.me/api/portraits/women/12.jpg', 0, datetime('now', '-6 days'), datetime('now', '-6 days')), -- Inactivo
(13, 'acastro', 'alejandro.castro@ulima.edu.pe', 'hashed_password_13', 'https://randomuser.me/api/portraits/men/13.jpg', 1, datetime('now', '-5 days'), datetime('now', '-5 days')),
(14, 'dmorales', 'daniela.morales@ulima.edu.pe', 'hashed_password_14', 'https://randomuser.me/api/portraits/women/14.jpg', 1, datetime('now', '-4 days'), datetime('now', '-4 days')),
(15, 'forozco', 'fernando.orozco@ulima.edu.pe', 'hashed_password_15', 'https://randomuser.me/api/portraits/men/15.jpg', 1, datetime('now', '-3 days'), datetime('now', '-3 days')),
(16, 'gchavez', 'gabriela.chavez@ulima.edu.pe', 'hashed_password_16', 'https://randomuser.me/api/portraits/women/16.jpg', 1, datetime('now', '-2 days'), datetime('now', '-2 days')),
(17, 'hruiz', 'hugo.ruiz@ulima.edu.pe', 'hashed_password_17', 'https://randomuser.me/api/portraits/men/17.jpg', 0, datetime('now', '-1 day'), datetime('now', '-1 day')), -- Inactivo
(18, 'icabrera', 'ines.cabrera@ulima.edu.pe', 'hashed_password_18', 'https://randomuser.me/api/portraits/women/18.jpg', 1, datetime('now', '-0 days'), datetime('now', '-0 days')),
(19, 'jmedina', 'javier.medina@ulima.edu.pe', 'hashed_password_19', 'https://randomuser.me/api/portraits/men/19.jpg', 1, datetime('now', '-0 days'), datetime('now', '-0 days')),
(20, 'kramirez', 'karen.ramirez@ulima.edu.pe', 'hashed_password_20', 'https://randomuser.me/api/portraits/women/20.jpg', 1, datetime('now', '-0 days'), datetime('now', '-0 days')),
(21, 'lcastillo', 'luis.castillo@ulima.edu.pe', 'hashed_password_21', 'https://randomuser.me/api/portraits/men/21.jpg', 1, datetime('now', '-0 days'), datetime('now', '-0 days')),
(22, 'mnavarro', 'mariana.navarro@ulima.edu.pe', 'hashed_password_22', 'https://randomuser.me/api/portraits/women/22.jpg', 0, datetime('now', '-0 days'), datetime('now', '-0 days')), -- Inactivo
(23, 'nvargas', 'nicole.vargas@ulima.edu.pe', 'hashed_password_23', 'https://randomuser.me/api/portraits/women/23.jpg', 1, datetime('now', '-0 days'), datetime('now', '-0 days'));
-- migrate:down

DELETE FROM users;