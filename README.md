# PJ-DBS-S.T.A.R.S.
# Doom Telemetry Database

Proyecto de bases de datos – Universidad Javeriana, 2026

## Descripción
Base de datos relacional en PostgreSQL para almacenar y analizar
telemetría de sesiones de Chocolate-Doom.

## Requisitos
- PostgreSQL 14+
- psql

## Cómo ejecutar
Con setup.sql
```bash
psql -U postgres -d doom_telemetry -f sql/01_schema.sql
psql -U postgres -d doom_telemetry -f sql/02_etl.sql
psql -U postgres -d doom_telemetry -f sql/03_ux_instrument_bangs.sql
psql -U postgres -d doom_telemetry -f sql/05_sample_data.sql
```
