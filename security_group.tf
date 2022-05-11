resource "aws_security_group" "splunk" {
  name        = "splunk"
  description = "Allow Splunk and webhook inbound traffic"
  vpc_id = aws_vpc.splunk_vpc.id

  ingress {
    description      = "8000 from internet"
    from_port        = 8000
    to_port          = 8000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "trello webhook http from internet"
    from_port        = 9000
    to_port          = 9000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # egress is required in order to connect to the ECR
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "Splunk"
  }
}

resource "aws_security_group" "efs" {
  name        = "splunk indexes efs"
  description = "Allow Splunk to connect to EFS"
  vpc_id = aws_vpc.splunk_vpc.id

  ingress {
    description      = "EFS"
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    security_groups = [aws_security_group.splunk.id]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "Splunk indexes EFS"
  }
}
