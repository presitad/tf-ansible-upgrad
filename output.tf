output "VPC" {
  value = aws_vpc.My_VPC.arn
}

output "Internet-gateway" {
  value = aws_internet_gateway.My_VPC_GW.arn
}

output "Public-Subnet" {
  value = aws_subnet.My_VPC_Subnet.arn
}

output "Route-table-public" {
  value = aws_route_table.My_VPC_route_table.arn
}

output "Private-Subnet" {
  value = aws_subnet.My_VPC_Subnet3.arn
}

output "Route-table-private" {
  value = aws_route_table.private_subnet_route_table.arn
}

output "Nat-Gateway-IP" {
  value = aws_nat_gateway.myngw.public_ip
}

output "Bastion-HOST-IP" {
  value = aws_instance.BASTION.public_ip
}

output "Jenkins-IP" {
  value = aws_instance.jenkins.private_ip
}

output "App-IP" {
  value = aws_instance.app.private_ip
}


# output "Load-Balancer" {
#   value = aws_lb.alb.arn
# }
