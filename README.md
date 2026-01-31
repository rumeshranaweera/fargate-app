# CI/CD to AWS Fargate using Terraform + GitHub Actions

![Architecture](https://img.shields.io/badge/AWS-Fargate-orange) ![Terraform](https://img.shields.io/badge/IaC-Terraform-purple) ![CI/CD](https://img.shields.io/badge/CI/CD-GitHub_Actions-blue) ![Node.js](https://img.shields.io/badge/Node.js-18-green)

A production-ready, automated deployment pipeline for containerized Node.js applications on AWS ECS Fargate, with infrastructure provisioned using Terraform and CI/CD automated through GitHub Actions.

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
- [CI/CD Pipeline](#cicd-pipeline)
- [Testing the Application](#testing-the-application)
- [Infrastructure Components](#infrastructure-components)
- [Security Best Practices](#security-best-practices)
- [Monitoring and Logging](#monitoring-and-logging)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         GitHub Repository                        │
│  ┌────────────┐  ┌────────────┐  ┌─────────────────────────┐   │
│  │   App Code │  │ Dockerfile │  │  Terraform Configs      │   │
│  └────────────┘  └────────────┘  └─────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Push to main
                              ▼
                    ┌──────────────────┐
                    │ GitHub Actions   │
                    │   (CI/CD)        │
                    └──────────────────┘
                              │
                    ┌─────────┴──────────┐
                    │                    │
                    ▼                    ▼
            ┌──────────────┐    ┌──────────────┐
            │  Build &     │    │  AWS OIDC    │
            │  Push Docker │    │  Auth        │
            └──────────────┘    └──────────────┘
                    │
                    ▼
┌───────────────────────────────────────────────────────────────────┐
│                         AWS Cloud                                  │
│                                                                    │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │                    VPC (10.0.0.0/16)                     │    │
│  │                                                           │    │
│  │  ┌─────────────────────┐  ┌─────────────────────┐       │    │
│  │  │  Public Subnet 1    │  │  Public Subnet 2    │       │    │
│  │  │  (10.0.0.0/24)      │  │  (10.0.1.0/24)      │       │    │
│  │  │                     │  │                     │       │    │
│  │  │  ┌──────────────┐   │  │  ┌──────────────┐   │       │    │
│  │  │  │     ALB      │◄──┼──┼─►│     ALB      │   │       │    │
│  │  │  └──────────────┘   │  │  └──────────────┘   │       │    │
│  │  │  ┌──────────────┐   │  │  ┌──────────────┐   │       │    │
│  │  │  │ NAT Gateway  │   │  │  │ NAT Gateway  │   │       │    │
│  │  │  └──────────────┘   │  │  └──────────────┘   │       │    │
│  │  └─────────┬───────────┘  └──────────┬──────────┘       │    │
│  │            │                          │                  │    │
│  │  ┌─────────▼──────────┐  ┌───────────▼─────────┐        │    │
│  │  │  Private Subnet 1  │  │  Private Subnet 2   │        │    │
│  │  │  (10.0.2.0/24)     │  │  (10.0.3.0/24)      │        │    │
│  │  │                    │  │                     │        │    │
│  │  │  ┌──────────────┐  │  │  ┌──────────────┐  │        │    │
│  │  │  │ ECS Task     │  │  │  │ ECS Task     │  │        │    │
│  │  │  │ (Fargate)    │  │  │  │ (Fargate)    │  │        │    │
│  │  │  └──────────────┘  │  │  └──────────────┘  │        │    │
│  │  └────────────────────┘  └─────────────────────┘        │    │
│  └───────────────────────────────────────────────────────────┘    │
│                                                                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │     ECR      │  │ CloudWatch   │  │     IAM      │           │
│  │  (Registry)  │  │    Logs      │  │   Roles      │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
└───────────────────────────────────────────────────────────────────┘
```

### Architecture Components

1. **VPC Network**: Multi-AZ deployment with public and private subnets
2. **Application Load Balancer**: Distributes traffic across ECS tasks
3. **ECS Fargate**: Serverless container orchestration
4. **ECR**: Private Docker image registry
5. **GitHub Actions**: Automated CI/CD pipeline with OIDC authentication
6. **CloudWatch**: Centralized logging and monitoring

---

## ✨ Features

### Infrastructure

- ✅ Multi-AZ VPC with public and private subnets
- ✅ Application Load Balancer with health checks
- ✅ ECS Fargate cluster using public Terraform module
- ✅ Amazon ECR with lifecycle policies
- ✅ Auto-scaling based on CPU and memory
- ✅ NAT Gateways for private subnet internet access

### Security

- ✅ OIDC authentication (no AWS credentials in GitHub)
- ✅ Security groups with least privilege
- ✅ Non-root container user
- ✅ ECR image scanning on push
- ✅ IAM roles with minimal permissions

### CI/CD

- ✅ Automated build on push to main
- ✅ Docker image build and push to ECR
- ✅ ECS task definition updates
- ✅ Zero-downtime deployments
- ✅ Deployment verification

### Application

- ✅ Node.js Express application
- ✅ Health check endpoint
- ✅ Container health checks
- ✅ Structured logging
- ✅ Responsive web interface

---

## 📦 Prerequisites

- **AWS Account** with appropriate permissions
- **Terraform** >= 1.0
- **AWS CLI** configured
- **Docker** installed locally
- **Node.js** 18+ (for local testing)
- **GitHub Account**
- **Git** installed

---

## 📁 Project Structure

```
aws-fargate-cicd/
├── app/
│   ├── index.js              # Node.js application
│   ├── package.json          # NPM dependencies
│   ├── Dockerfile            # Container image definition
│   └── .dockerignore         # Docker ignore patterns
├── terraform/
│   ├── main.tf               # Provider configuration
│   ├── variables.tf          # Input variables
│   ├── outputs.tf            # Output values
│   ├── vpc.tf                # VPC and networking
│   ├── security-groups.tf    # Security group rules
│   ├── alb.tf                # Application Load Balancer
│   ├── ecr.tf                # ECR repository
│   ├── iam.tf                # IAM roles and policies
│   ├── ecs.tf                # ECS cluster and service
│   └── terraform.tfvars.example
├── .github/
│   └── workflows/
│       └── deploy.yml        # CI/CD pipeline
├── .gitignore
└── README.md                 # This file
```

---

## 🚀 Setup Instructions

### Step 1: Clone the Repository

```bash
git clone https://github.com/rumeshranaweera/fargate-app.git
cd fargate-app
```

### Step 2: Configure Terraform Variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
aws_region   = "us-east-1"
project_name = "fargate-app"
github_org   = "rumeshranaweera"
github_repo  = "fargate-app"
```

### Step 3: Deploy Infrastructure with Terraform

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply infrastructure
terraform apply
```

**Important**: Save the outputs, especially:

- `alb_url` - Your application URL
- `github_actions_role_arn` - Needed for GitHub secrets
- `ecr_repository_url` - ECR repository URL

### Step 4: Build and Push Initial Docker Image

```bash
# Get ECR login
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ECR_REPOSITORY_URL>

# Build image
docker build -t fargate-app .

# Tag image
docker tag fargate-app:latest <ECR_REPOSITORY_URL>:latest

# Push to ECR
docker push <ECR_REPOSITORY_URL>:latest
```

### Step 5: Configure GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions

Add the following secret:

```
AWS_ROLE_ARN = <github_actions_role_arn from Terraform output>
```

### Step 6: Trigger Deployment

Push to main branch or manually trigger the workflow:

```bash
git add .
git commit -m "Initial deployment"
git push origin main
```

---

## 🔄 CI/CD Pipeline

The GitHub Actions workflow automates the entire deployment process:

### Pipeline Stages

1. **Checkout** - Retrieves the code from repository
2. **AWS Authentication** - Uses OIDC for secure authentication
3. **ECR Login** - Authenticates to Amazon ECR
4. **Build & Push** - Builds Docker image and pushes to ECR
5. **Update Task Definition** - Creates new revision with new image
6. **Deploy to ECS** - Updates service with new task definition
7. **Wait for Stability** - Ensures deployment completes successfully
8. **Verification** - Confirms service is running

### Workflow Triggers

- **Automatic**: Push to `main` branch
- **Manual**: Via GitHub Actions UI

### OIDC Authentication

The pipeline uses OpenID Connect (OIDC) for secure authentication:

**Benefits:**

- No long-lived AWS credentials in GitHub
- Temporary credentials per workflow run
- Reduced security risk
- Automatic credential rotation

---

## 🧪 Testing the Application

### Health Check Endpoint

```bash
curl http://<ALB_DNS_NAME>/health
```

**Expected Response:**

```json
{
  "status": "healthy",
  "timestamp": "2025-01-31T10:00:00.000Z",
  "uptime": 3600,
  "message": "Application is running successfully"
}
```

### Main Application

Open in browser:

```
http://<ALB_DNS_NAME>
```

You should see a responsive web page with:

- Student name section
- Architecture details
- Technology stack badges
- Deployment status

### Local Testing

```bash
cd app
npm install
npm start
```

Access locally at: `http://localhost:8080`

---

## 🏗️ Infrastructure Components

### VPC Configuration

- **CIDR Block**: 10.0.0.0/16
- **Public Subnets**: 2 (Multi-AZ)
- **Private Subnets**: 2 (Multi-AZ)
- **NAT Gateways**: 2 (One per AZ)
- **Internet Gateway**: 1

### ECS Fargate

- **Cluster**: Managed using public Terraform module
- **Service**: Fargate launch type
- **Task Definition**:
  - CPU: 256 (0.25 vCPU)
  - Memory: 512 MB
  - Network Mode: awsvpc
- **Desired Count**: 2 tasks
- **Auto Scaling**: 1-4 tasks based on CPU/Memory

### Application Load Balancer

- **Type**: Application Load Balancer
- **Scheme**: Internet-facing
- **Listeners**: HTTP (Port 80)
- **Target Group**:
  - Protocol: HTTP
  - Port: 8080
  - Health Check Path: /health
  - Health Check Interval: 30s

### Amazon ECR

- **Image Scanning**: Enabled on push
- **Encryption**: AES256
- **Lifecycle Policy**: Keep last 10 images
- **Tag Mutability**: MUTABLE

---

## 🔒 Security Best Practices

### Network Security

✅ **Private Subnets**: ECS tasks run in private subnets
✅ **Security Groups**: Least privilege access rules
✅ **ALB Security**: Only ports 80/443 exposed
✅ **No Public IPs**: Tasks access internet via NAT Gateway

### IAM Security

✅ **OIDC Authentication**: No hardcoded credentials
✅ **Least Privilege**: Minimal IAM permissions
✅ **Task Execution Role**: Separate from task role
✅ **Assumable Roles**: GitHub-specific trust policies

### Container Security

✅ **Non-root User**: Container runs as nodejs user
✅ **Image Scanning**: Automated vulnerability scanning
✅ **Read-only Root**: Filesystem immutability
✅ **Health Checks**: Container and ALB health monitoring

### Application Security

✅ **No Secrets in Code**: Environment variables for config
✅ **HTTPS Ready**: Can add SSL/TLS certificates
✅ **Security Headers**: Can implement CSP, HSTS

---

## 📊 Monitoring and Logging

### CloudWatch Logs

- **Log Group**: `/ecs/fargate-app`
- **Retention**: 7 days
- **Streams**: One per task

**View Logs:**

```bash
aws logs tail /ecs/fargate-app --follow
```

### ECS Metrics

- Service CPU Utilization
- Service Memory Utilization
- Running Task Count
- Target Group Health

**View Service Status:**

```bash
aws ecs describe-services \
  --cluster fargate-app-cluster \
  --services fargate-app-service
```

### Auto Scaling

- **CPU Trigger**: Scale at 70% utilization
- **Memory Trigger**: Scale at 80% utilization
- **Scale-out Cooldown**: 60 seconds
- **Scale-in Cooldown**: 300 seconds

---

## 🐛 Troubleshooting

### Common Issues

#### 1. Task Fails to Start

**Check:**

```bash
aws ecs describe-tasks \
  --cluster fargate-app-cluster \
  --tasks <task-id>
```

**Common Causes:**

- Image not found in ECR
- IAM role permissions
- Security group blocking traffic

#### 2. Health Check Failures

**Check:**

- Application is listening on port 8080
- Health endpoint returns 200 status
- Security group allows ALB → Task traffic

#### 3. GitHub Actions Fails

**Check:**

- AWS_ROLE_ARN secret is correct
- GitHub OIDC provider is created
- IAM role trust policy includes your repo

#### 4. Cannot Access Application

**Check:**

- ALB security group allows inbound 80
- ECS tasks are running
- Target group shows healthy targets

### Debug Commands

```bash
# Check service status
aws ecs describe-services --cluster fargate-app-cluster --services fargate-app-service

# List running tasks
aws ecs list-tasks --cluster fargate-app-cluster --service fargate-app-service

# View task details
aws ecs describe-tasks --cluster fargate-app-cluster --tasks <task-arn>

# Check logs
aws logs tail /ecs/fargate-app --follow

# Test health endpoint
curl http://<ALB-DNS>/health
```

---

## 🧹 Cleanup

To avoid AWS charges, destroy all resources:

```bash
cd terraform
terraform destroy
```

**Note**: This will delete:

- VPC and all networking components
- ECS cluster, service, and tasks
- ECR repository and images
- Load balancer and target groups
- IAM roles and policies
- CloudWatch log groups

---

## 📝 Assignment Deliverables Checklist

- ✅ **Terraform Infrastructure** (40 marks)
  - VPC with public/private subnets
  - ECS Fargate cluster (using public module)
  - ECR repository
  - IAM roles and policies
  - Application Load Balancer
  - Security groups

- ✅ **Application & Docker** (10 marks)
  - Node.js application on port 8080
  - Dockerfile with best practices
  - Health check endpoint
  - Student name displayed

- ✅ **CI/CD Pipeline** (30 marks)
  - GitHub Actions workflow
  - OIDC authentication
  - Automated build and push to ECR
  - ECS deployment with stability check

- ✅ **Documentation** (10 marks)
  - Comprehensive README
  - Architecture diagram
  - Setup instructions
  - Testing guide

- ✅ **Advanced Features** (10 marks)
  - Application Load Balancer with health checks
  - Auto-scaling configuration
  - Multi-AZ deployment
  - CloudWatch logging
  - Zero-downtime deployments
  - Security best practices

---

## 📚 Additional Resources

- [AWS ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GitHub Actions for AWS](https://github.com/aws-actions)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

---

## 👨‍💻 Student Information

**Name**: Rumesh Ranaweera  
**Student ID**: 21UG1359  
**Course**: Cloud Infrastructure Design  
**Assignment**: CI/CD to AWS Fargate  
**Date**: January 2025

---

## 📄 License

This project is created for educational purposes as part of a university assignment.

---

## 🤝 Acknowledgments

- AWS Documentation
- Terraform Registry
- GitHub Actions Community
- Node.js Community

---

**Made with ❤️ for Cloud Infrastructure Design Assignment**
