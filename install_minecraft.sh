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
        -e MEMORY=6144m \
        -v "/home/ec2-user/data:/data" \
        --restart unless-stopped \
        itzg/minecraft-server
docker start minecraft
# Create shutdown script
cat > /home/ec2-user/shutdown.sh <<- "EOF"
#!/bin/bash

for (( COUNTDDOWN=20; COUNTDDOWN>0; COUNTDDOWN-- ))
do
    echo "list" | sudo docker exec -i minecraft rcon-cli | grep "There are 0"
    if [ $? -ne 0 ]; then
        echo "There are online players"
        MSG="There are online players (Check every 30 minutes). Countdown ${COUNTDDOWN} of 20 minutes."
        echo $MSG
        echo "say ${MSG}" | sudo docker exec -i minecraft rcon-cli
        exit 0
    else
        echo "Sin juugadores online"
            MSG="Waiting for players to come back in ${COUNTDDOWN} minutes, otherwise shutdown"
            echo $MSG
            echo "say ${MSG}" | sudo docker exec -i minecraft rcon-cli
            sleep 1m
    fi
done
# Save world
echo "save-all" | sudo docker exec -i minecraft rcon-cli
# shutdown
$(sudo /sbin/shutdown -P +1)
EOF
chmod +x /home/ec2-user/shutdown.sh
# Create CRON task using shutdown script
CRON_TEXT="*/30 * * * * /home/ec2-user/shutdown.sh >> /tmp/shutdown-script.log 2>&1"
echo "$CRON_TEXT" | crontab -
