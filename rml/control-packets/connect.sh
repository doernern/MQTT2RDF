#!/bin/sh
set -eu

IN=/work/data/in/connect.json
OUT=/work/data/out/connect.ttl
M=/work/control-packets/connect.ttl
GDB=http://graphdb:7200/repositories/mqtt4ssn/statements

if [ ! -f "$IN" ]; then
  echo "[rmlmapper] CONNECT skipped, input missing: $IN"
  exit 0
fi

echo "[rmlmapper] CONNECT mapping once..."
java -jar /rmlmapper.jar -m "$M" -o "$OUT"

if [ -f "$OUT" ]; then
  echo "[rmlmapper] CONNECT posting triples to GraphDB..."
  curl -sS -X POST \
    -H "Content-Type: text/turtle" \
    --data-binary @"$OUT" \
    "$GDB" >/dev/null
fi