#!/bin/sh
set -u

PACKET="$1"
FILENAME="$2"

IN_UNIQUE="/work/data/in/${FILENAME}"
IN_CANONICAL="/work/data/in/${PACKET}.json"
OUT_BASENAME="${FILENAME%.json}"
OUT="/work/data/out/${OUT_BASENAME}.ttl"
MAP="/work/control-packets/${PACKET}.ttl"
LOCKDIR="/tmp/lock-${PACKET}"
GDB="http://graphdb:7200/repositories/mqtt4ssn/statements"
MAP_RUNTIME="/work/data/map_runtime.json"

now_ms() {
  date +%s%3N
}

start_total_ms="$(now_ms)"
mapping_ms=0
graphdb_post_ms=0
status="unknown"
error=""

log_runtime() {
  end_total_ms="$(now_ms)"
  shell_total_ms=$((end_total_ms - start_total_ms))

  printf '{"packet":"%s","filename":"%s","status":"%s","error":"%s","mapping_ms":%s,"graphdb_post_ms":%s,"shell_total_ms":%s}\n' \
    "$PACKET" "$FILENAME" "$status" "$error" "$mapping_ms" "$graphdb_post_ms" "$shell_total_ms" >> "$MAP_RUNTIME"
}

cleanup() {
  rm -f "$IN_CANONICAL" "$OUT"
  rmdir "$LOCKDIR" 2>/dev/null || true
}

trap 'log_runtime; cleanup' EXIT INT TERM

echo "[INFO] Processing packet=$PACKET file=$FILENAME"

if [ ! -f "$IN_UNIQUE" ]; then
  status="error"
  error="input_not_found"
  exit 1
fi

while ! mkdir "$LOCKDIR" 2>/dev/null; do
  sleep 1
done

cp "$IN_UNIQUE" "$IN_CANONICAL"

start_mapping_ms="$(now_ms)"
if ! java -jar /rmlmapper.jar -m "$MAP" -o "$OUT"; then
  end_mapping_ms="$(now_ms)"
  mapping_ms=$((end_mapping_ms - start_mapping_ms))
  status="error"
  error="rmlmapper_failed"
  exit 1
fi
end_mapping_ms="$(now_ms)"
mapping_ms=$((end_mapping_ms - start_mapping_ms))

if [ ! -s "$OUT" ]; then
  status="error"
  error="empty_output"
  exit 1
fi

start_graphdb_ms="$(now_ms)"
if ! curl -sS --fail \
  -H "Content-Type: text/turtle" \
  --data-binary @"$OUT" \
  "$GDB" > /dev/null; then
  end_graphdb_ms="$(now_ms)"
  graphdb_post_ms=$((end_graphdb_ms - start_graphdb_ms))
  status="error"
  error="graphdb_post_failed"
  exit 1
fi
end_graphdb_ms="$(now_ms)"
graphdb_post_ms=$((end_graphdb_ms - start_graphdb_ms))

rm -f "$IN_UNIQUE"

status="ok"
error=""

echo "[OK] Done packet=$PACKET file=$FILENAME mapping_ms=$mapping_ms graphdb_post_ms=$graphdb_post_ms"