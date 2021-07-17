resource "aws_instance" "instance1" {
  ami           = data.aws_ami.ami.id
  instance_type = var.instance_type
  key_name  = aws_key_pair.mykey.key_name

  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  subnet_id = var.public_subnet_id
  associate_public_ip_address = true
  user_data = <<-EOF
          #!/bin/bash
          sudo amazon-linux-extras install nginx1 -y
          sudo systemctl stop nginx
          sudo systemctl start nginx
          sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html
          sudo chown ec2-user /usr/share/nginx/html
            EOF


  tags = {
    Name = "NGINX-Instance"
  }

  provisioner "file" {
    source = "${path.module}/index.html"
    destination = "~/index.html"

    connection {
      host = self.public_ip
      type = "ssh"
      user = "ec2-user"
      private_key = file("${path.module}/mykey.pem")
      # timeout = "3m"
    }
  }

}

resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = file("${path.module}/mykey.pem.pub")

}

resource "aws_security_group" "nginx-sg" {
  name        = "NGINX-sg"
  description = "Allow SSH and HTTP From Anywhere"
  vpc_id      = var.vpc_id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

  tags = {
    Name = "Allow SSH from Anywhere"
  }

}
