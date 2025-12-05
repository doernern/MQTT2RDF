#!/bin/sh
set -eu

echo "[rmlmapper] starting all workers..."

/work/control-packets/publish.sh &
PID_PUBLISH=$!

/work/control-packets/subscribe.sh &
PID_SUBSCRIBE=$!

/work/control-packets/unsubscribe.sh &
PID_UNSUBSCRIBE=$!

/work/control-packets/connect.sh &
PID_CONNECT=$!

/work/control-packets/connack.sh &
PID_CONNACK=$!

/work/control-packets/disconnect.sh &
PID_DISCONNECT=$!

/work/control-packets/suback.sh &
PID_SUBACK=$!

/work/control-packets/unsuback.sh &
PID_UNSUBACK=$!

/work/control-packets/pingreq.sh &
PID_PINGREQ=$!

/work/control-packets/pingresp.sh &
PID_PINGRESP=$!

/work/control-packets/auth.sh &
PID_AUTH=$!

/work/control-packets/puback.sh &
PID_PUBACK=$!

/work/control-packets/pubrel.sh &
PID_PUBREL=$!

/work/control-packets/pubrec.sh &
PID_PUBREC=$!

/work/control-packets/pubcomp.sh &
PID_PUBCOMP=$!

echo "[rmlmapper] workers up:"
echo "  publish   pid=$PID_PUBLISH"
echo "  subscribe pid=$PID_SUBSCRIBE"
echo "  unsubscribe   pid=$PID_UNSUBSCRIBE"
echo "  connect pid=$PID_CONNECT"
echo "  connack   pid=$PID_CONNACK"
echo "  disconnect pid=$PID_DISCONNECT"
echo "  suback pid=$PID_SUBACK"
echo "  unsuback pid=$PID_UNSUBACK"
echo "  pingreq pid=$PID_PINGREQ"
echo "  pingresp pid=$PID_PINGRESP"
echo "  auth pid=$PID_AUTH"
echo "  puback pid=$PID_PUBACK"
echo "  pubrel pid=$PID_PUBREL"
echo "  pubrec pid=$PID_PUBREC"
echo "  pubcomp pid=$PID_PUBCOMP"

wait
echo "[rmlmapper] a worker exited -> stopping container."
exit 1
