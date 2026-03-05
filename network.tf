resource "aws_vpc" "this" {
  cidr_block           = var.cider_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.project_name}-vpc"
  }
}
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "resume-igw"
  }
}
resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.cider_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "public-route-table"
  }
}
resource "aws_route" "all_out" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public_rt.id
  gateway_id             = aws_internet_gateway.this.id

}

resource "aws_route_table_association" "public_assoc" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}
# i didnt use explicit type of gateway as i realised it is default lol
resource "aws_vpc_endpoint" "gateways" {
  for_each     = local.gateway_endpoints
  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${var.region}.${each.key}"
  policy       = each.value.policy
  tags = {
    Name = "${each.key}-gateway-endpoint"
  }
}

resource "aws_vpc_endpoint_route_table_association" "gateway_routes" {
  for_each = aws_vpc_endpoint.gateways

  route_table_id  = aws_route_table.public_rt.id
  vpc_endpoint_id = each.value.id
}
