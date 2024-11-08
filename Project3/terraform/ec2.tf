data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "tls_private_key" "student" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.additional_tags["student"]
  public_key = tls_private_key.student.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.student.private_key_pem}' > ${var.additional_tags["student"]}-key"
  }
}

resource "aws_instance" "public" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public.id
  security_groups = [aws_security_group.public.id]
  key_name        = aws_key_pair.generated_key.key_name

  user_data = <<EOF
#!/bin/bash
echo -e "${tls_private_key.student.public_key_openssh}" >> /home/ubuntu/.ssh/authorized_keys
EOF


  tags = merge(
    var.additional_tags,
    {
      Name = "${var.additional_tags["student"]}-jenkins-main"
    },
  )
}

resource "aws_spot_instance_request" "private" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = "t2.micro"
  spot_price           = "1.0"
  wait_for_fulfillment = true
  subnet_id            = aws_subnet.private.id
  security_groups      = [aws_security_group.private.id]
  key_name             = aws_key_pair.generated_key.key_name

  user_data = <<EOF
#!/bin/bash
echo -e "${tls_private_key.student.public_key_openssh}" >> /home/ubuntu/.ssh/authorized_keys
EOF



  tags = merge(
    var.additional_tags,
    {
      Name = "${var.additional_tags["student"]}-jenkins-worker"
    },
  )
}

