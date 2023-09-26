output "ec2pubip" {
  value = aws_instance.myec2.public_ip
}
