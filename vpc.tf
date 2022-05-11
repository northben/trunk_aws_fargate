resource "aws_subnet" "trunk" {
  vpc_id     = var.vpc_id
  cidr_block = var.subnet_cidr
  tags = {
    Name = "trunk"
  }
}
