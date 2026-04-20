#!/bin/sh
set -eu

IN=/work/data/in/pubrel.json
OUT=/work/data/out/pubrel.ttl
M=/work/control-packets/pubrel.ttl
GDB=http://graphdb:7200/repositories/mqtt4ssn/statements

if [ ! -f "$IN" ]; then
  echo "[rmlmapper] PUBREL skipped, input missing: $IN"
  exit 0
fi

echo "[rmlmapper] PUBREL mapping once..."
java -jar /rmlmapper.jar -m "$M" -o "$OUT"

if [ -f "$OUT" ]; then
  echo "[rmlmapper] PUBREL posting triples to GraphDB..."
  curl -sS -X POST \
    -H "Content-Type: text/turtle" \
    --data-binary @"$OUT" \
    "$GDB" >/dev/null
fi