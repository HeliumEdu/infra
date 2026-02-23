output "db_username" {
  value = random_string.username.result
}

output "db_password" {
  value = random_password.password.result
}

output "db_host" {
  value = aws_db_instance.helium.address
}