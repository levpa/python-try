FROM python:3.13-slim-bookworm
WORKDIR /app

COPY src/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
COPY src/ ./src/

EXPOSE 8080
CMD ["python", "src/server.py"]
