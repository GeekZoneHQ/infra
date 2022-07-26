
output "ec2_public_ip" {
  value = aws_instance.bastion-instance.public_ip
}


output "dev_vpc_id" {
  value = aws_vpc.gz-vpc.id
}

output "subnet-1-id" {
  value = aws_subnet.public-subnet.id
}



