# RBN statisztikák

Ezt egyszer kell:

```sql
CREATE TABLE IF NOT EXISTS "rbn_stats"(
  "callsign" TEXT, "de_pfx" TEXT, "de_cont" TEXT, "freq" REAL,
  "band" TEXT, "dx" TEXT, "dx_pfx" TEXT, "dx_cont" TEXT,
  "mode" TEXT, "db" REAL, "date" TEXT, "speed" REAL,
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
SELECT dx, band AS sáv, ROUND(AVG(db), 1) AS átlag, ROUND(SQRT(AVG(db * db) - (AVG(db) * AVG(db))), 1) AS szórás FROM rbn_stats WHERE dx LIKE 'HA8LHS%' GROUP BY dx, band;
```
