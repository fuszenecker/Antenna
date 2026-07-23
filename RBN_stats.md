# RBN statisztikák

Ezt egyszer kell:

```sql
CREATE TABLE IF NOT EXISTS "rbn_stats"
(
    "callsign" TEXT,
    "de_pfx" TEXT,
    "de_cont" TEXT,
    "freq" REAL,
    "band" TEXT,
    "dx" TEXT,
    "dx_pfx" TEXT,
    "dx_cont" TEXT,
    "mode" TEXT,
    "db" REAL,
    "date" TEXT,
    "speed" REAL,
    "tx_mode" TEXT
);
```

Import CSV:

```sql
.mode csv
.import 20260615.csv rbn_stats
```

Mód beállítása:

```sql
.mode box
```

Elemzés:

```sql
SELECT strftime('%Y-%m-%d', date) AS dátum,
    band AS sáv,
    de_cont AS kontinens,
    COUNT(1) AS szám,
    ROUND(AVG(db), 1) AS átlag,
    ROUND(SQRT(AVG(db * db) - (AVG(db) * AVG(db))), 1) AS szórás,
    MIN(db) as min,
    MAX(db) as max
FROM rbn_stats
WHERE dx LIKE 'HA8LHS%'
    AND date BETWEEN '2026-07-22' AND '2026-07-23'
GROUP BY band, de_cont
ORDER BY date, band, de_cont;
```
