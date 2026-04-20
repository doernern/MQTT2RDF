#!/bin/sh
set -eu

IN=/work/data/in/pubcomp.json
OUT=/work/data/out/pubcomp.ttl
M=/work/control-packets/pubcomp.ttl
GDB=http://graphdb:7200/repositories/mqtt4ssn/statements

if [ ! -f "$IN" ]; then
  echo "[rmlmapper] PUBCOMP skipped, input missing: $IN"
  exit 0
fi

echo "[rmlmapper] PUBCOMP mapping once..."
java -jar /rmlmapper.jar -m "$M" -o "$OUT"

if [ -f "$OUT" ]; then
  echo "[rmlmapper] PUBCOMP posting triples to GraphDB..."
  curl -sS -X POST \
    -H "Content-Type: text/turtle" \
    --data-binary @"$OUT" \
    "$GDB" >/dev/null
fi