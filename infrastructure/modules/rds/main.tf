resource "aws_db_subnet_group" "main" {
    name = "${var.project_name}-db-subnet"
    subnet_ids = var.private_subnets

    tags = {
        Name = "${var.project_name}-db-subnet"
    }
}

resource "aws_security_group" "rds" {
    name = "${var.project_name}-rds-sg"
    vpc_id = var.vpc_id

    ingress {
        from_port = 5432
        to_port = 5432
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

resource "aws_db_instance" "main" {
    identifier = "${var.project_name}-postgres"
    engine = "postgres"
    engine_version = "15.2"
    instance_class = "db.t3.micro"
    allocated_storage = 20

    db_name = "capstone"
    username = "postgres"
    password = random_password.db_password.result

    db_subnet_group_name = aws_db_subnet_group.main.name
    vpc_security_group_ids = [aws_security_group.rds.id]

    skip_final_snapshot = true
    multi_az = false

    tags = {
        Name = "${var.project_name}-postgres"
    }
}

resource "random_password" "db_password" {
    length = 32
    special = true
}

resource "aws_secretsmanager_secret" "db_password" {
    name = "${var.project_name}-db-password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
    secret_id = aws_secretsmanager_secret.db_password.id
    secret_string = random_password.db_password.result
}