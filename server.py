from http.server import ThreadingHTTPServer, BaseHTTPRequestHandler


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
        # Optional: cleaner logging without noisy timestamps
        print(f"{self.client_address[0]} requested {self.path}")


if __name__ == "__main__":
    host = "0.0.0.0"
    port = 8080
    server = ThreadingHTTPServer((host, port), SimpleHandler)
    print(f"🚀 Serving on http://{host}:{port}")
    server.serve_forever()
