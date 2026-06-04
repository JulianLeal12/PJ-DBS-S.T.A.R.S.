-- =============================================
-- Doom Telemetry Database
-- setup.sql - Recreacion completa de la DB
-- Ejecutar con:
-- psql -U postgres -d doom_telemetry -f setup.sql
-- =============================================

-- 1. Schema: creacion de tablas
\i sql/01_schema.sql

-- 2. ETL: carga de sesiones reales desde TSV
\i sql/02_etl.sql

-- 3. Instrumento UX: preguntas BANGS
\i sql/03_ux_instrument_bangs.sql

-- 4. Datos sinteticos: 6 jugadores, 3 episodios, 20k+ filas
\i sql/05_sample_data.sql

-- 6. Vistas
\i sql/06_queries.sql
 
-- 7. Queries analiticas
\i sql/07_views.sql

-- 4. Indices
\i sql/08_indexes.sql
 
