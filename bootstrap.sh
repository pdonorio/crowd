#!/bin/bash

ls -l /usr/bin/docker
if [ "$?" != "0" ]; then

    echo "$1 $HOSTNAME " >> /etc/hosts

    # apt-get update && apt-get upgrade -y
    wget -qO- https://get.docker.com/ | sh

    usermod -aG docker $2

    apt-get install -y python3-pip \
        && pip3 install --upgrade pip docker-compose

    # # swarm?
    # docker swarm init

    # sync
    # reboot

else
    echo "Bootstrap was already done"
fi

# docker swarm join --token $token $ip:2377
# echo "Joined..."
