#!/bin/sh
set -eu

IN=/work/data/in/disconnect.json
OUT=/work/data/out/disconnect.ttl
M=/work/control-packets/disconnect.ttl
GDB=http://graphdb:7200/repositories/mqtt4ssn/statements

if [ ! -f "$IN" ]; then
  echo "[rmlmapper] DISCONNECT skipped, input missing: $IN"
  exit 0
fi

echo "[rmlmapper] DISCONNECT mapping once..."
java -jar /rmlmapper.jar -m "$M" -o "$OUT"

if [ -f "$OUT" ]; then
  echo "[rmlmapper] DISCONNECT posting triples to GraphDB..."
  curl -sS -X POST \
    -H "Content-Type: text/turtle" \
    --data-binary @"$OUT" \
    "$GDB" >/dev/null
fi