
SELECT
    m.map_id,
    m.name                                              AS map_name,
    COUNT(g.game_id)                                    AS num_sesiones,
    AVG(g.end_time - g.start_time)                      AS duracion_promedio,
    ROUND(AVG(EXTRACT(EPOCH FROM (g.end_time - g.start_time)))::numeric, 1)
                                                        AS duracion_promedio_seg
FROM Game g
JOIN Map  m ON m.map_id = g.map_id
GROUP BY m.map_id, m.name
ORDER BY duracion_promedio DESC;


SELECT
    e1.player_id AS jugador_a,
    e2.player_id AS jugador_b,
    COUNT(*)     AS tics_compartidos,
    ROUND(AVG(
        SQRT( POWER(e1.pos_x - e2.pos_x, 2)
            + POWER(e1.pos_y - e2.pos_y, 2)
            + POWER(e1.pos_z - e2.pos_z, 2) )
    )::numeric, 2) AS distancia_promedio
FROM TelemetryEvent e1
JOIN TelemetryEvent e2
  ON e1.game_id   = e2.game_id
 AND e1.tic       = e2.tic
 AND e1.player_id < e2.player_id      
GROUP BY e1.player_id, e2.player_id
ORDER BY distancia_promedio ASC
LIMIT 10;



WITH pasos AS (
    SELECT
        player_id,
        game_id,
        SQRT( POWER(pos_x - LAG(pos_x) OVER w, 2)
            + POWER(pos_y - LAG(pos_y) OVER w, 2)
            + POWER(pos_z - LAG(pos_z) OVER w, 2) ) AS dist_paso
    FROM TelemetryEvent
    WINDOW w AS (PARTITION BY player_id, game_id ORDER BY tic)
),
trayectoria_por_juego AS (
    SELECT player_id, game_id, COALESCE(SUM(dist_paso), 0) AS dist_total
    FROM pasos
    GROUP BY player_id, game_id
)
SELECT
    player_id,
    ROUND(MIN(dist_total)::numeric, 2) AS trayectoria_mas_corta,
    ROUND(MAX(dist_total)::numeric, 2) AS trayectoria_mas_larga
FROM trayectoria_por_juego
GROUP BY player_id
ORDER BY player_id;


WITH conteo_celdas AS (
    SELECT
        ep.episode_id,
        ep.name                  AS episode_name,
        m.map_id,
        m.name                   AS map_name,
        FLOOR(te.pos_x / 250)::int AS grid_x,
        FLOOR(te.pos_y / 250)::int AS grid_y,
        COUNT(*)                 AS visitas
    FROM TelemetryEvent te
    JOIN Game    g  ON g.game_id    = te.game_id
    JOIN Map     m  ON m.map_id     = g.map_id
    JOIN Episode ep ON ep.episode_id = m.episode_id
    GROUP BY ep.episode_id, ep.name, m.map_id, m.name, grid_x, grid_y
),
ranking AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY episode_id, map_id
                           ORDER BY visitas DESC) AS rn
    FROM conteo_celdas
)
SELECT episode_id, episode_name, map_id, map_name,
       grid_x, grid_y, visitas
FROM ranking
WHERE rn = 1
ORDER BY episode_id, map_id;


SELECT
    e1.game_id,
    e1.player_id AS jugador_a,
    e2.player_id AS jugador_b,
    COUNT(DISTINCT e1.tic) AS tics_juntos
FROM TelemetryEvent e1
JOIN TelemetryEvent e2
  ON e1.game_id   = e2.game_id
 AND e1.tic       = e2.tic
 AND e1.player_id < e2.player_id
 AND FLOOR(e1.pos_x / 250) = FLOOR(e2.pos_x / 250)
 AND FLOOR(e1.pos_y / 250) = FLOOR(e2.pos_y / 250)
GROUP BY e1.game_id, e1.player_id, e2.player_id
ORDER BY tics_juntos DESC;



WITH pasos AS (
    SELECT
        player_id,
        SQRT( POWER(pos_x - LAG(pos_x) OVER w, 2)
            + POWER(pos_y - LAG(pos_y) OVER w, 2)
            + POWER(pos_z - LAG(pos_z) OVER w, 2) ) AS dist_paso
    FROM TelemetryEvent
    WINDOW w AS (PARTITION BY player_id, game_id ORDER BY tic)
)
SELECT
    player_id,
    COUNT(dist_paso)                       AS num_pasos,
    ROUND(SUM(dist_paso)::numeric, 2)      AS distancia_total,
    ROUND((SUM(dist_paso) / NULLIF(COUNT(dist_paso), 0))::numeric, 4)
                                           AS velocidad_promedio_por_tic
FROM pasos
GROUP BY player_id
ORDER BY distancia_total DESC;


