from http.server import ThreadingHTTPServer, BaseHTTPRequestHandler
import sys
import requests

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/favicon.ico":
            self.send_response(204)  # No Content
            self.end_headers()
            return

        self.send_response(200)
        self.send_header("Content-type", "text/plain; charset=utf-8")
        self.end_headers()
        self.wfile.write(b"Hello from Python 3.12 HTTP server!")

    def log_message(self, format, *args):
        # Cleaner logging to stderr for Docker visibility
        print(f"{self.client_address[0]} requested {self.path}", file=sys.stderr)

response = requests.get("https://api.github.com")
try:
    data = response.json()
    print("✅ JSON detected:", data)
except ValueError:
    print("❌ Not JSON. Content-Type:", response.headers.get("Content-Type"))

if __name__ == "__main__":
    host = "0.0.0.0"
    port = 8080
    print(f"🚀 Serving on http://{host}:{port}", file=sys.stderr)
    server = ThreadingHTTPServer((host, port), SimpleHandler)
    server.serve_forever()
