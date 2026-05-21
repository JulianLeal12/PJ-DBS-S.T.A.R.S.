-- =============================================
-- Doom Telemetry Database
-- 02_etl.sql - Pipeline ETL staging -> core
-- =============================================

-- Tabla staging: recibe el TSV tal cual (todo texto)
CREATE TABLE IF NOT EXISTS staging_telemetry (
    game_id   TEXT,
    player_id TEXT,
    tic       TEXT,
    pos_x     TEXT,
    pos_y     TEXT,
    pos_z     TEXT,
    angle     TEXT
);

-- Tabla de errores: filas invalidas o duplicadas
CREATE TABLE IF NOT EXISTS error_log_telemetry (
    error_id      SERIAL PRIMARY KEY,
    raw_game_id   TEXT,
    raw_player_id TEXT,
    raw_tic       TEXT,
    raw_pos_x     TEXT,
    raw_pos_y     TEXT,
    raw_pos_z     TEXT,
    raw_angle     TEXT
);

-- =============================================
-- SESION 1
-- =============================================
COPY staging_telemetry (game_id, player_id, tic, pos_x, pos_y, pos_z, angle)
FROM '/home/xerok/trajectory_doom/chocolate-doom/sesion1.tsv'
DELIMITER E'\t'
CSV HEADER;

INSERT INTO error_log_telemetry (raw_game_id, raw_player_id, raw_tic, raw_pos_x, raw_pos_y, raw_pos_z, raw_angle)
SELECT game_id, player_id, tic, pos_x, pos_y, pos_z, angle
FROM staging_telemetry
WHERE 
    game_id IS NULL OR player_id IS NULL OR tic IS NULL OR pos_x IS NULL OR pos_y IS NULL OR pos_z IS NULL OR angle IS NULL
    OR game_id !~ '^[0-9]+$'
    OR player_id !~ '^[0-9]+$'
    OR tic !~ '^[0-9]+$'
    OR pos_x !~ '^-?[0-9]+(\.[0-9]+)?$'
    OR pos_y !~ '^-?[0-9]+(\.[0-9]+)?$'
    OR pos_z !~ '^-?[0-9]+(\.[0-9]+)?$'
    OR angle !~ '^-?[0-9]+(\.[0-9]+)?$';

WITH cleaned_data AS (
    SELECT 
        game_id::INTEGER AS g_id,
        player_id::INTEGER AS p_id,
        tic::INTEGER AS t_tic,
        pos_x::NUMERIC(10,2) AS px,
        pos_y::NUMERIC(10,2) AS py,
        pos_z::NUMERIC(10,2) AS pz,
        angle::NUMERIC(6,2) AS ang,
        ROW_NUMBER() OVER (
            PARTITION BY game_id::INTEGER, tic::INTEGER, player_id::INTEGER 
            ORDER BY (SELECT NULL)
        ) AS row_num
    FROM staging_telemetry
    WHERE 
        game_id IS NOT NULL AND player_id IS NOT NULL AND tic IS NOT NULL 
        AND pos_x IS NOT NULL AND pos_y IS NOT NULL AND pos_z IS NOT NULL AND angle IS NOT NULL
        AND game_id ~ '^[0-9]+$' AND player_id ~ '^[0-9]+$' AND tic ~ '^[0-9]+$'
        AND pos_x ~ '^-?[0-9]+(\.[0-9]+)?$' AND pos_y ~ '^-?[0-9]+(\.[0-9]+)?$'
        AND pos_z ~ '^-?[0-9]+(\.[0-9]+)?$' AND angle ~ '^-?[0-9]+(\.[0-9]+)?$'
),
deduplicated_data AS (
    SELECT g_id, p_id, t_tic, px, py, pz, ang
    FROM cleaned_data WHERE row_num = 1
),
existing_max_id AS (
    SELECT COALESCE(MAX(event_id), 0) AS max_id FROM TelemetryEvent
)
INSERT INTO TelemetryEvent (event_id, game_id, player_id, tic, pos_x, pos_y, pos_z, angle)
SELECT 
    (ROW_NUMBER() OVER ()) + emi.max_id AS event_id,
    d.g_id, d.p_id, d.t_tic, d.px, d.py, d.pz, d.ang
FROM deduplicated_data d
CROSS JOIN existing_max_id emi
WHERE EXISTS (SELECT 1 FROM Game g WHERE g.game_id = d.g_id)
  AND EXISTS (SELECT 1 FROM Player p WHERE p.player_id = d.p_id);

TRUNCATE TABLE staging_telemetry;

-- =============================================
-- SESION 2
-- =============================================
COPY staging_telemetry (game_id, player_id, tic, pos_x, pos_y, pos_z, angle)
FROM '/home/xerok/trajectory_doom/chocolate-doom/sesion2.tsv'
DELIMITER E'\t'
CSV HEADER;

INSERT INTO error_log_telemetry (raw_game_id, raw_player_id, raw_tic, raw_pos_x, raw_pos_y, raw_pos_z, raw_angle)
SELECT game_id, player_id, tic, pos_x, pos_y, pos_z, angle
FROM staging_telemetry
WHERE 
    game_id IS NULL OR player_id IS NULL OR tic IS NULL OR pos_x IS NULL OR pos_y IS NULL OR pos_z IS NULL OR angle IS NULL
    OR game_id !~ '^[0-9]+$' OR player_id !~ '^[0-9]+$' OR tic !~ '^[0-9]+$'
    OR pos_x !~ '^-?[0-9]+(\.[0-9]+)?$' OR pos_y !~ '^-?[0-9]+(\.[0-9]+)?$'
    OR pos_z !~ '^-?[0-9]+(\.[0-9]+)?$' OR angle !~ '^-?[0-9]+(\.[0-9]+)?$';

WITH cleaned_data AS (
    SELECT 
        game_id::INTEGER AS g_id, player_id::INTEGER AS p_id, tic::INTEGER AS t_tic,
        pos_x::NUMERIC(10,2) AS px, pos_y::NUMERIC(10,2) AS py,
        pos_z::NUMERIC(10,2) AS pz, angle::NUMERIC(6,2) AS ang,
        ROW_NUMBER() OVER (
            PARTITION BY game_id::INTEGER, tic::INTEGER, player_id::INTEGER 
            ORDER BY (SELECT NULL)
        ) AS row_num
    FROM staging_telemetry
    WHERE 
        game_id IS NOT NULL AND player_id IS NOT NULL AND tic IS NOT NULL 
        AND pos_x IS NOT NULL AND pos_y IS NOT NULL AND pos_z IS NOT NULL AND angle IS NOT NULL
        AND game_id ~ '^[0-9]+$' AND player_id ~ '^[0-9]+$' AND tic ~ '^[0-9]+$'
        AND pos_x ~ '^-?[0-9]+(\.[0-9]+)?$' AND pos_y ~ '^-?[0-9]+(\.[0-9]+)?$'
        AND pos_z ~ '^-?[0-9]+(\.[0-9]+)?$' AND angle ~ '^-?[0-9]+(\.[0-9]+)?$'
),
deduplicated_data AS (
    SELECT g_id, p_id, t_tic, px, py, pz, ang FROM cleaned_data WHERE row_num = 1
),
existing_max_id AS (
    SELECT COALESCE(MAX(event_id), 0) AS max_id FROM TelemetryEvent
)
INSERT INTO TelemetryEvent (event_id, game_id, player_id, tic, pos_x, pos_y, pos_z, angle)
SELECT 
    (ROW_NUMBER() OVER ()) + emi.max_id AS event_id,
    d.g_id, d.p_id, d.t_tic, d.px, d.py, d.pz, d.ang
FROM deduplicated_data d
CROSS JOIN existing_max_id emi
WHERE EXISTS (SELECT 1 FROM Game g WHERE g.game_id = d.g_id)
  AND EXISTS (SELECT 1 FROM Player p WHERE p.player_id = d.p_id);

TRUNCATE TABLE staging_telemetry;

-- =============================================
-- SESION 3
-- =============================================
COPY staging_telemetry (game_id, player_id, tic, pos_x, pos_y, pos_z, angle)
FROM '/home/xerok/trajectory_doom/chocolate-doom/sesion3.tsv'
DELIMITER E'\t'
CSV HEADER;

INSERT INTO error_log_telemetry (raw_game_id, raw_player_id, raw_tic, raw_pos_x, raw_pos_y, raw_pos_z, raw_angle)
SELECT game_id, player_id, tic, pos_x, pos_y, pos_z, angle
FROM staging_telemetry
WHERE 
    game_id IS NULL OR player_id IS NULL OR tic IS NULL OR pos_x IS NULL OR pos_y IS NULL OR pos_z IS NULL OR angle IS NULL
    OR game_id !~ '^[0-9]+$' OR player_id !~ '^[0-9]+$' OR tic !~ '^[0-9]+$'
    OR pos_x !~ '^-?[0-9]+(\.[0-9]+)?$' OR pos_y !~ '^-?[0-9]+(\.[0-9]+)?$'
    OR pos_z !~ '^-?[0-9]+(\.[0-9]+)?$' OR angle !~ '^-?[0-9]+(\.[0-9]+)?$';

WITH cleaned_data AS (
    SELECT 
        game_id::INTEGER AS g_id, player_id::INTEGER AS p_id, tic::INTEGER AS t_tic,
        pos_x::NUMERIC(10,2) AS px, pos_y::NUMERIC(10,2) AS py,
        pos_z::NUMERIC(10,2) AS pz, angle::NUMERIC(6,2) AS ang,
        ROW_NUMBER() OVER (
            PARTITION BY game_id::INTEGER, tic::INTEGER, player_id::INTEGER 
            ORDER BY (SELECT NULL)
        ) AS row_num
    FROM staging_telemetry
    WHERE 
        game_id IS NOT NULL AND player_id IS NOT NULL AND tic IS NOT NULL 
        AND pos_x IS NOT NULL AND pos_y IS NOT NULL AND pos_z IS NOT NULL AND angle IS NOT NULL
        AND game_id ~ '^[0-9]+$' AND player_id ~ '^[0-9]+$' AND tic ~ '^[0-9]+$'
        AND pos_x ~ '^-?[0-9]+(\.[0-9]+)?$' AND pos_y ~ '^-?[0-9]+(\.[0-9]+)?$'
        AND pos_z ~ '^-?[0-9]+(\.[0-9]+)?$' AND angle ~ '^-?[0-9]+(\.[0-9]+)?$'
),
deduplicated_data AS (
    SELECT g_id, p_id, t_tic, px, py, pz, ang FROM cleaned_data WHERE row_num = 1
),
existing_max_id AS (
    SELECT COALESCE(MAX(event_id), 0) AS max_id FROM TelemetryEvent
)
INSERT INTO TelemetryEvent (event_id, game_id, player_id, tic, pos_x, pos_y, pos_z, angle)
SELECT 
    (ROW_NUMBER() OVER ()) + emi.max_id AS event_id,
    d.g_id, d.p_id, d.t_tic, d.px, d.py, d.pz, d.ang
FROM deduplicated_data d
CROSS JOIN existing_max_id emi
WHERE EXISTS (SELECT 1 FROM Game g WHERE g.game_id = d.g_id)
  AND EXISTS (SELECT 1 FROM Player p WHERE p.player_id = d.p_id);

TRUNCATE TABLE staging_telemetry;

-- =============================================
-- SESION 4
-- =============================================
COPY staging_telemetry (game_id, player_id, tic, pos_x, pos_y, pos_z, angle)
FROM '/home/xerok/trajectory_doom/chocolate-doom/sesion4.tsv'
DELIMITER E'\t'
CSV HEADER;

INSERT INTO error_log_telemetry (raw_game_id, raw_player_id, raw_tic, raw_pos_x, raw_pos_y, raw_pos_z, raw_angle)
SELECT game_id, player_id, tic, pos_x, pos_y, pos_z, angle
FROM staging_telemetry
WHERE 
    game_id IS NULL OR player_id IS NULL OR tic IS NULL OR pos_x IS NULL OR pos_y IS NULL OR pos_z IS NULL OR angle IS NULL
    OR game_id !~ '^[0-9]+$' OR player_id !~ '^[0-9]+$' OR tic !~ '^[0-9]+$'
    OR pos_x !~ '^-?[0-9]+(\.[0-9]+)?$' OR pos_y !~ '^-?[0-9]+(\.[0-9]+)?$'
    OR pos_z !~ '^-?[0-9]+(\.[0-9]+)?$' OR angle !~ '^-?[0-9]+(\.[0-9]+)?$';

WITH cleaned_data AS (
    SELECT 
        game_id::INTEGER AS g_id, player_id::INTEGER AS p_id, tic::INTEGER AS t_tic,
        pos_x::NUMERIC(10,2) AS px, pos_y::NUMERIC(10,2) AS py,
        pos_z::NUMERIC(10,2) AS pz, angle::NUMERIC(6,2) AS ang,
        ROW_NUMBER() OVER (
            PARTITION BY game_id::INTEGER, tic::INTEGER, player_id::INTEGER 
            ORDER BY (SELECT NULL)
        ) AS row_num
    FROM staging_telemetry
    WHERE 
        game_id IS NOT NULL AND player_id IS NOT NULL AND tic IS NOT NULL 
        AND pos_x IS NOT NULL AND pos_y IS NOT NULL AND pos_z IS NOT NULL AND angle IS NOT NULL
        AND game_id ~ '^[0-9]+$' AND player_id ~ '^[0-9]+$' AND tic ~ '^[0-9]+$'
        AND pos_x ~ '^-?[0-9]+(\.[0-9]+)?$' AND pos_y ~ '^-?[0-9]+(\.[0-9]+)?$'
        AND pos_z ~ '^-?[0-9]+(\.[0-9]+)?$' AND angle ~ '^-?[0-9]+(\.[0-9]+)?$'
),
deduplicated_data AS (
    SELECT g_id, p_id, t_tic, px, py, pz, ang FROM cleaned_data WHERE row_num = 1
),
existing_max_id AS (
    SELECT COALESCE(MAX(event_id), 0) AS max_id FROM TelemetryEvent
)
INSERT INTO TelemetryEvent (event_id, game_id, player_id, tic, pos_x, pos_y, pos_z, angle)
SELECT 
    (ROW_NUMBER() OVER ()) + emi.max_id AS event_id,
    d.g_id, d.p_id, d.t_tic, d.px, d.py, d.pz, d.ang
FROM deduplicated_data d
CROSS JOIN existing_max_id emi
WHERE EXISTS (SELECT 1 FROM Game g WHERE g.game_id = d.g_id)
  AND EXISTS (SELECT 1 FROM Player p WHERE p.player_id = d.p_id);

TRUNCATE TABLE staging_telemetry;
