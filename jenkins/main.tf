module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jenkins-vpc"
  cidr = var.vpc_cidr

  azs                     = [data.aws_availability_zones.available.names[0]]
  public_subnets          = var.subnets
  map_public_ip_on_launch = true

  tags = {
    Name        = "jenkins-vpc"
    Terraform   = "true"
    Environment = "dev"
  }

  public_subnet_tags = {
    Name = "jenkins-subnet"
  }
}

#sg
module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "jenkins-service"
  description = "Security Group for Jenkins Server"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "Jenkins PORT"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "0.0.0.0/0"
    }

  ]


  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Name = "Jenkins-security"
  }
}




module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "jenkins-instance"
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [module.sg.security_group_id]
  monitoring                  = true
  user_data                   = file("${path.module}/user_data.sh")
  subnet_id                   = module.vpc.public_subnets[0]

  tags = {
    Name        = "jenkins-instance"
    Terraform   = "true"
    Environment = "dev"
  }
}
