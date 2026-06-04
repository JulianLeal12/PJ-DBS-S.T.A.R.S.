//VIEW 1: Duracion promedio de sesiones por mapa
CREATE VIEW v_avg_duration_per_map AS
SELECT map_id, AVG(end_time - start_time) AS avg_duration
FROM Game
GROUP BY map_id;

SELECT * FROM v_avg_duration_per_map;

//VIEW 2: Respuestas UX de jugadores con sesiones sobre el promedio
CREATE VIEW v_ux_above_avg_players AS
SELECT DISTINCT p.player_id, p.alias, ur.response_id, ur.responded_at
FROM Game g
JOIN TelemetryEvent te ON g.game_id = te.game_id
JOIN Player p ON te.player_id = p.player_id
JOIN UXResponse ur ON ur.user_id = p.user_id
WHERE (g.end_time - g.start_time) > (
    SELECT AVG(end_time - start_time) FROM Game
);


//MATERIALIZED VIEW: Hotspot de sectores por episodio y juego
CREATE MATERIALIZED VIEW mv_sector_hotspot AS
SELECT 
    m.episode_id,
    te.game_id,
    COUNT(*) AS visit_count
FROM TelemetryEvent te
JOIN Game g ON te.game_id = g.game_id
JOIN Map m ON g.map_id = m.map_id
GROUP BY m.episode_id, te.game_id
ORDER BY visit_count DESC;

//Para actualizar la vista materializada después de cambios en los datos
REFRESH MATERIALIZED VIEW mv_sector_hotspot;



