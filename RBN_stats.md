# RBN statisztikák

Import CSV:

```sql
.mode csv
.import 20260615.csv _y_20260615
```

Mód beállítása:

```sql
.mode box
```

Elemzés:

```sql
SELECT dx, band AS sáv, ROUND(AVG(db), 1) AS átlag, ROUND(SQRT(AVG(db * db) - (AVG(db) * AVG(db))), 1) AS szórás FROM _y_20260615 WHERE dx LIKE 'HA8LHS%' GROUP BY dx, band;
```
