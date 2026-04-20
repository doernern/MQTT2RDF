#!/bin/sh
set -eu

IN=/work/data/in/suback.json
OUT=/work/data/out/suback.ttl
M=/work/control-packets/suback.ttl
GDB=http://graphdb:7200/repositories/mqtt4ssn/statements

if [ ! -f "$IN" ]; then
  echo "[rmlmapper] SUBACK skipped, input missing: $IN"
  exit 0
fi

echo "[rmlmapper] SUBACK mapping once..."
java -jar /rmlmapper.jar -m "$M" -o "$OUT"

if [ -f "$OUT" ]; then
  echo "[rmlmapper] SUBACK posting triples to GraphDB..."
  curl -sS -X POST \
    -H "Content-Type: text/turtle" \
    --data-binary @"$OUT" \
    "$GDB" >/dev/null
fi