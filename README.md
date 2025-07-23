AWS ECS Service Connect POC
A Proof-of-Concept: demonstrates how to set up a microservices architecture on AWS using ECS Fargate, AWS App Mesh, and ECS Service Connect with Terraform.

🚀 Table of Contents
Architecture

Features

Prerequisites

Getting Started

1. Clone the repo

2. Configure Terraform

3. Deploy Infrastructure

Repository Structure

Details & Usage

Cleanup


🏗️ Architecture
This PoC sets up:

ECS Cluster with container insights enabled

AWS App Mesh for service-to-service communication

Service Connect managing internal service discovery

Fargate Tasks/Services – separate frontend/backend

AWS CloudWatch for centralized logs

Service Discovery via private DNS namespace

✅ Features
Modular Terraform design

ECS FARGATE launch with ARM64 support

Private networking with ECS Service Connect

Shared CloudWatch logging across services

Infrastructure as code, ready for customization

🧭 Prerequisites
Before proceeding, ensure you have:

Requirement	Detail
Terraform CLI	v1.4+
AWS CLI	v2.x, configured with correct IAM permissions
AWS IAM Role	ecsTaskExecutionRole exists in your account
VPC & Subnets	Already deployed and accessible
ECS Images	Frontend/backend container images pushed to ECR in the correct region (eu-north-1)

⚙️ Getting Started
1. Clone the repo
git clone https://github.com/ronnewdev/AWS-ECS-Service-Connect-POC.git
cd AWS-ECS-Service-Connect-POC
2. Configure Terraform
Update terraform.tfvars:
vpc_id             = "your-vpc-id"
subnet_ids         = ["subnet-aaa","subnet-bbb"]
ecr_backend_image  = "123456789012.dkr.ecr.eu-north-1.amazonaws.com/backend:latest"
ecr_frontend_image = "123456789012.dkr.ecr.eu-north-1.amazonaws.com/frontend:latest"
ecs_cluster_name   = "my-service-connect-poc"
3. Deploy Infrastructure
terraform init
terraform plan
terraform apply
You’ll see applied modules for VPC, ECS cluster, App Mesh, and both backend & frontend services.

📁 Repository Structure
.
├── modules/                 
│   ├── network/            → VPC & subnet wrapper
│   ├── ecs-cluster/        → ECS cluster and CloudWatch logs
│   ├── app-mesh/           → App Mesh + private DNS namespace
│   └── service/            → Generic ECS Fargate service with Service Connect
├── main.tf                 → Root module tying everything together
├── variables.tf            → Root variables
├── outputs.tf              → Module outputs
├── terraform.tfvars        → Environment-specific values
└── provider.tf             → AWS provider configuration

🧩 Details & Usage
Modules
network: accepts an existing VPC & subnet IDs

ecs-cluster: provisions ECS cluster with container insights & CloudWatch log group

app-mesh: sets up App Mesh and service discovery namespace

service: deploys ECS Fargate services with Service Connect enabled

Service Connect
Backend: internal-only (no public IP), accessible via backend-poc.service.local:5000

Frontend: public IP enabled; configured to communicate with backend using Service Connect alias on port 5000

🧹 Cleanup
terraform destroy
This will tear down all resources provisioned by Terraform in this PoC.

