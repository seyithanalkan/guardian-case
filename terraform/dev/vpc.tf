# Availability Zones'i otomatik olarak çekme
data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source      = "../modules/vpc"
  vpc_cidr    = var.vpc_cidr
  environment = var.environment
  project     = var.project
  cost_center = var.vpc_cost_center
}

module "public_subnets" {
  source            = "../modules/subnet"
  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = var.vpc_cidr
  availability_zones = data.aws_availability_zones.available.names
  subnet_type       = "public"
  environment       = var.environment
  project           = var.project
  cost_center       = var.cost_center
  subnet_offset     = 0  
}

module "private_subnets" {
  source            = "../modules/subnet"
  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = var.vpc_cidr
  availability_zones = data.aws_availability_zones.available.names
  subnet_type       = "private"
  environment       = var.environment
  project           = var.project
  cost_center       = var.cost_center
  subnet_offset     = 100  
}

module "data_subnets" {
  source            = "../modules/subnet"
  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = var.vpc_cidr
  availability_zones = data.aws_availability_zones.available.names
  subnet_type       = "data"
  environment       = var.environment
  project           = var.project
  cost_center       = var.cost_center
  subnet_offset     = 200  
}


resource "aws_eip" "nat_gateway_eip" {
  tags = {
    Name        = format("%s-%s-ngw-eip", var.project, var.environment)
    Environment = var.environment
    Project     = var.project
    Cost_Center = var.cost_center
    Created_By  = var.created_by
  }
}


# İnternet Gateway Oluşturma
resource "aws_internet_gateway" "igw" {
  vpc_id = module.vpc.vpc_id

  tags = {
    Name        = format("%s-%s-igw", var.project, var.environment)
    Environment = var.environment
    Project     = var.project
    Cost_Center = var.cost_center
    Created_By  = var.created_by
  }
}

module "nat_gateway" {
  source        = "../modules/nat_gateway"
  subnet_id     = element(values(module.public_subnets.subnet_ids), 0)  # İlk Public Subnet ID'yi al
  allocation_id = aws_eip.nat_gateway_eip.id
  environment   = var.environment
  project       = var.project
  cost_center   = var.cost_center
}

module "public_route_table" {
  source         = "../modules/route_table"
  vpc_id         = module.vpc.vpc_id
  gateway_id     = aws_internet_gateway.igw.id
  nat_gateway_id = module.nat_gateway.nat_gateway_id
  environment    = var.environment
  project        = var.project
  cost_center    = var.cost_center

  route_type     = "public"
  subnet_ids     = values(module.public_subnets.subnet_ids)
}

module "private_route_table" {
  source         = "../modules/route_table"
  vpc_id         = module.vpc.vpc_id
  gateway_id     = null
  nat_gateway_id = module.nat_gateway.nat_gateway_id
  environment    = var.environment
  project        = var.project
  cost_center    = var.cost_center

  route_type     = "private"
  subnet_ids     = values(module.private_subnets.subnet_ids)
}

module "data_route_table" {
  source         = "../modules/route_table"
  vpc_id         = module.vpc.vpc_id
  gateway_id     = null
  nat_gateway_id = null
  environment    = var.environment
  project        = var.project
  cost_center    = var.cost_center

  route_type     = "data"
  subnet_ids     = values(module.data_subnets.subnet_ids)
}
