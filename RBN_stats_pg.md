# RBN statisztikák PostgreSQL-ben

A tábla (egyszer kell létrehozni):

```sql
CREATE TABLE rbn_stats (
    callsign    VARCHAR(20),
    de_pfx      VARCHAR(10),
    de_cont     VARCHAR(5),
    freq        NUMERIC(10, 3), -- Pontos frekvencia ábrázoláshoz
    band        VARCHAR(10),
    dx          VARCHAR(20),
    dx_pfx      VARCHAR(10),
    dx_cont     VARCHAR(5),
    mode        VARCHAR(10),
    db          REAL,
    date        TIMESTAMP WITH TIME ZONE, -- Időzóna-helyes időbélyeg
    speed       REAL,
    tx_mode     VARCHAR(10)
);
```

Importáljuk az adatot:

```sql
\copy rbn_stats FROM '/home/fuszenecker/Downloads/20260722.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
```

Elemzés:

```sql
SELECT 
    TO_CHAR(date, 'YYYY-MM-DD') AS dátum,
    band AS sáv,
    de_cont AS kontinens,
    COUNT(1) AS szám,
    ROUND(CAST(AVG(db) AS NUMERIC), 1) AS átlag,
    ROUND(CAST(STDDEV_POP(db) AS NUMERIC), 1) AS szórás,
    MIN(db) AS min,
    MAX(db) AS max
FROM rbn_stats
WHERE dx LIKE 'HA8LHS%'
    AND date BETWEEN '2026-07-22' AND '2026-07-24'
GROUP BY TO_CHAR(date, 'YYYY-MM-DD'), band, de_cont
ORDER BY dátum, band DESC, de_cont;
```


