

CREATE TABLE IF NOT EXISTS UXInstrument (
    instrument_id   INTEGER         PRIMARY KEY,
    name            VARCHAR(20)     NOT NULL,
    version         VARCHAR(10),
    likert_min      SMALLINT        NOT NULL DEFAULT 1,
    likert_max      SMALLINT        NOT NULL DEFAULT 7,
    CONSTRAINT chk_likert_range CHECK (likert_max > likert_min)
);

-- Catalogo de items del instrumento (1 fila por pregunta).
CREATE TABLE IF NOT EXISTS UXItem (
    item_id         INTEGER         PRIMARY KEY,
    instrument_id   INTEGER         NOT NULL REFERENCES UXInstrument(instrument_id),
    item_number     SMALLINT        NOT NULL,         -- orden canonico 1..18
    subscale        VARCHAR(30)     NOT NULL,         -- p.ej. autonomy_satisfaction
    item_text       VARCHAR(255)    NOT NULL,
    is_reverse_scored BOOLEAN       NOT NULL DEFAULT FALSE,
    CONSTRAINT uq_item_per_instrument UNIQUE (instrument_id, item_number),
    CONSTRAINT chk_subscale CHECK (subscale IN (
        'autonomy_satisfaction',   'autonomy_frustration',
        'competence_satisfaction', 'competence_frustration',
        'relatedness_satisfaction','relatedness_frustration'
    ))
);

-- Detalle de respuestas: 1 fila por (respuesta, item).
-- Asume que UXResponse ya existe (cabecera con user_id, instrument_id,
-- game_id, responded_at).
CREATE TABLE IF NOT EXISTS UXResponseItem (
    response_id     INTEGER         NOT NULL REFERENCES UXResponse(response_id),
    item_id         INTEGER         NOT NULL REFERENCES UXItem(item_id),
    answer_value    SMALLINT        NOT NULL,
    PRIMARY KEY (response_id, item_id),
    CONSTRAINT chk_answer_likert CHECK (answer_value BETWEEN 1 AND 7)
);


-- =====================================================================
-- 2. Poblar el instrumento: BANGS
-- =====================================================================

INSERT INTO UXInstrument (instrument_id, name, version, likert_min, likert_max)
VALUES (1, 'BANGS', '1.0', 1, 7)
ON CONFLICT (instrument_id) DO NOTHING;




INSERT INTO UXItem (item_id, instrument_id, item_number, subscale, item_text, is_reverse_scored) VALUES

(1, 1, 1, 'autonomy_satisfaction',   'Senti que las cosas que hacia en el juego eran decisiones propias.', FALSE),
(2, 1, 2, 'autonomy_satisfaction',   'Senti libertad para jugar a mi manera.', FALSE),
(3, 1, 3, 'autonomy_satisfaction',   'Las acciones que realice en el juego reflejaban lo que yo queria hacer.', FALSE),

(4, 1, 4, 'autonomy_frustration',    'Senti que el juego me obligaba a hacer cosas que no queria.', FALSE),
(5, 1, 5, 'autonomy_frustration',    'Senti presion para jugar de una forma especifica.', FALSE),
(6, 1, 6, 'autonomy_frustration',    'Senti que tenia poca eleccion sobre como avanzar en el juego.', FALSE),

(7, 1, 7, 'competence_satisfaction', 'Senti que fui mejorando mientras jugaba.', FALSE),
(8, 1, 8, 'competence_satisfaction', 'Senti que podia superar los retos del juego con eficacia.', FALSE),
(9, 1, 9, 'competence_satisfaction', 'Senti una sensacion de logro al jugar.', FALSE),


(10, 1, 10, 'competence_frustration', 'Senti que no era lo suficientemente bueno en el juego.', FALSE),
(11, 1, 11, 'competence_frustration', 'Senti que cometia demasiados errores al jugar.', FALSE),
(12, 1, 12, 'competence_frustration', 'Senti dudas sobre mi capacidad para enfrentar los desafios del juego.', FALSE),
-
(13, 1, 13, 'relatedness_satisfaction', 'Senti una conexion con otros personajes o jugadores durante la sesion.', FALSE),
(14, 1, 14, 'relatedness_satisfaction', 'Senti que importaba a los demas presentes en el juego.', FALSE),
(15, 1, 15, 'relatedness_satisfaction', 'Senti cercania con otros personajes o jugadores.', FALSE),

(16, 1, 16, 'relatedness_frustration', 'Senti que los demas en el juego eran indiferentes hacia mi.', FALSE),
(17, 1, 17, 'relatedness_frustration', 'Senti que estaba solo o aislado durante la sesion.', FALSE),
(18, 1, 18, 'relatedness_frustration', 'Senti distancia respecto a otros personajes o jugadores.', FALSE)
ON CONFLICT (instrument_id, item_number) DO NOTHING;


