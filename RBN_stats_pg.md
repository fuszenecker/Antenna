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
```


