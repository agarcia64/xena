#!/bin/bash

GIT=1
SSH_CONF=1
HOSTS=1
SSH_KEY=1
FILES=1

if [ $GIT -eq 1 ]; then
    git config --global user.email fulton@redhat.com
    git config --global user.name "John Fulton"
fi

if [ $SSH_CONF -eq 1 ]; then
    if [[ ! -f ~/.ssh/config ]]; then
        echo StrictHostKeyChecking no > ~/.ssh/config
        chmod 0600 ~/.ssh/config
        rm -f ~/.ssh/known_hosts 2> /dev/null
        ln -s /dev/null ~/.ssh/known_hosts
    fi
fi

if [ $HOSTS -eq 1 ]; then
    NODE0="192.168.122.251 overcloud0.example.com overcloud0"
    NODE1="192.168.122.250 overcloud1.example.com overcloud1"
    echo $NODE1 | sudo tee -a /etc/hosts
    ssh 192.168.122.250 "echo $NODE0 | sudo tee -a /etc/hosts"
fi

if [ $SSH_KEY -eq 1 ]; then
    rm -f ~/.ssh/id_ed25519{,.pub}
    ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
    ssh-copy-id -i ~/.ssh/id_ed25519 overcloud0
    ssh-copy-id -i ~/.ssh/id_ed25519 overcloud1
    ssh -i ~/.ssh/id_ed25519 overcloud0 "tail -1 ~/.ssh/authorized_keys"
    ssh -i ~/.ssh/id_ed25519 overcloud1 "tail -1 ~/.ssh/authorized_keys"
fi

if [ $FILES -eq 1 ]; then
    cp -f -v directord-inventory-catalog.yaml ~/
fi