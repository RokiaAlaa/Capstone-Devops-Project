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
}

provider "aws" {
    region = "us-east-1"
    access_key = "test"
    secret_key = "test"
    skip_credentials_validation = true
    skip_metadata_api_check = true
    skip_requesting_account_id = true

    endpoints {
        ec2 = "http://localhost:4566"
        eks = "http://localhost:4566"
        rds = "http://localhost:4566"
        elasticache = "http://localhost:4566"
        iam = "http://localhost:4566"
        secretsmanager = "http://localhost:4566"
        sts = "http://localhost:4566"
    }
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