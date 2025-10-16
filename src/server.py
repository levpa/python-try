from http.server import ThreadingHTTPServer, BaseHTTPRequestHandler
import sys
import time
import platform

try:
    from version import VERSION, COMMIT, BUILD_DATE
except ImportError:
    VERSION = COMMIT = BUILD_DATE = "unknown"

PYTHON_VERSION = platform.python_version()

print(f"\nVersion: {VERSION}, Commit: {COMMIT}, Built: {BUILD_DATE}\n")
print(f"Running on Python {PYTHON_VERSION}\n")
sys.stdout.flush()

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        start = time.time()
        client_ip = self.client_address[0]
        path = self.path

        print(f"{client_ip} requested {path}", file=sys.stderr)

        if path == "/favicon.ico":
            self.send_response(204)
            self.end_headers()
            return

        self.send_response(200)
        self.send_header("Content-type", "text/plain; charset=utf-8")
        self.end_headers()
        self.wfile.write(f"Hello from Python {PYTHON_VERSION} HTTP server!\n".encode("utf-8"))

        duration = time.time() - start
        print(f"⏱️ Served {path} in {duration:.3f}s", file=sys.stderr)

    def log_message(self, format, *args):
        return

if __name__ == "__main__":
    host = "0.0.0.0"
    port = 8080
    print(f"🚀 Serving on http://{host}:{port}", file=sys.stderr)
    server = ThreadingHTTPServer((host, port), SimpleHandler)
    server.serve_forever()
