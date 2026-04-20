#!/bin/sh
set -eu

IN=/work/data/in/pubrec.json
OUT=/work/data/out/pubrec.ttl
M=/work/control-packets/pubrec.ttl
GDB=http://graphdb:7200/repositories/mqtt4ssn/statements

if [ ! -f "$IN" ]; then
  echo "[rmlmapper] PUBREC skipped, input missing: $IN"
  exit 0
fi

echo "[rmlmapper] PUBREC mapping once..."
java -jar /rmlmapper.jar -m "$M" -o "$OUT"

if [ -f "$OUT" ]; then
  echo "[rmlmapper] PUBREC posting triples to GraphDB..."
  curl -sS -X POST \
    -H "Content-Type: text/turtle" \
    --data-binary @"$OUT" \
    "$GDB" >/dev/null
fi