#!/bin/sh
set -eu

IN=/work/data/in/pubcomp.json
OUT=/work/data/out/pubcomp.ttl
M=/work/control-packets/pubcomp.ttl
GDB=http://graphdb:7200/repositories/mqtt4ssn/statements

last=""
echo "[rmlmapper] watching $IN ..."
while true; do
  if [ -f "$IN" ]; then
    now="$(stat -c %Y "$IN" 2>/dev/null || echo 0)"
    if [ "$now" != "$last" ]; then
      echo "[rmlmapper] change detected, mapping..."
      # run mapping
      java -jar /rmlmapper.jar -m "$M" -o "$OUT"
      # push to GraphDB (create repo 'mqtt4ssn' first in Workbench)
      if [ -f "$OUT" ]; then
        echo "[rmlmapper] posting triples to GraphDB..."
        curl -sS -X POST \
          -H "Content-Type: text/turtle" \
          --data-binary @"$OUT" \
          "$GDB" >/dev/null || true
      fi
      last="$now"
    fi
  fi
  sleep 3
done
