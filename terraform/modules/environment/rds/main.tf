resource "random_string" "username" {
  length  = 16
  special = false
}

resource "random_password" "password" {
  length  = 26
  special = false
}

resource "aws_db_subnet_group" "helium" {
  name       = "helium-${var.environment}"
  subnet_ids = [for id in var.subnet_ids : id]
}

resource "aws_db_instance" "helium" {
  identifier                  = "helium-${var.environment}"
  allocated_storage           = 20
  db_name                     = "platform_${var.environment}"
  engine                      = "mysql"
  engine_version              = "8.4"
  instance_class              = var.instance_size
  username                    = random_string.username.result
  password                    = random_password.password.result
  storage_encrypted           = true
  skip_final_snapshot         = true
  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = true
  deletion_protection         = true
  backup_retention_period     = 7
  vpc_security_group_ids      = [var.mysql_sg]
  db_subnet_group_name        = aws_db_subnet_group.helium.name
  multi_az                    = var.multi_az
  backup_window               = "05:00-05:30"
  maintenance_window          = "sat:06:00-sat:07:00"
}
