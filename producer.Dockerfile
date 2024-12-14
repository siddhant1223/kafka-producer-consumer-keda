# Dockerfile for Kafka producer
FROM python:3.9-slim

RUN apt-get update && apt-get install -y \
    gcc \
    libffi-dev \
    python3-dev \
    librdkafka-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*  # Clean up apt cache


WORKDIR /app
COPY requirements.txt /app/

RUN pip install --no-cache-dir -r requirements.txt

COPY producer.py /app/

CMD ["python", "producer.py"]

