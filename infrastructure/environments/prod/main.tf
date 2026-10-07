terraform {
    required_version = ">= 1.0"

    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }

        random = {
            source = "hashicorp/random"
        }
    }

    backend "s3" {
        bucket = "capstone-terraform-state-rokia"
        key = "prod/terraform.tfstate"
        region = "us-east-1"
        encrypt = true
        dynamodb_table = "terraform-locks"
    }
}

provider "aws" {
    region = var.aws_region
}

module "vpc" {
    source = "../../modules/vpc"

    aws_region = var.aws_region
    vpc_cidr = var.vpc_cidr
    project_name = var.project_name
}

module "eks" {
    source = "../../modules/eks"

    project_name = var.project_name
    public_subnets = module.vpc.public_subnets
    private_subnets = module.vpc.private_subnets 
}

module "rds" {
    source = "../../modules/rds"

    project_name = var.project_name
    vpc_id = module.vpc.vpc_id 
    private_subnets = module.vpc.private_subnets 
}

module "redis" {
    source = "../../modules/redis"

    project_name = var.project_name
    vpc_id = module.vpc.vpc_id 
    private_subnets = module.vpc.private_subnets 
}