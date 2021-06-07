data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

resource "random_id" "kryz_node_id" {
  byte_length = 2
  count       = var.instance_count
  keepers = {
    key_name = var.key_name
  }
}

resource "aws_key_pair" "pc_auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "kryz_node" {
  count         = var.instance_count
  ami           = data.aws_ami.server_ami.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.pc_auth.id
  user_data = templatefile(var.user_data_path, {
    nodename    = "kryz_node-${random_id.kryz_node_id[count.index].dec}"
    db_endpoint = var.dbendpoint
    dbuser      = var.dbuser
    dbpassword  = var.dbpassword
    dbname      = var.dbname
  })

  tags = {
    Name = "kryz_node-${random_id.kryz_node_id[count.index].dec}"
  }

  vpc_security_group_ids = [var.public_sg]
  subnet_id              = var.public_subnet[count.index]

  root_block_device {
    volume_size = var.vol_size
  }

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_ip
      private_key = file("~/.ssh")
    }
    script = "${path.cwd}/delay.sh"
  }

  provisioner "local-exec" {
    command = ""
  }
}

resource "aws_lb_target_group_attachment" "kryz_tg_attach" {
  count = var.instance_count
  target_group_arn = var.lb_target_group_arn
  target_id = aws_instance.kryz_node[count.index].id
  port = var.tg_port
}
