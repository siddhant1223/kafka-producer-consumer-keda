from kafka import KafkaConsumer
import time
import json

# Kafka consumer configuration
bootstrap_servers = 'your-kafka-bootstrap-server'
topic = 'keda-demo-topic'
group_id = 'my-kafka-consumer-group'

# Initialize Kafka consumer
consumer = KafkaConsumer(
    topic,
    group_id=group_id,
    bootstrap_servers=[bootstrap_servers],
    value_deserializer=lambda m: json.loads(m.decode('utf-8'))
)

def consume_message():
    for message in consumer:
        print(f"Consumed message: {message.value}")
        time.sleep(random.uniform(0.5, 2.0))  # Simulate lag by adding a random delay

if __name__ == "__main__":
    consume_message()

