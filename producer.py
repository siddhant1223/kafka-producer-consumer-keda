from kafka import KafkaProducer
import time
import random
import json

# Kafka producer configuration
bootstrap_servers = 'host.docker.internal:9092'
topic = 'keda-demo-topic'

# Initialize Kafka producer
producer = KafkaProducer(
    bootstrap_servers=[bootstrap_servers],
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

def produce_message():
    while True:
        message = {
            "timestamp": time.time(),
            "random_value": random.randint(0, 100)
        }
        producer.send(topic, message)
        print(f"Produced message: {message}")
        time.sleep(0.1)  # simulate a message every 100ms

if __name__ == "__main__":
    produce_message()

