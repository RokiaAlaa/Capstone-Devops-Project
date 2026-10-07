output "eks_cluster_name" {
    value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
    value = module.eks.cluster_endpoint
}

output "rds_endpoint" {
    value = module.rds.db_endpoint
}

output "redis_cluster_endpoint" {
    value = module.redis.redis_endpoint
}