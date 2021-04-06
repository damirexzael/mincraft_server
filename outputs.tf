output "vpc_id" {
  value = aws_vpc.instance_connect.id
}

output "subnet_cidr" {
  value = aws_subnet.instance_connect.cidr_block
}

output "instance_ip" {
  value = aws_instance.instance_connect.public_ip
}

output "instance_id" {
  value = aws_instance.instance_connect.id
}

output "elastic_ip_allocation_id" {
  value = aws_eip_association.eip_assoc.allocation_id
}

output "aws_lambda_function_arn" {
  value = aws_lambda_function.default.arn
}
