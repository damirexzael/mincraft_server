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
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDe/BnG948G21Fid1tWGkrefmvyV4q71pjjW5Kgkde+t6Sd1vOu/RnVHYHsCZ4KNrns9p3HiKo1TV2k842pD5YPzjK32eEpFxfDnYzc6uD8rJVQJtcSOkHfwZNn9BXY3IgiRqo1zGaiG8qqdnf6S02YBsV6EoahV2hQUHBvPmuAUV51DSh8JhDNZ3Cblgu17HkOiXTOer+2AwVTJ8SufjAuk2KcMy/omTV5/6xDLZR1Ja6Gyy6e21DiT5EDLCPmL5qUd8sbiYZ2X+42DQDnBwxqFyuBWFtuCN+ufD/uhn7ml+udgll+T9WGIegEq/t3ZW+5d70A34BOAf7qozDR1YJVkosHMfZhZYff3se4t7CK402xZjNCM2NFog2j9AmFLjw3uVHe9mql8fp9dulqodawE+P9CRCANqilhm+8XSHF2bmL82wUDXzCOOSkQPXaDghlIh9m+updqwNMTGOVl462J72qIxAICBQNxPby9f/8nediIpv3eAG44bcGGP9Kdzk= damiraliquintui@damirs-MacBook-Pro.local"
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
  instance_type               = "t2.small"
  subnet_id                   = aws_subnet.instance_connect.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.minecraft_key_pair.key_name
  availability_zone = "us-east-1a"

  #root_block_device = {
  #  volume_type = "standard"
  #  volume_size = 8
  #}

  vpc_security_group_ids = [aws_security_group.instance_connect.id]

  iam_instance_profile = aws_iam_instance_profile.instance_connect.name

  tags        = merge(map("Name","instance_connect"), var.tags)
  volume_tags = merge(map("Name","instance_connect"), var.tags)

  user_data = <<EOF
#!/bin/bash
sudo yum update -y -q
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --disable docker-ce-stable
yum install docker -y
systemctl start docker
systemctl enable docker
mkdir /home/ec2-user/data
mkfs -t xfs /dev/xvdh
mount /dev/xvdh /home/ec2-user/data
docker create \
        -p 25565:25565 \
        --name minecraft \
        -e EULA=TRUE \
        -e VERSION=SNAPSHOT \
        -e ONLINE_MODE=false \
        -e MEMORY=1024m \
        -v "/home/ec2-user/data:/data" \
        itzg/minecraft-server
docker start minecraft
EOF
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
