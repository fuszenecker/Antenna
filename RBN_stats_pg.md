# RBN statisztikák PostgreSQL-ben

A tábla (egyszer kell létrehozni):

```sql
CREATE TABLE IF NOT EXISTS rbn_stats (
    id          BIGSERIAL PRIMARY KEY,
    callsign    TEXT NOT NULL,          -- vevő (skimmer) hívójele, pl. KW7MM-2
    de_pfx      TEXT NOT NULL,          -- vevő prefixe, pl. K
    de_cont     TEXT NOT NULL,          -- vevő kontinense, pl. NA
    freq        NUMERIC(10,2) NOT NULL, -- vett frekvencia kHz-ben
    band        TEXT NOT NULL,          -- sáv, pl. 20m
    dx          TEXT NOT NULL,          -- adó (spotted) hívójele
    dx_pfx      TEXT NOT NULL,          -- adó prefixe
    dx_cont     TEXT NOT NULL,          -- adó kontinense
    mode        TEXT NOT NULL,          -- CQ / BEACON / DX / NCDXF B
    db          SMALLINT NOT NULL,      -- SNR dB
    spot_ts     TIMESTAMP NOT NULL,     -- eredeti "date" oszlop (UTC)
    speed       SMALLINT NOT NULL,      -- WPM
    tx_mode     TEXT NOT NULL           -- CW / RTTY
);

-- gyakori lekérdezésekhez hasznos indexek
CREATE INDEX IF NOT EXISTS idx_rbn_stats_spot_ts   ON rbn_stats (spot_ts);
CREATE INDEX IF NOT EXISTS idx_rbn_stats_callsign  ON rbn_stats (callsign);
CREATE INDEX IF NOT EXISTS idx_rbn_stats_dx        ON rbn_stats (dx);
CREATE INDEX IF NOT EXISTS idx_rbn_stats_band      ON rbn_stats (band);
```

Tisztítjuk az adatokat:

```sh
for file in *.csv; do
    [[ $file == CLEAN_* ]] && continue   # már tiszta fájlt ne dolgozzon fel újra
    grep -vE '^\([0-9]+ rows\)$' "$file" > "CLEAN_$file"
done
```

Importáljuk az adatot:

```sql
CREATE TEMP TABLE rbn_stats_staging (
    callsign  TEXT,
    de_pfx    TEXT,
    de_cont   TEXT,
    freq      NUMERIC(10,2),
    band      TEXT,
    dx        TEXT,
    dx_pfx    TEXT,
    dx_cont   TEXT,
    mode      TEXT,
    db        SMALLINT,
    spot_ts   TIMESTAMP,
    speed     SMALLINT,
    tx_mode   TEXT
);

\copy rbn_stats_staging FROM '/home/fuszenecker/Downloads/20260722.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',')

INSERT INTO rbn_stats (callsign, de_pfx, de_cont, freq, band, dx, dx_pfx, dx_cont, mode, db, spot_ts, speed, tx_mode)
SELECT callsign, de_pfx, de_cont, freq, band, dx, dx_pfx, dx_cont, mode, db, spot_ts, speed, tx_mode
FROM rbn_stats_staging;

DROP TABLE rbn_stats_staging;
```

Elemzés:

```sql
SELECT 
    TO_CHAR(spot_ts, 'YYYY-MM-DD') AS dátum,
    band AS sáv,
    de_cont AS kontinens,
    COUNT(1) AS szám,
    ROUND(CAST(AVG(db) AS NUMERIC), 1) AS átlag,
    ROUND(CAST(STDDEV_POP(db) AS NUMERIC), 1) AS szórás,
    MIN(db) AS min,
    MAX(db) AS max
FROM rbn_stats
WHERE dx IN ('HA8LHS', 'HA8LHS/P')
    AND spot_ts BETWEEN '2026-07-22' AND '2026-07-24'
GROUP BY TO_CHAR(spot_ts, 'YYYY-MM-DD'), band, de_cont
ORDER BY dátum, band DESC, de_cont;
```


