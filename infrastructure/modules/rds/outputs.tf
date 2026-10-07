output "db_endpoint" {
    value = aws_db_instance.main.endpoint
}

output "db_password_secret" {
    value = aws_secretsmanager_secret.db_password.name
}