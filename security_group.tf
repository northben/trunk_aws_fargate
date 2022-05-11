resource "aws_security_group" "allow_splunk" {
  name        = "allow_splunk"
  description = "Allow Splunk and webhook inbound traffic"

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
    Name = "allow_splunk"
  }
}
