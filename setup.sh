#!/bin/bash

args=$@

main() {
    # Setup Python 3 virtual environment for Ansible playbook
    apt update
    apt install -y python3 python3-pip python3-venv
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip \
        && pip install --upgrade setuptools wheel \
        && pip install ansible-core
    ansible-galaxy collection install community.general
    ansible-galaxy collection install community.crypto

    # Setup inception project
    wget https://raw.githubusercontent.com/abdelbenamara/\
    Inception/main/inception-setup-debian.yml
    ansible-playbook inception-setup-debian.yml $args
}

main

exit $?
