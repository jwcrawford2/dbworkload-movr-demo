#!/usr/bin/bash
# Install required Python components
sudo yum install gcc -y
sudo amazon-linux-extras install python3.8
sudo pip3.8 install -U pip
pip3 install psycopg[binary]
# Install dbworkload
pip3 install dbworkload[postgres]
