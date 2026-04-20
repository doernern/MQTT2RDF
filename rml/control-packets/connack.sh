#!/bin/sh
set -eu

IN=/work/data/in/connack.json
OUT=/work/data/out/connack.ttl
M=/work/control-packets/connack.ttl
GDB=http://graphdb:7200/repositories/mqtt4ssn/statements

if [ ! -f "$IN" ]; then
  echo "[rmlmapper] CONNACK skipped, input missing: $IN"
  exit 0
fi

echo "[rmlmapper] CONNACK mapping once..."
java -jar /rmlmapper.jar -m "$M" -o "$OUT"

if [ -f "$OUT" ]; then
  echo "[rmlmapper] CONNACK posting triples to GraphDB..."
  curl -sS -X POST \
    -H "Content-Type: text/turtle" \
    --data-binary @"$OUT" \
    "$GDB" >/dev/null
fi