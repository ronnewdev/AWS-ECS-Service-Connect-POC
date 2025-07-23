# Replace these values with your actual environment details

vpc_id = "vpc-0247a7a87c35a134f"

subnet_ids = [
  "subnet-04924db4881962061",
  "subnet-0d8c8255760c721a0"
]

# ECR image URLs (make sure both images are pushed to ECR already)
ecr_backend_image  = "480195466229.dkr.ecr.eu-north-1.amazonaws.com/usama-backend:latest"
ecr_frontend_image = "480195466229.dkr.ecr.eu-north-1.amazonaws.com/usama-frontend:latest"

# Optional override for ECS cluster name
ecs_cluster_name = "service-connect-poc"
