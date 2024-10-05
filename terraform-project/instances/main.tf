data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "proxy" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_id

  tags = {
    Name = "Proxy"
  }
}

resource "aws_instance" "backend" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_id

  tags = {
    Name = "Backend"
  }
}
resource "aws_instance" "nginx" {
  for_each                     = local.public_instances
  ami                          = data.aws_ami.amz_linux.id
  instance_type                = var.ec2type
  associate_public_ip_address   = true
  key_name                     = var.ec2key
  subnet_id                    = each.value.subnet_id
  security_groups              = [var.pub_sg_id]

  provisioner "local-exec" {
    command = "echo ${each.value.instance_name} Public IP ${self.public_ip} >> all-ips.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install nginx -y",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      <<EOF
      echo 'server {
        listen 80;
        location / {
          proxy_pass http://${var.alb_private_dns};
        }
      }' | sudo tee /etc/nginx/conf.d/reverse-proxy.conf
      EOF
      ,"sudo systemctl restart nginx"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("/home/ziad/Desktop/key.pem")
    host        = self.public_ip
  }

  tags = {
    Name = each.value.instance_name
  }
}

resource "aws_instance" "web" {
  for_each                     = local.private_instances
  ami                          = data.aws_ami.amz_linux.id
  instance_type                = var.ec2type
  key_name                     = var.ec2key
  subnet_id                    = each.value.subnet_id
  security_groups              = [var.priv_sg_id]

  provisioner "local-exec" {
    command = "echo ${each.value.instance_name} Private IP ${self.private_ip} >> all-ips.txt"
  }

  provisioner "file" {
    source      = each.value.file_source
    destination = "/tmp/index.html"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("/home/ziad/Desktop/key.pem")
      host        = self.private_ip
      bastion_host = aws_instance.bast_host.public_ip
      bastion_user = "ec2-user"
      bastion_private_key = file("/home/ziad/Desktop/key.pem")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install httpd -y",
      "sudo systemctl enable httpd",
      "sudo systemctl start httpd",
      "sudo mv /tmp/index.html /var/www/html/index.html",
      "sudo systemctl restart httpd"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("/home/ziad/Desktop/key.pem")
      host        = self.private_ip
      bastion_host = aws_instance.bast_host.public_ip
      bastion_user = "ec2-user"
      bastion_private_key = file("/home/ziad/Desktop/key.pem")
    }
  }

  tags = {
    Name = each.value.instance_name
  }
}
