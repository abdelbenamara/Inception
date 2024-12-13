#!/bin/bash

main() {
    # Setup Python 3 virtual environment for Ansible playbook
    apt update
    apt install -y python3 python3-pip python3-venv
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip \
        && pip install --upgrade setuptools wheel \
        && pip install --upgrade ansible-core passlib
        && ansible-galaxy collection install --upgrade \
            community.general community.crypto

    # Setup inception project
    wget https://raw.githubusercontent.com/abdelbenamara/\
    Inception/main/inception-setup-ubuntu.yml \
        && ansible-playbook inception-setup-ubuntu.yml --ask-become-pass
}

main

exit $?
