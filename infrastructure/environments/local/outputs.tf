output "vpc_id" {
    value = module.vpc.vpc_id
}

output "rds_endpoint" {
    value = module.rds.db_endpoint
}

output "redis_cluster_endpoint" {
    value = module.redis.redis_endpoint
}