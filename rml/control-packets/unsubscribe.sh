#!/bin/sh
set -eu

IN=/work/data/in/unsubscribe.json
OUT=/work/data/out/unsubscribe.ttl
M=/work/control-packets/unsubscribe.ttl
GDB=http://graphdb:7200/repositories/mqtt4ssn/statements

if [ ! -f "$IN" ]; then
  echo "[rmlmapper] UNSUBSCRIBE skipped, input missing: $IN"
  exit 0
fi

echo "[rmlmapper] UNSUBSCRIBE mapping once..."
java -jar /rmlmapper.jar -m "$M" -o "$OUT"

if [ -f "$OUT" ]; then
  echo "[rmlmapper] UNSUBSCRIBE posting triples to GraphDB..."
  curl -sS -X POST \
    -H "Content-Type: text/turtle" \
    --data-binary @"$OUT" \
    "$GDB" >/dev/null
fi