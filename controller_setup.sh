#!/bin/bash

if [[ `id -u` != 0 ]]; then
    echo "You must run this as root"
    exit 1
fi

# Install packages

yum -y update

yum -y install git

yum -y install vim

yum -y install python3

yum -y install python3-dns

yum -y install python3-netaddr

yum -y install epel-release

yum -y install xrdp

if ! dnf list installed atom; then
    curl -SLo ~/atom.rpm https://atom.io/download/rpm
    dnf -y localinstall ~/atom.rpm
fi

# Get Lab Variables

if ! grep "TF_VAR_LAB_USER" /etc/environment; then
    read -p 'Lab User: ' TF_VAR_LAB_USER
    echo 'export TF_VAR_LAB_USER='$TF_VAR_LAB_USER >> /etc/environment
    source /etc/environment
fi

if ! grep "TF_VAR_LAB_PW" /etc/environment; then
    read -p 'Lab Password: ' TF_VAR_LAB_PW
    echo 'export TF_VAR_LAB_PW='$TF_VAR_LAB_PW >> /etc/environment
    source /etc/environment
fi

if ! grep "TF_VAR_LAB_DOMAIN" /etc/environment; then
    read -p 'Lab Domain: ' TF_VAR_LAB_DOMAIN
    echo 'export TF_VAR_LAB_DOMAIN='$TF_VAR_LAB_DOMAIN >> /etc/environment
    source /etc/environment
fi

if ! grep "TF_VAR_LAB_SUBNET" /etc/environment; then
    read -p 'Lab Subnet: ' TF_VAR_LAB_SUBNET
    echo 'export TF_VAR_LAB_SUBNET='$TF_VAR_LAB_SUBNET >> /etc/environment
    source /etc/environment
fi

if ! grep "TF_VAR_LAB_DNS1" /etc/environment; then
    read -p 'Lab DNS1: ' TF_VAR_LAB_DNS1
    echo 'export TF_VAR_LAB_DNS1='$TF_VAR_LAB_DNS1 >> /etc/environment
    source /etc/environment
fi

if ! grep "_TFLAB_DNS2" /etc/environment; then
    read -p 'Lab DNS2: ' TF_VAR_LAB_DNS2
    echo 'export TF_VAR_LAB_DNS2='$TF_VAR_LAB_DNS2 >> /etc/environment
    source /etc/environment
fi

if ! grep "TF_VAR_LAB_REPO" /etc/environment; then
    read -p 'Lab Repo( e.g. nas.labdomain.local): ' TF_VAR_LAB_REPO
    echo 'export TF_VAR_LAB_REPO='$TF_VAR_LAB_REPO >> /etc/environment
    source /etc/environment
fi

# Configure XRDP

systemctl enable xrdp --now

if ! grep "xrdp8" /etc/xrdp/xrdp.ini; then
    echo '[xrdp8]' >> /etc/xrdp/xrdp.ini
    echo 'name=Reconnect' >> /etc/xrdp/xrdp.ini
    echo 'lib=libvnc.so' >> /etc/xrdp/xrdp.ini
    echo 'username=ask' >> /etc/xrdp/xrdp.ini
    echo 'password=ask' >> /etc/xrdp/xrdp.ini
    echo 'ip=127.0.0.1' >> /etc/xrdp/xrdp.ini
    echo 'port=5901' >> /etc/xrdp/xrdp.ini
fi

if ! firewall-cmd --list-ports | grep "3389"; then
    firewall-cmd --permanent --zone=public --add-port=3389/tcp
    firewall-cmd --reload
fi

# Configure VIM

FILE=/home/$LAB_USER/.vimrc
if [ ! -f  "$FILE" ]; then
    touch "$FILE"
    chown $LAB_USER:$LAB_USER "$FILE"
    echo 'set shiftwidth=2' >> "$FILE"
    echo 'set expandtab' >> "$FILE"
    echo 'set tabstop=4' >> "$FILE"
    echo 'color desert' >> "$FILE"
fi

if ! grep "color" $FILE; then
    echo 'set shiftwidth=2' >> "$FILE"
    echo 'set expandtab' >> "$FILE"
    echo 'set tabstop=4' >> "$FILE"
    echo 'color desert' >> "$FILE"
fi
