locals {
  ssh_user          =  "user"
  key_name          =  "nginx"
  private_key_path  =  "private_key_path" 
  }   


  provider "aws" {
  access_key = "access_key"
  secret_key = "secret_key"
  region     = "eu-west-2"
}

resource "aws_security_group" "nginx" {
  name          = "allow_ssh"
  description   = "Allow ssh traffic"


  ingress {

    from_port   = 22 
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }

  ingress {

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "aws_instance" "Linux_VM_nginx" {
  ami             = "ami-06178cf087598769c"
  instance_type   = "t2.micro"
  key_name        = "Linux-Key"
  security_groups = [aws_security_group.nginx.name]
  
  tags            = {
    name          = "Linux_VM"
   }


provisioner "remote-exec" {
  inline           = ["echo 'Wait until SSH is ready"]

  connection {
    type           = "ssh"
    user           = local.ssh_user
    private_key    = file(local.private_key_path)
    host           = aws_instance.Linux_VM_nginx.public_ip
   }
 }

provisioner "local-exec" {
    command        = "ansible-playbook -i ${aws_instance.Linux_VM_nginx.public_ip}, --private-key ${local.private_key_path} nginx.yaml"
 }

}

output "nginx_ip" {
    value           = aws_instance.Linux_VM_nginx.public_ip
  
}