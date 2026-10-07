resource "aws_elasticache_subnet_group" "main" {
    name = "${var.project_name}-redis-subnet"
    subnet_ids = var.private_subnets

    tags = {
        Name = "${var.project_name}-redis-subnet"
    }
}

resource "aws_security_group" "redis" {
    name = "${var.project_name}-redis-sg"
    vpc_id = var.vpc_id

    ingress {
        from_port = 6379
        to_port = 6379
        protocol = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }
    
    egress { 
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_elasticache_cluster" "main" {
    cluster_id = "${var.project_name}-redis"
    engine = "redis"
    engine_version = "7.0"
    node_type = "cache.t3.micro"
    num_cache_nodes = 1
    parameter_group_name = "default.redis7"
    port = 6379

    subnet_group_name = aws_elasticache_subnet_group.main.name
    security_group_ids = [aws_security_group.redis.id]

    tags = {
        Name = "${var.project_name}-redis"
    }
}