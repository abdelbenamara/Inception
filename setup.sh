#!/bin/bash

main() {
    apt update

    # Setup Python 3 virtual environment for Ansible playbook
    apt install -y python3 python3-pip python3-venv
    python3 -m venv inception-venv
    source inception-venv/bin/activate
    pip install --upgrade pip && pip install --upgrade setuptools wheel && pip install ansible-core
    ansible-galaxy collection install community.general

    # Setup inception project
    wget https://raw.githubusercontent.com/abdelbenamara/Inception/main/inception-debian-setup.yml
    ansible-playbook inception-setup-debian.yml
}

main

exit $?
