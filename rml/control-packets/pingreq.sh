#!/bin/sh
set -eu

IN=/work/data/in/pingreq.json
OUT=/work/data/out/pingreq.ttl
M=/work/control-packets/pingreq.ttl
GDB=http://graphdb:7200/repositories/mqtt4ssn/statements

if [ ! -f "$IN" ]; then
  echo "[rmlmapper] PINGREQ skipped, input missing: $IN"
  exit 0
fi

echo "[rmlmapper] PINGREQ mapping once..."
java -jar /rmlmapper.jar -m "$M" -o "$OUT"

if [ -f "$OUT" ]; then
  echo "[rmlmapper] PINGREQ posting triples to GraphDB..."
  curl -sS -X POST \
    -H "Content-Type: text/turtle" \
    --data-binary @"$OUT" \
    "$GDB" >/dev/null
fi