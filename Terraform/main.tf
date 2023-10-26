### DATA BLOCKS
data "aws_availability_zones" "available" {}
data "aws_vpc" "eks-vpc" {
  tags = {
    Name = var.vpc_name
  }
}
###

### VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name                 = var.vpc_name
  cidr                 = var.cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared",
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                        = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"               = "1"
  }
}
###

### EKS Module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.17.2"

  cluster_name                    = var.eks_cluster_name
  cluster_version                 = var.kubernetes_version
  cluster_endpoint_private_access = true

  subnet_ids = var.private_subnets
  vpc_id     = data.aws_vpc.eks-vpc.id

  tags = {
    Terraform   = "true"
    Environment = "test"
  }

  #cluster_additional_security_group_ids = ["sg-0d27814818022c661"]

  eks_managed_node_group_defaults = {
    disk_size                  = 20
    instance_types             = var.instance_type
    ami_type                   = var.ami_id
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    Infrastructure = {
      subnet_ids   = var.private_subnets
      min_size     = 2
      max_size     = 7
      desired_size = 3
      key_name     = var.keypair_name

    }
  }
  depends_on = [module.vpc]
}
###
