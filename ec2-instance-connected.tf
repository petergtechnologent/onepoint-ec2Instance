# This template is designed for deploying an EC2 instance from the Morpheus UI. 

locals {
  ec2_power_schedule = "<%=customOptions.ot_power_schedule%>" != "null" ? "<%=customOptions.ot_power_schedule%>" : var.power_schedule
  ec2_instance_count = "<%=customOptions.ec2InstanceCount%>"
}

data "aws_subnet" "subnet" {
  availability_zone = "<%=customOptions.ot_availability_zone%>"
  vpc_id            = var.vpc
}

resource "aws_instance" "ec2" {
  count = local.ec2_instance_count
  instance_type           = "<%=customOptions.ec2InstanceType%>"
  ami                     = "<%=customOptions.ot_image_id%>"
  subnet_id               = data.aws_subnet.subnet.id
  vpc_security_group_ids  = [var.security_groups]
  key_name                = var.key_name
  user_data                   = <<-EOF
   #! /bin/bash
   echo "OPM CMaaS"
   sudo bash -c 'echo "OPM CMaaS" | tee /home/ec2-user/opm.log'
   sudo bash -c 'echo "OPM CMaaS" >> /home/ec2-user/opm.txt'
   sudo bash -c 'echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDT+qPnovKEbCKG4zWm3Yy8KC5W+8RL8mTLTkpVRemeWMZoR6L2O7xFkq5bT2LIPlskQh46YsFkjQCtJ70XkiDnu3znz06/LoJUUEQkF0RLP97C6lHE1gY5rRlbS5W1ulb/hbbmCNV3xdOsPRPR0s3Azho1InOlJbL0FRzz2v+KounyCSf684ElQI9XiuGSrj7nwY/dth+E9Ea7sEh7mtDIvc6fGfapAZ2wr+AvqOdqKNh1lGhduldtvOk2VHtnYfrVf9ItT5Prit2GAj+PpLhkwa744cjwn4aFiVwzN6waD7wChSH9+K9mbXGzECZJVE+3agiqOVI/u3oIc+pghfYH opmadminprov"  >> /home/ec2-user/.ssh/authorized_keys'
   
   sudo bash -c '<%=instance?.cloudConfig?.agentInstall%> | tee /home/ec2-user/agentInstall.log'
   sudo bash -c '<%=instance?.cloudConfig?.finalizeServer%> | tee /home/ec2-user/finalizeServer.log'
   
   EOF
  tags = {
    Name = "<%=instance.name%>"
    PowerSchedule = local.ec2_power_schedule
  }
}
