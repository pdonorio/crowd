#!/bin/bash

if [ -z $1 ]; then
    nodename="unknown"
else
    nodename=$1
fi
export nodename
# echo "Node is: $nodename"

export OS_AUTH_URL=
export OS_DOMAIN_NAME=LDAP
export OS_TENANT_NAME=
export OS_VOLUME_API_VERSION=2
export OS_IDENTITY_API_VERSION=3
export OS_REGION_NAME=RegionOne
export OS_IMAGE_NAME=ubuntu-xenial-server

export OS_USERNAME=
export OS_PASSWORD=
export OS_TENANT_ID=

# openstack keypair list
# openstack image list
# openstack flavor list
# openstack security group list
# openstack security group rule list $NAME
# openstack floating ip list
# openstack network list

export OS_SEC_GROUPS=
export OS_KEY_NAME=
export OS_KEY=
export OS_USER=ubuntu
export OS_FLAVOR_NAME=
# export OS_NET_NAME=
# export OS_FLOATINGIP_POOL=ext-net

test=$(openstack server show $nodename -f json --noindent | jq ".addresses" | tr -d '"')

if [ "$test" == "" ];
then
    echo "Let's do this"
    current_ip=$(openstack floating ip list | grep None | head -n 1 | awk '{ print $4 }')

    openstack server create -f json --noindent \
        --file bootstrap=./bootstrap.sh \
        --key-name $OS_KEY_NAME \
        --image $OS_IMAGE_NAME \
        --flavor $OS_FLAVOR_NAME \
        --security-group default --security-group $OS_SEC_GROUPS \
        --property myip=$current_ip \
        $nodename | jq

    status="fail"
    until [ $status == "ACTIVE" ]
    do
        sleep 2
        status=$(openstack server list --name $nodename -f json --noindent | jq ".[0].Status" | tr -d '"' )
        echo "current status: $status"
    done

    openstack server add floating ip $nodename $current_ip

    ssh-keygen -R $current_ip
else
    ips=(${test//,/ })
    current_ip=$(echo ${ips[1]} | tr -d ' ')
fi

export current_ip

# echo "Node $nodename is active with ip: $current_ip"
export ssh_command="ssh -i $OS_KEY -o StrictHostKeyChecking=no -l $OS_USER $current_ip"
# alternative
# openstack server ssh $nodename --login $OS_USER --identity $OS_KEY

until $ssh_command "hostname" 2> /dev/null;
do
    echo "ssh not reachable yet"
    sleep 5
done

# $ssh_command sudo chmod +x /bootstrap
# $ssh_command sudo -H /bootstrap $current_ip $OS_USER
# echo "Done"
