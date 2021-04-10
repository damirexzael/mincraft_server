# ------------------------------------------------------------------------------
# privileges for the instance we are standing up
# ------------------------------------------------------------------------------
resource "aws_iam_role" "instance_connect" {
  name        = "instance-connect"
  description = "privileges for the instance-connect demonstration"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["ec2.amazonaws.com", "ssm.amazonaws.com" ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "instance_connect" {
  role       = aws_iam_role.instance_connect.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_instance_profile" "instance_connect" {
  name = "instance-connect"
  role = aws_iam_role.instance_connect.id
}

# ------------------------------------------------------------------------------
# security group constraining access
# ------------------------------------------------------------------------------

resource "aws_security_group" "instance_connect" {
  vpc_id      = aws_vpc.instance_connect.id
  name_prefix = "instance_connect"
  description = "allow ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_list
  }

  ingress {
  from_port   = 25565
  to_port     = 25565
  protocol    = "tcp"
  cidr_blocks = var.ssh_list
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "minecraft_key_pair" {
  key_name   = "deployer-key"
  public_key = file("connection/minecraft.pub")
}

resource "aws_ebs_volume" "minecraft_data" {
  availability_zone = "us-east-1a"
  size              = 10

  tags = {
    Name = "Minecraft Data"
  }
}

# ------------------------------------------------------------------------------
# the instance we will try to connect to
# ------------------------------------------------------------------------------
resource "aws_instance" "instance_connect" {
  ami                         = data.aws_ami.target_ami.id
  instance_type               = "t2.xlarge"
  subnet_id                   = aws_subnet.instance_connect.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.minecraft_key_pair.key_name
  availability_zone = "us-east-1a"

  vpc_security_group_ids = [aws_security_group.instance_connect.id]

  iam_instance_profile = aws_iam_instance_profile.instance_connect.name

  tags        = merge(map("Name","instance_connect"), var.tags)
  volume_tags = merge(map("Name","instance_connect"), var.tags)

  user_data = file("install_minecraft.sh")
}

resource "aws_volume_attachment" "minecraft_volume_attachment" {
device_name = "/dev/sdh"
volume_id   = aws_ebs_volume.minecraft_data.id
instance_id = aws_instance.instance_connect.id
}


  # ------------------------------------------------------------------------------
# policy for users allowing connection
# ------------------------------------------------------------------------------
resource "aws_iam_policy" "instance_connect" {
  name        = "instance-connect"
  path        = "/test/"
  description = "Allows use of EC2 instance connect"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
  		"Effect": "Allow",
  		"Action": "ec2-instance-connect:SendSSHPublicKey",
  		"Resource": "${aws_instance.instance_connect.arn}",
  		"Condition": {
  			"StringEquals": { "ec2:osuser": "ec2-user" }
  		}
  	},
		{
			"Effect": "Allow",
			"Action": "ec2:DescribeInstances",
			"Resource": "*"
		}
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "instance_connect" {
  name       = "instance-connect"
  users      = ["damirexzael"]
  policy_arn = aws_iam_policy.instance_connect.arn
}

# associate own elastic IP
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.instance_connect.id
  allocation_id = var.elastic_ip_allocation_id
}
