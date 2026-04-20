from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import subprocess
import sys

ALLOWED = {
    "connect", "connack", "publish", "puback", "pubrec", "pubrel", "pubcomp",
    "subscribe", "suback", "unsubscribe", "unsuback",
    "pingreq", "pingresp", "disconnect", "auth"
}

class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        parts = self.path.strip("/").split("/")
        if len(parts) != 2 or parts[0] != "map":
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"not found")
            return

        packet = parts[1].lower()
        if packet not in ALLOWED:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(f"invalid packet type: {packet}".encode())
            return

        script = f"/work/control-packets/{packet}.sh"

        try:
            print(f"[rmlmapper] triggering {script}", flush=True)

            result = subprocess.run(
                ["sh", script],
                capture_output=True,
                text=True,
                timeout=120
            )

            if result.stdout:
                print(result.stdout, end="", flush=True)
            if result.stderr:
                print(result.stderr, end="", file=sys.stderr, flush=True)

            body = {
                "packet": packet,
                "returncode": result.returncode,
                "stdout": result.stdout,
                "stderr": result.stderr
            }

            self.send_response(200 if result.returncode == 0 else 500)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(body).encode())

        except Exception as e:
            print(f"[rmlmapper] trigger error: {e}", file=sys.stderr, flush=True)
            self.send_response(500)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"error": str(e)}).encode())

    def log_message(self, format, *args):
        return

if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", 8080), Handler)
    print("[rmlmapper] trigger server listening on :8080", flush=True)
    server.serve_forever()