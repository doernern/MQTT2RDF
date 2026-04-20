#!/bin/sh
set -eu

PACKET="$1"

IN="/work/data/in/${PACKET}.json"
OUT="/work/data/out/${PACKET}.ttl"
MAP="/work/control-packets/${PACKET}.ttl"

GDB="http://graphdb:7200/repositories/mqtt4ssn/statements"

echo "[INFO] Processing $PACKET"

[ -f "$IN" ] || {
  echo "[WARN] Input not found: $IN"
  exit 0
}

java -jar /rmlmapper.jar -m "$MAP" -o "$OUT"

[ -s "$OUT" ] || {
  echo "[WARN] Empty output for $PACKET"
  exit 0
}

curl -sS --fail \
  -H "Content-Type: text/turtle" \
  --data-binary @"$OUT" \
  "$GDB" > /dev/null

echo "[OK] Done $PACKET"