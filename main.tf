provider "aws" {
  region = var.region
}

resource "aws_key_pair" "mysshkey" {
  key_name   = var.ssh_keypair_name
  public_key = file(var.ssh_keypair_pub)
}

resource "aws_security_group" "http_ingress" {
  name        = "http-ingress"
  description = "Allow inbound HTTP traffic"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "myec2" {
  ami                    = var.ami
  instance_type          = var.ec2_type
  key_name               = aws_key_pair.mysshkey.key_name
  vpc_security_group_ids = [aws_security_group.http_ingress.id]

  provisioner "local-exec" {
      command = "sleep 30 && ansible-playbook -i '${aws_instance.myec2.public_ip},' -e 'debian_host=${aws_instance.myec2.public_ip}' ansible/install-jenkins.yml"
  }

}
