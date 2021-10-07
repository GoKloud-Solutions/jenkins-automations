resource "aws_security_group" "ecsSG" {
  name        = "jenkins-ecs-sg"
  vpc_id      = var.vpcId

  ingress = [
    {
      from_port        = 5000
      description = "For the JNLP port accessablitiy"
      to_port          = 5000
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = [var.controler_sg]
      self             = false
    }
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      description = "For outbound traffic"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name = "allow_tls"
  }
}