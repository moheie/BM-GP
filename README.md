# 🌟 Solar System Microservice

A cloud-native Node.js microservice showcasing the Solar System, deployed on AWS EKS with complete infrastructure automation using Terraform and CI/CD pipeline with GitHub Actions.

## 🚀 Features

- **Interactive Solar System**: Web application displaying planets and solar system information
- **Cloud-Native Architecture**: Containerized with Docker, deployed on Kubernetes
- **Infrastructure as Code**: Complete AWS infrastructure automation with Terraform
- **CI/CD Pipeline**: Automated build, test, and deployment with GitHub Actions
- **Production Ready**: Health checks, monitoring, and scaling capabilities
- **Security**: Non-root container, security groups, and best practices

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │───▶│  GitHub Actions │───▶│   Docker Hub    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Terraform     │───▶│   AWS EKS      │───▶│  LoadBalancer   │
│  Infrastructure │    │   Cluster      │    │   (Internet)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📋 Prerequisites

- **AWS Account** with appropriate permissions
- **Docker Hub Account** for container registry
- **GitHub Repository** with secrets configured
- **Local Tools** (for manual deployment):
  - AWS CLI
  - Terraform (>= 1.5)
  - kubectl
  - Docker

## ⚙️ Setup

### 1. GitHub Secrets Configuration

Add the following secrets to your GitHub repository (`Settings > Secrets and variables > Actions`):

```
AWS_ACCESS_KEY_ID      = your_aws_access_key
AWS_SECRET_ACCESS_KEY  = your_aws_secret_key
DOCKERHUB_USERNAME     = your_dockerhub_username
DOCKERHUB_PASSWORD     = your_dockerhub_password
```

### 2. Configuration

Update the configuration in `terraform/terraform.tfvars`:

```hcl
region = "us-west-2"
vpc_cidr = "10.0.0.0/16"
public_key_path = "./id_rsa.pub"
cluster_name = "stage-eks-cluster"
node_desired_capacity = 2
node_max_capacity = 4
node_min_capacity = 1
```

## 🚀 Deployment Options

### Option 1: Automated Deployment (Recommended)

**Using GitHub Actions:**
1. Push to `main` branch to trigger automatic deployment
2. Or manually trigger via `Actions` tab with "Run workflow"

### Option 2: Manual Deployment

**Using PowerShell (Windows):**
```powershell
.\scripts\deploy.ps1 -DockerUsername your_username
```

**Using Bash (Linux/Mac):**
```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh -u your_username
```

### Option 3: Step-by-Step Manual Deployment

1. **Generate SSH Key:**
   ```bash
   cd terraform
   ssh-keygen -t rsa -b 4096 -f ./id_rsa -N ""
   ```

2. **Deploy Infrastructure:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. **Build and Push Docker Image:**
   ```bash
   docker build -t your_username/solar-system:latest .
   docker push your_username/solar-system:latest
   ```

4. **Update Kubernetes Manifest:**
   Update the image in `k8s/deployment.yaml`

5. **Configure kubectl:**
   ```bash
   aws eks update-kubeconfig --region us-west-2 --name stage-eks-cluster
   ```

6. **Deploy to Kubernetes:**
   ```bash
   kubectl apply -f k8s/deployment.yaml
   kubectl apply -f k8s/service.yaml
   ```

## 📊 Application Endpoints

Once deployed, access your application:

- **Main App**: `http://<loadbalancer-url>/`
- **Health Check**: `http://<loadbalancer-url>/live`
- **Ready Check**: `http://<loadbalancer-url>/ready`
- **System Info**: `http://<loadbalancer-url>/os`

## 🔍 Monitoring & Management

### Check Deployment Status
```bash
kubectl get all
kubectl get pods
kubectl get services
```

### View Application Logs
```bash
kubectl logs -l app=microservice
```

### Scale Application
```bash
kubectl scale deployment deployment1 --replicas=6
```

### Get LoadBalancer URL
```bash
kubectl get svc microservice-svc
```

## 🛠️ Troubleshooting

### Common Issues

1. **Pods not starting**: Check image availability and resource limits
2. **LoadBalancer timeout**: Wait 5-10 minutes for AWS provisioning
3. **Access denied**: Verify AWS credentials and permissions

### Debug Commands
```bash
# Describe resources
kubectl describe deployment deployment1
kubectl describe service microservice-svc

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# Check cluster info
kubectl cluster-info
kubectl get nodes
```

## 🧹 Cleanup

### Destroy All Resources

**Using Scripts:**
```bash
# PowerShell
.\scripts\deploy.ps1 -Action destroy

# Bash
./scripts/deploy.sh -a destroy
```

**Manual Cleanup:**
```bash
# Delete Kubernetes resources
kubectl delete -f k8s/

# Destroy infrastructure
cd terraform
terraform destroy
```

## 🔧 Customization

### Environment Variables
Modify `k8s/deployment.yaml` to add environment variables:
```yaml
env:
- name: NODE_ENV
  value: "production"
- name: CUSTOM_VAR
  value: "custom_value"
```

### Resource Limits
Adjust resources in `k8s/deployment.yaml`:
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### Infrastructure Changes
Modify `terraform/terraform.tfvars` and apply changes:
```bash
terraform plan
terraform apply
```

## 📁 Project Structure

```
BM-GP/
├── 📄 app.js                    # Main Node.js application
├── 📄 package.json              # Node.js dependencies
├── 📄 Dockerfile                # Container definition
├── 📁 k8s/                      # Kubernetes manifests
│   ├── deployment.yaml          # Application deployment
│   ├── service.yaml             # LoadBalancer service
│   └── service-monitoring.yaml  # Monitoring configuration
├── 📁 terraform/                # Infrastructure as Code
│   ├── main.tf                  # Main Terraform configuration
│   ├── variables.tf             # Variable definitions
│   ├── outputs.tf               # Output definitions
│   └── terraform.tfvars         # Variable values
├── 📁 .github/workflows/        # CI/CD pipeline
│   └── ci-cd.yml                # GitHub Actions workflow
├── 📁 scripts/                  # Deployment scripts
│   ├── deploy.sh                # Bash deployment script
│   └── deploy.ps1               # PowerShell deployment script
└── 📄 DEPLOYMENT.md             # Detailed deployment guide
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- 📖 [Detailed Deployment Guide](DEPLOYMENT.md)
- 🐛 [Report Issues](../../issues)
- 💬 [Discussions](../../discussions)

## 🌟 Acknowledgments

- Built with ❤️ using Node.js, Docker, Kubernetes, and AWS
- Terraform for Infrastructure as Code
- GitHub Actions for CI/CD automation

