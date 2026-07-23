#!/usr/bin/env bash
#
# RBN history letöltés + kicsomagolás + tisztítás + Postgres import
#
# Használat:
#   ./import_rbn.sh 2026-07-01 2026-07-16
#
# Postgres kapcsolat paraméterei (mind felülírható env változóval):
#   PG_HOST      (alapértelmezett: localhost)
#   PG_PORT      (alapértelmezett: 5432)
#   PG_USER      (alapértelmezett: az aktuális OS user)
#   PG_DB        (alapértelmezett: rbn)
#   PG_PASSWORD  (alapértelmezett: üres — inkább .pgpass-t használj)
#
# Példa:
#   PG_HOST=db.example.com PG_PORT=5432 PG_USER=robi PG_DB=fuszenecker \
#       ./import_rbn.sh 2026-07-01 2026-07-16
#
# Postgres kapcsolati paraméterek — felülírhatók env változóval, pl.:
#   PG_DB=fuszenecker PG_USER=robi PG_HOST=db.example.com ./import_rbn.sh 2026-07-01 2026-07-16
# Jelszóhoz .pgpass fájl ajánlott (ne kerüljön jelszó a szkriptbe/parancssorba);
# ha mégis env-ből kell, PG_PASSWORD-ot állíts be, azt a szkript PGPASSWORD-ként adja tovább.

PG_HOST="${PG_HOST:-localhost}"
PG_PORT="${PG_PORT:-5432}"
PG_USER="${PG_USER:-$(whoami)}"
PG_DB="${PG_DB:-rbn}"
PG_PASSWORD="${PG_PASSWORD:-}"

set -euo pipefail

FROM_DATE="${1:?Használat: $0 FROM_DATE TO_DATE (YYYY-MM-DD)}"
TO_DATE="${2:?Használat: $0 FROM_DATE TO_DATE (YYYY-MM-DD)}"

BASE_URL="https://data.reversebeacon.net/rbn_history"
WORK_DIR="${WORK_DIR:-./rbn_import}"

PSQL_OPTS=(-h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -d "$PG_DB")
if [[ -n "$PG_PASSWORD" ]]; then
    export PGPASSWORD="$PG_PASSWORD"
fi

mkdir -p "$WORK_DIR"/{downloads,extracted,clean,logs}
LOG_FILE="$WORK_DIR/logs/import_$(date +%Y%m%d_%H%M%S).log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# --- dátumtartomány validálás ---
if ! date -d "$FROM_DATE" >/dev/null 2>&1; then
    echo "Hibás FROM_DATE: $FROM_DATE" >&2; exit 1
fi
if ! date -d "$TO_DATE" >/dev/null 2>&1; then
    echo "Hibás TO_DATE: $TO_DATE" >&2; exit 1
fi

d="$FROM_DATE"
while [[ "$(date -d "$d" +%Y%m%d)" -le "$(date -d "$TO_DATE" +%Y%m%d)" ]]; do
    ymd="$(date -d "$d" +%Y%m%d)"
    next_ymd="$(date -d "$d + 1 day" +%Y-%m-%d)"

    zip_path="$WORK_DIR/downloads/${ymd}.zip"
    csv_path="$WORK_DIR/extracted/${ymd}.csv"
    clean_path="$WORK_DIR/clean/CLEAN_${ymd}.csv"

    log "=== $ymd feldolgozása ==="

    # 1. Letöltés (ha még nincs meg)
    if [[ -s "$zip_path" ]]; then
        log "Már letöltve: $zip_path"
    else
        log "Letöltés: $BASE_URL/${ymd}.zip"
        if ! curl -sSf -o "$zip_path" "$BASE_URL/${ymd}.zip"; then
            log "HIBA: nem sikerült letölteni ${ymd}.zip — kihagyva"
            rm -f "$zip_path"
            d="$next_ymd"
            continue
        fi
    fi

    # 2. Kicsomagolás (ha még nincs meg)
    if [[ -s "$csv_path" ]]; then
        log "Már kicsomagolva: $csv_path"
    else
        log "Kicsomagolás..."
        if ! unzip -p "$zip_path" > "$csv_path"; then
            log "HIBA: kicsomagolás sikertelen (${ymd}.zip) — kihagyva"
            rm -f "$csv_path"
            d="$next_ymd"
            continue
        fi
    fi

    # 3. Tisztítás — a psql exportból odaragadt "(N rows)" és üres sorok kiszűrése
    log "Tisztítás..."
    grep -vE '^\([0-9]+ rows\)$' "$csv_path" | sed '/^$/d' > "$clean_path"

    rows=$(( $(wc -l < "$clean_path") - 1 ))
    log "Tiszta adatsorok (fejléc nélkül): $rows"

    if [[ "$rows" -le 0 ]]; then
        log "FIGYELEM: 0 adatsor $ymd-hez, import kihagyva"
        d="$next_ymd"
        continue
    fi

    # 4. Import Postgresbe — staging táblán át, idempotensen
    #    (ha a napot már importáltuk korábban, előbb töröljük, hogy
    #    újrafuttatásra ne duplikálódjon az adat)
    log "Import Postgresbe ($PG_USER@$PG_HOST:$PG_PORT/$PG_DB)..."
    if psql "${PSQL_OPTS[@]}" -v ON_ERROR_STOP=1 --set=day="$ymd" --set=nextday="$(date -d "$next_ymd" +%Y%m%d)" <<SQL >>"$LOG_FILE" 2>&1
BEGIN;

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

\copy rbn_stats_staging FROM '$clean_path' WITH (FORMAT csv, HEADER true, ON_ERROR ignore, LOG_VERBOSITY verbose)

DELETE FROM rbn_stats
WHERE spot_ts >= TO_TIMESTAMP(:'day', 'YYYYMMDD')
  AND spot_ts <  TO_TIMESTAMP(:'nextday', 'YYYYMMDD');

INSERT INTO rbn_stats (callsign, de_pfx, de_cont, freq, band, dx, dx_pfx, dx_cont, mode, db, spot_ts, speed, tx_mode)
SELECT callsign, de_pfx, de_cont, freq, band, dx, dx_pfx, dx_cont, mode, db, spot_ts, speed, tx_mode
FROM rbn_stats_staging;

COMMIT;
SQL
    then
        log "$ymd sikeresen importálva ($rows sor)."
    else
        log "HIBA: $ymd importja sikertelen — lásd fent a psql kimenetet."
    fi

    d="$next_ymd"
done

log "Kész."
