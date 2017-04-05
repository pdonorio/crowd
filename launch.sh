#!/bin/bash

for i in `seq 1 5`;
do
    source os_new_node.sh swarm0$i

    # $ssh_command docker swarm leave --force
    # $ssh_command "sync; sudo reboot"
    # $ssh_command 'docker rm -f $(docker ps -a -q)'

    for container in `$ssh_command docker ps -q`;
    do
        PORT=$($ssh_command docker inspect $container | jq -r ".[0].Config.Labels.notebook_port")
        LINE=$($ssh_command docker logs --tail 1 $container 2>&1)
        TOKEN=$(echo $LINE | sed 's/^[^?]*//')
        echo http://$current_ip:$PORT/$TOKEN

        # exit 1
    done

done
