resource "aws_vpc" "main" {
    cidr_block = "192.168.0.0/16"
    enable_dns_hostnames = "true" #required for eks
    enable_dns_support = "true"   #required for eks
    instance_tenancy = "default"

    tags = {
        Name="main"
    }
  
}
output "vpc_id" {
    value = aws_vpc.main.id
  
}
