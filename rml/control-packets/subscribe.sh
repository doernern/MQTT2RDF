#!/bin/sh
set -eu

IN=/work/data/in/subscribe.json
OUT=/work/data/out/subscribe.ttl
M=/work/control-packets/subscribe.ttl
GDB=http://graphdb:7200/repositories/mqtt4ssn/statements

if [ ! -f "$IN" ]; then
  echo "[rmlmapper] SUBSCRIBE skipped, input missing: $IN"
  exit 0
fi

echo "[rmlmapper] SUBSCRIBE mapping once..."
java -jar /rmlmapper.jar -m "$M" -o "$OUT"

if [ -f "$OUT" ]; then
  echo "[rmlmapper] SUBSCRIBE posting triples to GraphDB..."
  curl -sS -X POST \
    -H "Content-Type: text/turtle" \
    --data-binary @"$OUT" \
    "$GDB" >/dev/null
fi