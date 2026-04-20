#!/bin/sh
set -eu

IN=/work/data/in/auth.json
OUT=/work/data/out/auth.ttl
M=/work/control-packets/auth.ttl
GDB=http://graphdb:7200/repositories/mqtt4ssn/statements

if [ ! -f "$IN" ]; then
  echo "[rmlmapper] AUTH skipped, input missing: $IN"
  exit 0
fi

echo "[rmlmapper] AUTH mapping once..."
java -jar /rmlmapper.jar -m "$M" -o "$OUT"

if [ -f "$OUT" ]; then
  echo "[rmlmapper] AUTH posting triples to GraphDB..."
  curl -sS -X POST \
    -H "Content-Type: text/turtle" \
    --data-binary @"$OUT" \
    "$GDB" >/dev/null
fi