# mincraft_server

Links:

https://github.com/itzg/docker-minecraft-server
https://hub.docker.com/r/itzg/minecraft-server

Run local minecraft using docker-compose

    docker-compose up


# Pre install
 
1. Create elastic IP address this assigned and use this 

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


# Others

* Check healthy of server


    sudo docker container inspect -f "{{.State.Health.Status}}" minecraft

* Check paused


    sudo docker container inspect -f "{{.State.Paused}}" minecraft

* Execute command


    sudo docker exec -i minecraft rcon-cli
    

* execute a command and exit


    echo "say hola" | sudo docker exec -i minecraft rcon-cli

* get actual players

    
    echo "list" | sudo docker exec -i minecraft rcon-cli
