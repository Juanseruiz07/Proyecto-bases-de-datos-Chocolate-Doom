-- =========================================================
-- Parte B - Proyecto Chocolate Doom
-- Archivo: 01_schema.sql
-- Objetivo: Crear el esquema principal en PostgreSQL
-- =========================================================

DROP TABLE IF EXISTS ux_response CASCADE;
DROP TABLE IF EXISTS ux_item CASCADE;
DROP TABLE IF EXISTS ux_instrument CASCADE;
DROP TABLE IF EXISTS telemetry_event CASCADE;
DROP TABLE IF EXISTS game_participant CASCADE;
DROP TABLE IF EXISTS game CASCADE;
DROP TABLE IF EXISTS sector CASCADE;
DROP TABLE IF EXISTS map CASCADE;
DROP TABLE IF EXISTS episode CASCADE;
DROP TABLE IF EXISTS player CASCADE;
DROP TABLE IF EXISTS research_user CASCADE;

CREATE TABLE research_user (
    user_id          SERIAL PRIMARY KEY,
    anonymous_code   VARCHAR(50)  UNIQUE NOT NULL,
    age              INTEGER      NOT NULL CHECK (age >= 18),
    gender           VARCHAR(30),
    experience_level VARCHAR(30)  NOT NULL CHECK (
                         experience_level IN ('beginner', 'intermediate', 'advanced')
                     ),
    consent_accepted BOOLEAN      NOT NULL CHECK (consent_accepted = TRUE),
    consent_date     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE player (
    player_id  SERIAL PRIMARY KEY,
    user_id    INTEGER      NOT NULL REFERENCES research_user(user_id) ON DELETE CASCADE,
    nickname   VARCHAR(80)  NOT NULL,
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, nickname)
);

CREATE TABLE episode (
    episode_id   SERIAL PRIMARY KEY,
    episode_code VARCHAR(20)  UNIQUE NOT NULL,
    name         VARCHAR(100) NOT NULL
);

CREATE TABLE map (
    map_id     SERIAL PRIMARY KEY,
    episode_id INTEGER      NOT NULL REFERENCES episode(episode_id) ON DELETE CASCADE,
    map_code   VARCHAR(20)  NOT NULL,
    name       VARCHAR(100) NOT NULL,
    UNIQUE(episode_id, map_code)
);

CREATE TABLE sector (
    sector_id   SERIAL PRIMARY KEY,
    map_id      INTEGER       NOT NULL REFERENCES map(map_id) ON DELETE CASCADE,
    sector_code VARCHAR(30)   NOT NULL,
    grid_x      NUMERIC(10,2) NOT NULL,
    grid_y      NUMERIC(10,2) NOT NULL,
    UNIQUE(map_id, sector_code)
);

CREATE TABLE game (
    game_id    SERIAL PRIMARY KEY,
    map_id     INTEGER   NOT NULL REFERENCES map(map_id),
    start_time TIMESTAMP NOT NULL,
    end_time   TIMESTAMP,
    game_mode  VARCHAR(40),
    difficulty VARCHAR(40),
    CHECK (end_time IS NULL OR end_time > start_time)
);

CREATE TABLE game_participant (
    game_id     INTEGER NOT NULL REFERENCES game(game_id)     ON DELETE CASCADE,
    player_id   INTEGER NOT NULL REFERENCES player(player_id) ON DELETE CASCADE,
    role        VARCHAR(40),
    final_score INTEGER DEFAULT 0 CHECK (final_score >= 0),
    PRIMARY KEY (game_id, player_id)
);

CREATE TABLE telemetry_event (
    telemetry_id BIGSERIAL     PRIMARY KEY,
    game_id      INTEGER       NOT NULL REFERENCES game(game_id)     ON DELETE CASCADE,
    player_id    INTEGER       NOT NULL REFERENCES player(player_id) ON DELETE CASCADE,
    sector_id    INTEGER       NOT NULL REFERENCES sector(sector_id),
    tic          INTEGER       NOT NULL CHECK (tic > 0),
    pos_x        NUMERIC(12,4) NOT NULL,
    pos_y        NUMERIC(12,4) NOT NULL,
    pos_z        NUMERIC(12,4) NOT NULL,
    angle        NUMERIC(10,4),
    momentum_x   NUMERIC(12,4),
    momentum_y   NUMERIC(12,4),
    momentum_z   NUMERIC(12,4),
    fov          NUMERIC(8,2),
    health       INTEGER       CHECK (health >= 0),
    armor        INTEGER       CHECK (armor >= 0),
    ammo         INTEGER       CHECK (ammo >= 0),
    created_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(game_id, player_id, tic)
);

CREATE TABLE ux_instrument (
    instrument_id SERIAL PRIMARY KEY,
    name          VARCHAR(80) NOT NULL,
    version       VARCHAR(30),
    description   TEXT,
    UNIQUE(name, version)
);

CREATE TABLE ux_item (
    item_id       SERIAL PRIMARY KEY,
    instrument_id INTEGER     NOT NULL REFERENCES ux_instrument(instrument_id) ON DELETE CASCADE,
    item_code     VARCHAR(30) NOT NULL,
    question_text TEXT        NOT NULL,
    dimension     VARCHAR(80),
    UNIQUE(instrument_id, item_code)
);

CREATE TABLE ux_response (
    response_id   SERIAL       PRIMARY KEY,
    user_id       INTEGER      NOT NULL REFERENCES research_user(user_id)      ON DELETE CASCADE,
    instrument_id INTEGER      NOT NULL REFERENCES ux_instrument(instrument_id),
    response_date TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_score   NUMERIC(8,2)
);
