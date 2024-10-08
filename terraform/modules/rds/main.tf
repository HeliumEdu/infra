resource "random_string" "username" {
  length  = 16
  special = false
}

output "db_username" {
  value = random_string.username.result
}

resource "random_password" "password" {
  length  = 26
  special = false
}

output "db_password" {
  value = random_password.password.result
}

resource "aws_db_subnet_group" "helium" {
  name       = "helium"
  subnet_ids = [for id in var.subnet_ids : id]
}

resource "aws_db_instance" "helium" {
  identifier                 = "helium-${var.environment}"
  allocated_storage          = 20
  db_name                    = "platform_${var.environment}"
  engine                     = "mysql"
  engine_version             = "8.0"
  instance_class             = "db.t3.micro"
  username                   = random_string.username.result
  password                   = random_password.password.result
  storage_encrypted          = true
  skip_final_snapshot        = true
  auto_minor_version_upgrade = true
  deletion_protection        = true
  backup_retention_period    = 7
  vpc_security_group_ids = [var.mysql_sg]
  db_subnet_group_name       = aws_db_subnet_group.helium.name
}

output "db_host" {
  value = aws_db_instance.helium.address
}