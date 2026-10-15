output "instance_id" { value = aws_instance.honeypot.id }
output "public_ip" { value = aws_instance.honeypot.public_ip }
output "security_group_id" { value = aws_security_group.honeypot.id }