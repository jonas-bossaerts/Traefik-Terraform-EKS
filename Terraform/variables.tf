# General Variables
variable "region" {
  type = string
}
variable "aws_profile" {
  type = string
}

# EKS Variables
variable "eks_cluster_name" {
  type = string
}
variable "kubernetes_version" {
  type = string
}
variable "keypair_name" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "ami_id" {
  type = string
}

# VPC Variables
variable "cidr" {
  type = string
}
variable "private_subnets" {
  type = list(string)
}
variable "public_subnets" {
  type = list(string)
}
variable "vpc_name" {
  type = string
}
