#!/bin/sh
set -eu

IN=/work/data/in/pingresp.json
OUT=/work/data/out/pingresp.ttl
M=/work/control-packets/pingresp.ttl
GDB=http://graphdb:7200/repositories/mqtt4ssn/statements

if [ ! -f "$IN" ]; then
  echo "[rmlmapper] PINGRESP skipped, input missing: $IN"
  exit 0
fi

echo "[rmlmapper] PINGRESP mapping once..."
java -jar /rmlmapper.jar -m "$M" -o "$OUT"

if [ -f "$OUT" ]; then
  echo "[rmlmapper] PINGRESP posting triples to GraphDB..."
  curl -sS -X POST \
    -H "Content-Type: text/turtle" \
    --data-binary @"$OUT" \
    "$GDB" >/dev/null
fi