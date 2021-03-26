# mincraft_server

Links:

https://github.com/itzg/docker-minecraft-server
https://hub.docker.com/r/itzg/minecraft-server

Run local minecraft using docker-compose

    docker-compose up


# Install in AWS


1. Create ECR in https://console.aws.amazon.com/ecr/create-repository?region=us-east-1

    
    601519195132.dkr.ecr.us-east-1.amazonaws.com/minecraft_server
    
    push command
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 601519195132.dkr.ecr.us-east-1.amazonaws.com
    docker image ls
    docker tag ff7f4ef4a24e 601519195132.dkr.ecr.us-east-1.amazonaws.com/minecraft_server
    docker push 601519195132.dkr.ecr.us-east-1.amazonaws.com/minecraft_server
    

2 Create a VPC in https://console.aws.amazon.com/vpc/home?region=us-east-1#VpcDetails:VpcId=vpc-0cb84617f47cccddd

    
    name: minecraft_vpc
    IPv4 CIDR: 10.0.0.0/24


3 Create subnet https://console.aws.amazon.com/vpc/home?region=us-east-1#subnets:SubnetId=subnet-0cd9f12f62d720888


    From minecraft_vpc
    name: minecraft_vpc_subnet
    using 10.0.0.0/24
    
2. Create a volume in EFS https://console.aws.amazon.com/efs/home?region=us-east-1

    
    Name: minecraft_data
    VPC: minecraft_vpc
    One Zone: us-east-1c

3. Create task definition https://console.aws.amazon.com/ecs/home?region=us-east-1#/taskDefinitions/Minecraft-task/1

    
    USE vpc, volume and image
    

4. Add task role permission for ecr


    Add roles
    
    
5. Create EC2 and upload ecr


    

1. Create ECS https://console.aws.amazon.com/ecs/home?region=us-east-1#/firstRun


    Container name: minecraft_server
    Image: itzg/minecraft-server
    Port mappings: 25575
    ENVIRONMENT:
    - CPU units: 1
    - GPUs: 0
    - Environment variables:
      - EULA: "TRUE"
      - VERSION: "SNAPSHOT"
      - ONLINE_MODE: "false"
      - SERVER_NAME: "Server de Nico"
      - MOTD: "A Snapshot Minecraft Nico Server powered by Docker"
      
      

      Create EBS volumne https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Volumes:sort=desc:createTime
      foormat
      sudo mkfs -t xfs /dev/xvdh
      lsblk # list volumenes

      create with server_file
      
      sudo docker create \
        -p 25565:25565 \
        --name minecraft \
        -e EULA=TRUE \
        -e VERSION=SNAPSHOT \
        -e ONLINE_MODE=false \
        -e MEMORY=512m \
        -e WORLD="/server_files/world.zip" \
        -v "$(pwd)/server_files:/server_files" \
        -v "$(pwd)/data:/data" \
        itzg/minecraft-server
        
        
      create without server_file
      
      sudo docker create \
        -p 25565:25565 \
        --name minecraft \
        -e EULA=TRUE \
        -e VERSION=SNAPSHOT \
        -e ONLINE_MODE=false \
        -e MEMORY=512m \
        -v "$(pwd)/data:/data" \
        itzg/minecraft-server
      

601519195132
damir
us-east-1
damirexzael


/var/log/cloud-init.log
/var/log/cloud-init-output.log



sudo docker ps -a
docker stop
docker rm


# Install

1. Generate rsa


    ssh-keygen -t rsa -f connection/minecraft
    
2. Copy rsa.pub in resource "aws_key_pair" "minecraft_key_pair" -> public_key


    cat connection/minecraft.pub
    
3. Run terraform

    
    terraform init
    terraform apply

4. Enter to instance using ssh


    ssh -i connection/minecraft.pub ec2-user@<ip>

5. Check container finish  with STATUS (healthy)

    
    sudo docker ps

# Backup minecraft world

1. Enter to terminal


    ssh -i connection/minecraft.pub ec2-user@<ip>
    
2. zip world


    zip -r world.zip data/world/

3. Download world

    
    scp -i connection/minecraft.pub ec2-user@<ip>:/home/ec2-user/world.zip <path world zip> 

4. Run install Minecraft

5. Stop container


    sudo docker stop minecraft

6. Upload world.zip

    
    scp -i connection/minecraft.pub <path world zip> ec2-user@<ip>:/home/ec2-user

7. Replace world by world.zip

    
    sudo rm -r data/world
    unzip world.zip
    sudo mv world data/

8. Run docker container


    sudo docker start minecraft



# Uninstall

1. Terminate the instance from AWS console

2. Execute destroy from terraform

    
    terraform destroy
