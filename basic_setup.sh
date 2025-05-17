#!/bin/bash

# set timezone
default_timezone="Asia/Shanghai"
read -p $'\033[32minfo: set timezone(default '"$default_timezone"$'): \033[0m' target_timezone

if [ -z "$target_timezone" ]; then
    target_timezone=$default_timezone
fi

timedatectl set-timezone "$target_timezone"

# update package lists
echo -e "\033[32minfo: updating package lists...\033[0m"
apt update

# install packages
packages=(net-tools vim openssh-server)

to_be_installed=()

for pkg in "${packages[@]}"; do
    if dpkg -s "$pkg" > /dev/null 2>&1; then
        echo -e "\033[32minfo: $pkg installed, skip it\033[0m"
    else
        echo -e "\033[32minfo: $pkg uninstalled, ready to install\033[0m"
        to_be_installed+=("$pkg")
    fi
done

if [ ${#to_install[@]} -gt 0 ]; then
    echo -e "\033[34minfo: start installing: ${to_install[*]}\033[0m"
    apt install -y "${to_install[@]}"
else
    echo -e "\033[32minfo: no more packages need to be installed\033[0m"
fi

# modify sshd_config
echo -e "\033[32minfo: modifing openssh-server configuration to enable remote connect\033[0m"
sed -i '/#PermitRootLogin/c\PermitRootLogin yes' /etc/ssh/sshd_config
sed -i '/#PubkeyAuthentication/c\PubkeyAuthentication yes' /etc/ssh/sshd_config
sed -i '/#PasswordAuthentication/c\PasswordAuthentication yes' /etc/ssh/sshd_config
systemctl restart ssh