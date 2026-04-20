#!/bin/sh
set -eu

IN=/work/data/in/unsuback.json
OUT=/work/data/out/unsuback.ttl
M=/work/control-packets/unsuback.ttl
GDB=http://graphdb:7200/repositories/mqtt4ssn/statements

if [ ! -f "$IN" ]; then
  echo "[rmlmapper] UNSUBACK skipped, input missing: $IN"
  exit 0
fi

echo "[rmlmapper] UNSUBACK mapping once..."
java -jar /rmlmapper.jar -m "$M" -o "$OUT"

if [ -f "$OUT" ]; then
  echo "[rmlmapper] UNSUBACK posting triples to GraphDB..."
  curl -sS -X POST \
    -H "Content-Type: text/turtle" \
    --data-binary @"$OUT" \
    "$GDB" >/dev/null
fi