#!/bin/sh
set -eu

IN=/work/data/in/publish.json
OUT=/work/data/out/publish.ttl
M=/work/control-packets/publish.ttl
GDB=http://graphdb:7200/repositories/mqtt4ssn/statements

if [ ! -f "$IN" ]; then
  echo "[rmlmapper] PUBLISH skipped, input missing: $IN"
  exit 0
fi

echo "[rmlmapper] PUBLISH mapping once..."
java -jar /rmlmapper.jar -m "$M" -o "$OUT"

if [ -f "$OUT" ]; then
  echo "[rmlmapper] PUBLISH posting triples to GraphDB..."
  curl -sS -X POST \
    -H "Content-Type: text/turtle" \
    --data-binary @"$OUT" \
    "$GDB" >/dev/null
fi