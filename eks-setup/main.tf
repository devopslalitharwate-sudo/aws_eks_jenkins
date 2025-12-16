#vpc

module "vpc" {

  source = "terraform-aws-modules/vpc/aws"

  name = "eks-vpc"
  cidr = var.vpc_cidr

  azs                     = data.aws_availability_zones.available.names
  private_subnets         = var.private_subnets
  public_subnets          = var.public_subnets
  enable_dns_hostnames    = true
  map_public_ip_on_launch = true
  enable_nat_gateway      = true
  single_nat_gateway      = true

  tags = {
    Name        = "eks-vpc"
    Terraform   = "true"
    Environment = "dev"
  }

  public_subnet_tags = {
    Name                                   = "eks-public-subnets"
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/elb"               = 1
  }

  private_subnet_tags = {
    Name                                   = "eks-private-subnets"
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb"      = "1"
  }
}


#eks

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "my-eks-cluster"
  kubernetes_version = "1.33"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnets

  eks_managed_node_groups = {
    nodes = {

      ami_type       = ""
      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

