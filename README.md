Here's a `README.md` that explains the purpose and details of the files inside the directory:

---

# Kafka Producer-Consumer with KEDA and SASL Authentication

This project sets up a Kafka producer-consumer system using Kubernetes, Helm, KEDA (Kubernetes Event-Driven Autoscaling), and SASL authentication. The goal is to demonstrate how to deploy a Kafka producer and consumer with automated scaling based on workload.

## Project Structure

This directory contains several files that are used to configure and deploy the Kafka system:

### 1. **Dockerfiles**
- **`producer.Dockerfile`**: Builds a Docker image for the Kafka producer. The image includes Python and the necessary libraries to run the producer script.
- **`consumer.Dockerfile`**: Builds a Docker image for the Kafka consumer. This image also includes Python and the necessary dependencies to run the consumer script.
- **`python-kafka.Dockerfile`**: A helper Dockerfile that could be used for custom configurations, or for shared dependencies between the producer and consumer.

### 2. **Python Scripts**
- **`producer.py`**: A Python script that sends random messages to a Kafka topic (`test`) every 100ms. It uses `kafka-python` to connect to the Kafka broker using SASL authentication.
- **`consumer.py`**: A Python script that consumes messages from the Kafka `test` topic. It listens to the messages and prints them every 10 seconds. Like the producer, it uses SASL for authentication.

### 3. **Kubernetes Configurations**
- **`scaledobject.yaml`**: Defines a KEDA ScaledObject that triggers the scaling of the Kafka consumer based on the message queue length. This ensures that the consumer can scale up or down based on demand.
- **`trigger-authentication.yaml`**: Configures the trigger authentication for KEDA. This file ensures that KEDA can authenticate with Kafka using SASL when scaling the consumer.
- **`producer_deployment.yaml`**: Defines the Kubernetes deployment for the Kafka producer. It specifies the Docker image, environment variables, resource requests, and limits.
- **`consumer_deployment.yaml`**: Defines the Kubernetes deployment for the Kafka consumer, similar to the producer deployment, but scaled based on the KEDA ScaledObject.
- **`secret.yaml`**: Contains the Kubernetes secret with the SASL credentials for authenticating with Kafka (username and password).
- **`kafka_secret.yaml`**: Contains the Kafka-specific credentials (username and password) used for connecting to the Kafka broker with SASL authentication.

### 4. **Requirements**
- **`requirements.txt`**: Lists the necessary Python packages for running both the Kafka producer and consumer, such as `kafka-python` and others. These are installed when building the Docker image.

### 5. **Shell Script**
- **`setup.sh`**: A bash script that automates the following:
  - Connects to the Kubernetes cluster.
  - Installs Helm and KEDA.
  - Builds Docker images for the Kafka producer and consumer (for the specified architecture).
  - Applies the Kubernetes YAML files in the correct order (`scaledobject.yaml`, `trigger-authentication.yaml`, `producer_deployment.yaml`, `consumer_deployment.yaml`).
  - Checks the status of the deployments.

### How It Works

1. **Kafka Producer**: The producer sends random JSON messages to a Kafka topic (`test`) every 100ms. The producer authenticates with the Kafka broker using SASL authentication via the `client.properties` file.

2. **Kafka Consumer**: The consumer listens to the same Kafka topic and prints consumed messages. The consumer also uses SASL authentication to connect securely to Kafka.

3. **KEDA**: The KEDA ScaledObject monitors the `test` topic and automatically scales the consumer based on the number of messages in the topic. If the queue is too long, KEDA will scale up the consumer deployment to handle the load.

4. **SASL Authentication**: Both the producer and consumer use SASL for authenticating with Kafka, which ensures secure communication. The credentials are stored in Kubernetes secrets, and KEDA uses these credentials when scaling the consumer.

### Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-repository/kafka-producer-consumer-keda.git
   cd kafka-producer-consumer-keda
   ```

2. **Install dependencies**:
   - Make sure Docker and Kubernetes are installed on your local machine.
   - Build the Docker images for the producer and consumer:
     ```bash
     docker build -f producer.Dockerfile -t kafka-producer .
     docker build -f consumer.Dockerfile -t kafka-consumer .
     ```

3. **Run the setup script**:
   The `setup.sh` script will:
   - Connect to the Kubernetes cluster.
   - Install Helm and KEDA.
   - Build Docker images for the producer and consumer.
   - Apply the Kubernetes YAML files.
   - Check the status of the deployments.
   ```bash
   ./setup.sh
   ```

4. **Verify deployments**:
   Once the script finishes, verify the deployments are running:
   ```bash
   kubectl get pods
   kubectl get deployments
   kubectl get scaledobject
   ```

5. **Test the system**:
   - The producer will start sending messages to Kafka.
   - The consumer will start consuming those messages.
   - KEDA will automatically scale the consumer based on the queue length in Kafka.

### Troubleshooting

- **Kubernetes Connection Issues**: Make sure your `kubectl` is configured correctly to connect to your Kubernetes cluster.
- **Docker Build Failures**: Ensure Docker is running and the Dockerfiles are correct. If you're on a different architecture (e.g., ARM), modify the `Dockerfile` or the build platform.
- **KEDA Scaling Issues**: Check the KEDA metrics and logs to see if there’s an issue with autoscaling:
  ```bash
  kubectl logs -l app=keda-operator -n keda
  ```

---

This README explains the project structure, how each part works, and the steps to get everything running. It provides enough information for someone unfamiliar with the project to get started and troubleshoot common issues.
