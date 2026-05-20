-- =============================================
-- Doom Telemetry Database
-- 05_sample_data.sql - Datos sinteticos
-- Generado a partir de sesiones reales
-- =============================================

-- Episodios
INSERT INTO Episode (episode_id, name) VALUES
(1, 'Knee-Deep in the Dead'),
(2, 'The Shores of Hell'),
(3, 'Inferno');

-- Mapas (uno por episodio)
INSERT INTO Map (map_id, episode_id, name) VALUES
(1, 1, 'Hangar'),
(2, 2, 'Deimos Anomaly'),
(3, 3, 'Hell Keep');

-- Sectores (3 por mapa)
INSERT INTO Sector (sector_id, map_id, sector_number) VALUES
(1, 1, 1), (2, 1, 2), (3, 1, 3),
(4, 2, 1), (5, 2, 2), (6, 2, 3),
(7, 3, 1), (8, 3, 2), (9, 3, 3);

-- Instrumento UX
INSERT INTO UXInstrument (instrument_id, name, version) VALUES
(1, 'BANGS', '1.0');

-- 6 usuarios
INSERT INTO "User" (user_id, age, gender, experience_level) VALUES
(1, 20, 'Male',   'intermediate'),
(2, 22, 'Female', 'novice'),
(3, 21, 'Male',   'expert'),
(4, 23, 'Female', 'novice'),
(5, 19, 'Male',   'intermediate'),
(6, 24, 'Female', 'expert');

-- 6 jugadores (uno por usuario)
INSERT INTO Player (player_id, user_id, alias) VALUES
(1, 1, 'DoomGuy01'),
(2, 2, 'Slayer02'),
(3, 3, 'Rip03'),
(4, 4, 'Tear04'),
(5, 5, 'Frag05'),
(6, 6, 'Raze06');

-- 6 sesiones de juego (2 por mapa)
INSERT INTO Game (game_id, map_id, start_time, end_time, skill_level) VALUES
(1, 1, '15:11:49', '15:24:55', 2),
(2, 1, '15:14:04', '15:19:48', 2),
(3, 2, '15:25:01', '15:28:07', 3),
(4, 2, '15:27:50', '15:30:00', 3),
(5, 3, '15:37:23', '15:42:40', 1),
(6, 3, '15:39:19', '15:45:00', 1);

-- Telemetria sintetica: 20,034 filas
-- Basada en rangos reales de las sesiones capturadas
-- x: 188 a 24053 | y: -2462 a 1784 | angle: -668 a 240
INSERT INTO TelemetryEvent (event_id, game_id, player_id, tic, pos_x, pos_y, pos_z, angle)
SELECT
    i AS event_id,
    -- Distribuir entre los 6 juegos
    (((i-1) / 3339) + 1) AS game_id,
    -- Distribuir entre los 6 jugadores
    ((i % 6) + 1) AS player_id,
    -- Tic incremental por jugador/juego
    i AS tic,
    -- pos_x: rango real 188 a 24053
    ROUND((188 + random() * (24053 - 188))::numeric, 2) AS pos_x,
    -- pos_y: rango real -2462 a 1784
    ROUND((-2462 + random() * (1784 + 2462))::numeric, 2) AS pos_y,
    -- pos_z: casi siempre 0 o 32 (como en los datos reales)
    (ARRAY[0, 0, 0, 32])[floor(random() * 4 + 1)] AS pos_z,
    -- angle: rango real -668 a 240
    ROUND((-668 + random() * (240 + 668))::numeric, 2) AS angle
FROM generate_series(1, 20034) AS i;
