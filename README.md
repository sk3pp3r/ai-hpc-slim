# AI-HPC Infrastructure Management

A demonstration of HPC/AI infrastructure management capabilities, including Infrastructure as Code (IaC), CI/CD, and monitoring.

## Architecture

The project implements a scalable AI training infrastructure with the following components:

- Kubernetes cluster for orchestration
- GPU-enabled nodes for AI training
- Monitoring stack (Prometheus + Grafana)
- CI/CD pipeline using GitHub Actions

## Prerequisites

- GitHub account
- Access to a Kubernetes cluster with GPU nodes
- Docker Hub account (for container registry)
- Terraform v1.5.0 or later

## Setup Instructions

### 1. Fork and Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/ai-hpc-slim.git
cd ai-hpc-slim
```

### 2. Configure GitHub Secrets

Add the following secrets to your GitHub repository (Settings > Secrets and variables > Actions):

- `KUBE_CONFIG`: Your Kubernetes cluster configuration (base64 encoded)
- `DOCKERHUB_USERNAME`: Your Docker Hub username
- `DOCKERHUB_TOKEN`: Your Docker Hub access token

To get your Kubernetes config:
```bash
kubectl config view --raw | base64
```

### 3. Deploy Infrastructure

The infrastructure will be automatically deployed when you push to the main branch. You can also trigger the workflow manually:

1. Go to the "Actions" tab in your GitHub repository
2. Select "Deploy AI-HPC Infrastructure"
3. Click "Run workflow"

### 4. Monitor Deployment

Once the workflow completes:
- Check the Kubernetes resources in the `ai-training` namespace
- Access Grafana dashboard at `http://YOUR_CLUSTER_IP:3000`
- View training job logs in the GitHub Actions output

## Project Structure

```
.
├── .github/
│   └── workflows/
│       └── deploy.yaml      # GitHub Actions workflow
├── kubernetes/
│   ├── gpu-training.yaml    # GPU training job
│   └── monitoring.yaml      # Monitoring stack
├── terraform/
│   ├── main.tf             # Main Terraform configuration
│   ├── variables.tf        # Variable definitions
│   └── outputs.tf          # Output definitions
└── README.md
```

## Monitoring

The monitoring stack includes:
- Prometheus for metrics collection
- Grafana for visualization
- Node Exporter for hardware metrics
- GPU metrics exporter

Access the Grafana dashboard to view:
- GPU utilization
- Node resource usage
- Training job metrics

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT License
