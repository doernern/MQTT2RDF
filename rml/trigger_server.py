from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from queue import Queue, Full
from threading import Thread
import subprocess
import json
import time

PORT = 8080

jobs = Queue(maxsize=200)

ALLOWED_PACKETS = {
    "connect", "connack", "subscribe", "suback", "unsubscribe", "unsuback",
    "disconnect", "publish", "puback", "pubrec", "pubrel", "pubcomp",
    "pingreq", "pingresp"
}

def worker():
    while True:
        packet = jobs.get()
        start = time.time()
        try:
            result = subprocess.run(
                ["sh", f"/work/control-packets/{packet}.sh"],
                check=False
            )
            dur = time.time() - start
            print(f"[WORKER] packet={packet} rc={result.returncode} dur_s={dur:.3f}")
        finally:
            jobs.task_done()

for _ in range(4):
    Thread(target=worker, daemon=True).start()

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"OK")
            return

        self.send_response(404)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps({
            "status": "error",
            "message": "not found"
        }).encode())

    def do_POST(self):
        parts = self.path.strip("/").split("/")

        if len(parts) != 2 or parts[0] != "map":
            self.send_response(404)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({
                "status": "error",
                "message": "not found"
            }).encode())
            return

        packet = parts[1].lower()

        if packet not in ALLOWED_PACKETS:
            self.send_response(400)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({
                "status": "error",
                "message": f"unknown packet type: {packet}"
            }).encode())
            return

        try:
            jobs.put_nowait(packet)
        except Full:
            self.send_response(503)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({
                "status": "error",
                "message": "queue full"
            }).encode())
            return

        self.send_response(202)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps({
            "status": "queued",
            "packet": packet,
            "queue_size": jobs.qsize()
        }).encode())

    def log_message(self, format, *args):
        return

if __name__ == "__main__":
    server = ThreadingHTTPServer(("0.0.0.0", PORT), Handler)
    print(f"Trigger server running on port {PORT}")
    server.serve_forever()