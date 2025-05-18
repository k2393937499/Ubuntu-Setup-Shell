#!/bin/bash

# set timezone
default_timezone="Asia/Shanghai"
echo -e "\033[32mInfo: timezone will be set, you can check avaiable timezone on https://manpages.ubuntu.com/manpages/xenial/man3/DateTime::TimeZone::Catalog.3pm.html\033[0m"
while true; do
    read -p $'\033[32mInfo: set timezone(default '"$default_timezone"$', "skip" to skip): \033[0m' target_timezone
    target_timezone=${target_timezone:-$default_timezone}

    if [ -f "/usr/share/zoneinfo/$target_timezone" ]; then
        timedatectl set-timezone "$target_timezone"
        break
    elif [["$target_timezone" =~ ^[Ss][Kk][Ii][Pp]$]]; then
        :
        break
    else
        echo -e "\033[31mError: invalid timezone, check the input please"
    fi
done

# update package lists
echo -e "\033[32mInfo: updating package lists...\033[0m"
apt update

# install packages
packages=(net-tools wget vim openssh-server)

echo -e "\033[32mInfo: the following packages will be installed, ${packages[@]}\033[0m"

to_be_installed=()

for pkg in "${packages[@]}"; do
    if dpkg -s "$pkg" > /dev/null 2>&1; then
        :
        # echo -e "\033[32minfo: $pkg installed, skip it\033[0m"
    else
        # echo -e "\033[32minfo: $pkg uninstalled, ready to install\033[0m"
        to_be_installed+=("$pkg")
    fi
done

if [ ${#to_install[@]} -gt 0 ]; then
    echo -e "\033[32mInfo: start installing: ${to_install[*]}\033[0m"
    apt install -y "${to_install[@]}"
else
    echo -e "\033[32mInfo: no more packages need to be installed, skip all\033[0m"
fi

# modify sshd_config
modify_sshd="y"
while true; do
    read -p $'\033[32mInfo: modify openssh-server configuration(y/n, default '"$modify_sshd"$'): \033[0m' target_modify
    target_modify=${target_modify:-$modify_sshd}

    case "$target_modify" in 
        [Yy])
            sed -i '/#PermitRootLogin/c\PermitRootLogin yes' /etc/ssh/sshd_config
            sed -i '/#PubkeyAuthentication/c\PubkeyAuthentication yes' /etc/ssh/sshd_config
            sed -i '/#PasswordAuthentication/c\PasswordAuthentication yes' /etc/ssh/sshd_config
            systemctl restart ssh
            break
            ;;
        [Nn])
            :
            break
            ;;
        *)
            echo -e "\033[31mError: invalid input, input "y/n" please"
    esac
done
    

# if [ -z "$target_modify" ] || [ "$target_modify" == "yes" ] || [ "$target_modify" == "y" ]; then
#     target_modify=$modify_sshd
# elif [ "$target_modify" == "yes" ] || [ "$target_modify" == "y" ]; then
#     :
# else

# echo -e "\033[32minfo: modifing openssh-server configuration to enable remote connect\033[0m"
# sed -i '/#PermitRootLogin/c\PermitRootLogin yes' /etc/ssh/sshd_config
# sed -i '/#PubkeyAuthentication/c\PubkeyAuthentication yes' /etc/ssh/sshd_config
# sed -i '/#PasswordAuthentication/c\PasswordAuthentication yes' /etc/ssh/sshd_config
# systemctl restart ssh