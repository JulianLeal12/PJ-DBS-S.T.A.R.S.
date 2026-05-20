-- =============================================
-- Doom Telemetry Database
-- 01_schema.sql - Creacion de tablas
-- =============================================

CREATE TABLE "User" ( //comillas para evitar conflicto con palabra reservada
    user_id         INTEGER         PRIMARY KEY,
    age             INTEGER         CHECK (age >= 0),
    gender          VARCHAR(20),
    experience_level VARCHAR(20)
);

CREATE TABLE Episode (
    episode_id      INTEGER         PRIMARY KEY NOT NULL,
    name            VARCHAR(50)
);

CREATE TABLE UXInstrument (
    instrument_id   INTEGER         PRIMARY KEY NOT NULL,
    name            VARCHAR(20),
    version         VARCHAR(10)
);

-- Tablas con una FK

CREATE TABLE Player (
    player_id       INTEGER         PRIMARY KEY,
    user_id         INTEGER         REFERENCES "User"(user_id), // FK
    alias           VARCHAR(50)
);

CREATE TABLE Map (
    map_id          INTEGER         PRIMARY KEY NOT NULL,
    episode_id      INTEGER         NOT NULL REFERENCES Episode(episode_id),
    name            VARCHAR(50)
);

CREATE TABLE UXItem (
    item_id         INTEGER         PRIMARY KEY NOT NULL,
    instrument_id   INTEGER         NOT NULL REFERENCES UXInstrument(instrument_id),
    item_number     INTEGER,
    question_text   VARCHAR(200)
);

-- Tablas con dos o mas FKs

CREATE TABLE Sector (
    sector_id       INTEGER         PRIMARY KEY NOT NULL,
    map_id          INTEGER         NOT NULL REFERENCES Map(map_id),
    sector_number   INTEGER
);

CREATE TABLE Game (
    game_id         INTEGER         PRIMARY KEY NOT NULL,
    map_id          INTEGER         NOT NULL REFERENCES Map(map_id),
    start_time      TIME            NOT NULL,
    end_time        TIME            CHECK (end_time > start_time),
    skill_level     INTEGER
);

CREATE TABLE TelemetryEvent (
    event_id        INTEGER         PRIMARY KEY NOT NULL,
    game_id         INTEGER         NOT NULL REFERENCES Game(game_id),
    player_id       INTEGER         NOT NULL REFERENCES Player(player_id),
    tic             INTEGER         NOT NULL CHECK (tic > 0),
    pos_x           NUMERIC(10,2)   NOT NULL,
    pos_y           NUMERIC(10,2)   NOT NULL,
    pos_z           NUMERIC(10,2)   NOT NULL,
    angle           NUMERIC(6,2)    NOT NULL
);

CREATE TABLE UXResponse (
    response_id     INTEGER         PRIMARY KEY NOT NULL,
    user_id         INTEGER         NOT NULL REFERENCES "User"(user_id),
    instrument_id   INTEGER         NOT NULL REFERENCES UXInstrument(instrument_id),
    game_id         INTEGER         REFERENCES Game(game_id),
    responded_at    TIME
);

CREATE TABLE UXResponseItem (
    response_id     INTEGER         NOT NULL REFERENCES UXResponse(response_id),
    item_id         INTEGER         NOT NULL REFERENCES UXItem(item_id),
    score           INTEGER         NOT NULL CHECK (score >= 1 AND score <= 5),
    PRIMARY KEY (response_id, item_id)
);
