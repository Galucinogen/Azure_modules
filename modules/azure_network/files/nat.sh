#!/bin/sh
sudo yum -y update
sudo yum -y install mc
sudo setenforce 0
sudo sed -i.bak 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
sudo sysctl -w net.ipv4.ip_forward=1
sudo sh -c "echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/ip_forward.conf"
sudo firewall-cmd --zone=public --add-masquerade
sudo firewall-cmd --reload