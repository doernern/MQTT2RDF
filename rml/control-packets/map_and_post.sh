#!/bin/sh
set -eu

PACKET="$1"
IN="/work/data/in/${PACKET}.json"
OUT="/work/data/out/${PACKET}.ttl"
MAP="/work/control-packets/${PACKET}.ttl"
GDB="http://graphdb:7200/repositories/mqtt4ssn/statements"

start_ts="$(date +%s)"

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

end_ts="$(date +%s)"
echo "[OK] Done $PACKET dur_s=$((end_ts-start_ts))"