#!/bin/sh
set -eu

IN=/work/data/in/puback.json
OUT=/work/data/out/puback.ttl
M=/work/control-packets/puback.ttl
GDB=http://graphdb:7200/repositories/mqtt4ssn/statements

if [ ! -f "$IN" ]; then
  echo "[rmlmapper] PUBACK skipped, input missing: $IN"
  exit 0
fi

echo "[rmlmapper] PUBACK mapping once..."
java -jar /rmlmapper.jar -m "$M" -o "$OUT"

if [ -f "$OUT" ]; then
  echo "[rmlmapper] PUBACK posting triples to GraphDB..."
  curl -sS -X POST \
    -H "Content-Type: text/turtle" \
    --data-binary @"$OUT" \
    "$GDB" >/dev/null
fi