#!/bin/bash

# Solar System Microservice Deployment Script
# This script automates the deployment process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
REGION="us-west-2"
CLUSTER_NAME="stage-eks-cluster"
DOCKER_USERNAME=""
ACTION="deploy"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if required tools are installed
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    command -v terraform >/dev/null 2>&1 || { print_error "Terraform is required but not installed. Aborting."; exit 1; }
    command -v kubectl >/dev/null 2>&1 || { print_error "kubectl is required but not installed. Aborting."; exit 1; }
    command -v aws >/dev/null 2>&1 || { print_error "AWS CLI is required but not installed. Aborting."; exit 1; }
    command -v docker >/dev/null 2>&1 || { print_error "Docker is required but not installed. Aborting."; exit 1; }
    
    print_status "All prerequisites are installed."
}

# Function to generate SSH key if it doesn't exist
generate_ssh_key() {
    if [ ! -f "./terraform/id_rsa" ]; then
        print_status "Generating SSH key pair..."
        ssh-keygen -t rsa -b 4096 -f ./terraform/id_rsa -N ""
        chmod 600 ./terraform/id_rsa
        chmod 644 ./terraform/id_rsa.pub
    else
        print_status "SSH key pair already exists."
    fi
}

# Function to deploy infrastructure
deploy_infrastructure() {
    print_status "Deploying infrastructure with Terraform..."
    
    cd terraform
    
    # Initialize Terraform
    terraform init
    
    # Validate configuration
    terraform validate
    
    # Plan deployment
    terraform plan -out=tfplan
    
    # Apply configuration
    terraform apply -auto-approve tfplan
    
    cd ..
    
    print_status "Infrastructure deployment completed."
}

# Function to build and push Docker image
build_and_push_image() {
    if [ -z "$DOCKER_USERNAME" ]; then
        print_error "Docker username not provided. Use -u flag or set DOCKER_USERNAME environment variable."
        exit 1
    fi
    
    print_status "Building Docker image..."
    docker build -t ${DOCKER_USERNAME}/solar-system:latest .
    
    print_status "Pushing Docker image..."
    docker push ${DOCKER_USERNAME}/solar-system:latest
    
    # Update deployment.yaml with the correct image
    sed -i.bak "s|image: .*|image: ${DOCKER_USERNAME}/solar-system:latest|" k8s/deployment.yaml
    
    print_status "Docker image built and pushed successfully."
}

# Function to configure kubectl
configure_kubectl() {
    print_status "Configuring kubectl..."
    aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME
    
    # Test connection
    kubectl cluster-info
    print_status "kubectl configured successfully."
}

# Function to deploy to Kubernetes
deploy_to_kubernetes() {
    print_status "Deploying to Kubernetes..."
    
    # Apply Kubernetes manifests
    kubectl apply -f k8s/deployment.yaml
    kubectl apply -f k8s/service.yaml
    
    # Wait for deployment to be ready
    print_status "Waiting for deployment to be ready..."
    kubectl rollout status deployment/deployment1 --timeout=300s
    
    print_status "Kubernetes deployment completed."
}

# Function to get service information
get_service_info() {
    print_status "Getting service information..."
    
    echo "Deployments:"
    kubectl get deployments
    
    echo ""
    echo "Services:"
    kubectl get services
    
    echo ""
    echo "Pods:"
    kubectl get pods
    
    # Wait for LoadBalancer
    print_status "Waiting for LoadBalancer to be ready..."
    EXTERNAL_IP=""
    while [ -z $EXTERNAL_IP ]; do
        print_status "Waiting for external IP..."
        EXTERNAL_IP=$(kubectl get svc microservice-svc --template="{{range .status.loadBalancer.ingress}}{{.hostname}}{{.ip}}{{end}}")
        [ -z "$EXTERNAL_IP" ] && sleep 10
    done
    
    print_status "Application is available at: http://$EXTERNAL_IP"
}

# Function to destroy infrastructure
destroy_infrastructure() {
    print_warning "This will destroy all infrastructure. Are you sure? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_status "Destroying Kubernetes resources..."
        kubectl delete -f k8s/ || true
        
        print_status "Destroying infrastructure..."
        cd terraform
        terraform destroy -auto-approve
        cd ..
        
        print_status "Infrastructure destroyed."
    else
        print_status "Destruction cancelled."
    fi
}

# Function to show usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -a, --action ACTION     Action to perform (deploy|destroy) [default: deploy]"
    echo "  -u, --docker-user USER  Docker Hub username"
    echo "  -r, --region REGION     AWS region [default: us-west-2]"
    echo "  -c, --cluster NAME      EKS cluster name [default: stage-eks-cluster]"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -u myusername                    # Deploy with Docker Hub username"
    echo "  $0 -a destroy                       # Destroy infrastructure"
    echo "  $0 -u myusername -r us-east-1       # Deploy in us-east-1 region"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--action)
            ACTION="$2"
            shift 2
            ;;
        -u|--docker-user)
            DOCKER_USERNAME="$2"
            shift 2
            ;;
        -r|--region)
            REGION="$2"
            shift 2
            ;;
        -c|--cluster)
            CLUSTER_NAME="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    print_status "Starting Solar System Microservice deployment..."
    print_status "Action: $ACTION"
    print_status "Region: $REGION"
    print_status "Cluster: $CLUSTER_NAME"
    
    check_prerequisites
    
    if [ "$ACTION" = "deploy" ]; then
        generate_ssh_key
        deploy_infrastructure
        
        if [ -n "$DOCKER_USERNAME" ]; then
            build_and_push_image
        else
            print_warning "Docker username not provided. Skipping image build."
            print_warning "Make sure the image in k8s/deployment.yaml is correct."
        fi
        
        configure_kubectl
        deploy_to_kubernetes
        get_service_info
        
        print_status "Deployment completed successfully!"
        
    elif [ "$ACTION" = "destroy" ]; then
        destroy_infrastructure
        
    else
        print_error "Invalid action: $ACTION. Use 'deploy' or 'destroy'."
        exit 1
    fi
}

# Run main function
main "$@"
