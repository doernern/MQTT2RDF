#!/bin/sh
set -eu

PACKET="$1"
FILENAME="$2"

IN_UNIQUE="/work/data/in/${FILENAME}"
IN_CANONICAL="/work/data/in/${PACKET}.json"
OUT_BASENAME="${FILENAME%.json}"
OUT="/work/data/out/${OUT_BASENAME}.ttl"
MAP="/work/control-packets/${PACKET}.ttl"
LOCKDIR="/tmp/lock-${PACKET}"

GDB="http://graphdb:7200/repositories/mqtt4ssn/statements"

start_ts="$(date +%s)"

echo "[INFO] Processing packet=$PACKET file=$FILENAME"

[ -f "$IN_UNIQUE" ] || {
  echo "[WARN] Input not found: $IN_UNIQUE"
  exit 0
}

cleanup() {
  rm -f "$IN_CANONICAL" "$OUT"
  rmdir "$LOCKDIR" 2>/dev/null || true
}

while ! mkdir "$LOCKDIR" 2>/dev/null; do
  sleep 1
done

trap cleanup EXIT INT TERM

cp "$IN_UNIQUE" "$IN_CANONICAL"

java -jar /rmlmapper.jar -m "$MAP" -o "$OUT"

[ -s "$OUT" ] || {
  echo "[WARN] Empty output for packet=$PACKET file=$FILENAME"
  rm -f "$IN_UNIQUE"
  exit 0
}

curl -sS --fail \
  -H "Content-Type: text/turtle" \
  --data-binary @"$OUT" \
  "$GDB" > /dev/null

rm -f "$IN_UNIQUE"

end_ts="$(date +%s)"
echo "[OK] Done packet=$PACKET file=$FILENAME dur_s=$((end_ts-start_ts))"