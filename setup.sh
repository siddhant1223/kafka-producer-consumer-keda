#!/bin/bash

# Function to run a command and capture output
run_command() {
    local command="$1"
    echo "Running: $command"
    output=$(eval "$command" 2>&1)
    if [ $? -ne 0 ]; then
        echo "Error: $output"
        exit 1
    fi
    echo "$output"
}

# Function to connect to the Kubernetes cluster
connect_to_cluster() {
    local config_path="$1"
    local context="$2"

    echo "Connecting to cluster..."
    run_command "kubectl config use-context $context"
    echo "Switched context."

    nodes=$(run_command "kubectl get nodes -o json")
    echo "Cluster nodes:"
    echo "$nodes" | jq .
}

# Function to install Helm
install_helm() {
    echo "Installing Helm..."
    run_command "curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"
}

# Function to install KEDA
install_keda() {
    echo "Installing KEDA..."
    run_command "helm repo add kedacore https://kedacore.github.io/charts"
    run_command "helm repo update"
    run_command "helm install keda kedacore/keda --create-namespace --namespace keda"
}

# Function to build Docker image based on architecture
build_docker_image() {
    local dockerfile="$1"
    local image_name="$2"
    local architecture="$3"

    echo "Building Docker image for $architecture..."
    run_command "docker buildx build --file $dockerfile --tag $image_name --platform $architecture ."
}

# Apply a Kubernetes manifest
apply_yaml() {
    local file_path="$1"
    echo "Applying: $file_path"
    run_command "kubectl apply -f $file_path"
}

# Get deployment status
get_deployment_status() {
    local deployment_name="$1"
    local namespace="${2:-default}"
    echo "Checking status for $deployment_name..."
    status_json=$(run_command "kubectl get deployment $deployment_name -n $namespace -o json")
    echo "$status_json" | jq .
}

# Main execution

KUBECONFIG_PATH="~/.kube/config"
KUBE_CONTEXT="my-cluster-context"

connect_to_cluster "$KUBECONFIG_PATH" "$KUBE_CONTEXT"
install_helm
install_keda

# Build Docker images
ARCHITECTURE="linux/amd64"  # Change to match your architecture
PRODUCER_IMAGE="kafka-producer:latest"
CONSUMER_IMAGE="kafka-consumer:latest"

build_docker_image "producer.Dockerfile" "$PRODUCER_IMAGE" "$ARCHITECTURE"
build_docker_image "consumer.Dockerfile" "$CONSUMER_IMAGE" "$ARCHITECTURE"

# Apply Kubernetes manifests
apply_yaml "scaledobject.yaml"
apply_yaml "trigger-authentication.yaml"
apply_yaml "producer_deployment.yaml"
apply_yaml "consumer_deployment.yaml"

# Check the status of deployments
get_deployment_status "kafka-producer" "default"
get_deployment_status "kafka-consumer" "default"

