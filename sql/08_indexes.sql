-- =================================================
-- Doom DB
-- 08_index.sql
-- =================================================

-- Indice 1
CREATE INDEX IF NOT EXISTS idx_telemetry_game_player_tic
ON TelemetryEvent (game_id, player_id, tic);

-- Indice 2, distinto por la localización de los atributos en diferentes tablas fuera de telemetry event
CREATE INDEX IF NOT EXISTS idx_map_episode_id ON Map (episode_id);
CREATE INDEX IF NOT EXISTS idx_sector_map_id ON Sector (map_id);
CREATE INDEX IF NOT EXISTS idx_game_map_id ON Game (map_id);

-- Indice 3
CREATE INDEX IF NOT EXISTS idx_telemetry_pos_x_y
ON TelemetryEvent (pos_x, pos_y);

-- Query utilizada para comprobar el efecto de los index

-- EXPLAIN ANALYZE
-- SELECT
-- 	e1.game_id,
-- 	e1.player_id AS jugador_a,
-- 	e2.player_id AS jugador_b,
-- 	COUNT(DISTINCT e1.tic) AS tics_juntos
-- FROM TelemetryEvent e1
-- JOIN TelemetryEvent e2
-- ON e1.game_id = e2.game_id
-- AND e1.tic = e2.tic
-- AND e1.player_id < e2.player_id
-- AND FLOOR(e1.pos_x / 250) = FLOOR(e2.pos_x / 250)
-- AND FLOOR(e1.pos_y / 250) = FLOOR(e2.pos_y / 250)
-- GROUP BY e1.game_id, e1.player_id, e2.player_id
-- ORDER BY tics_juntos DESC;