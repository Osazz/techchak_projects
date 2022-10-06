output "ec2_public_dns_0" {
  value = aws_instance.ec2_public[0].public_dns
}

output "ec2_public_dns_1" {
  value = aws_instance.ec2_public[1].public_dns
}

output "ec2_public_dns_2" {
  value = aws_instance.ec2_public[2].public_dns
}