# mincraft_server

Create a Minecraft server that stop the 
instance after 30 min with zero players online.
Also, create a Alexa lambda skill for check,
start and stop the minecraft instance.

Links:

https://github.com/itzg/docker-minecraft-server
https://hub.docker.com/r/itzg/minecraft-server

Run local minecraft using docker-compose

    docker-compose up


# Pre install
 
1. Create [elastic IP address](https://console.aws.amazon.com/vpc/home?region=us-east-1#Addresses:).


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

# Post Install (ALexa Skill)

Create [Alexa Skill](https://developer.amazon.com/alexa/console/ask) 
as `Minecraft Server`.

1. Choose a model to add to your skill: Custom
2. Choose a method to host your skill's backend resources : Provisioner your own 
3. Choose a template to add to your skill: Fact Skill
4. Skill Invocation Name: Minecraft Server.
5. Intents -> JSON Editor: Copy lambda_minecraft/skill.json
6. Save Model and build the model
7. Endpoint: Copy aws_lambda_function_arn
8. Save endpoint
9. 

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
    
3. Remove Alexa Skill `Minecraft Server`.


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
