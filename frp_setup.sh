#! /bin/bash

# download frp file from github releases
file_name="frp_0.62.1_linux_amd64.tar.gz"

if [ -f "$file_name" ]; then
    echo "\033[32m[INFO] '$file_name' already exists, skip downloading.\033[0m"
else
    echo "[INFO] Downloading $file_name..."
    wget https://github.com/fatedier/frp/releases/download/v0.62.1/$file_name
fi

tar -zxf frp_0.62.1_linux_amd64.tar.gz

setup_frps() {
    echo -e "\033[32m[INFO] Setup frps service...\033[0m"

    mv frp_0.62.1_linux_amd64/frps /usr/local/bin/
    chmod +x /usr/local/bin/frps

    mkdir -p /etc/frp
    mv frp_0.62.1_linux_amd64/frps.toml /etc/frp/

    bash -c 'cat <<EOF > /etc/systemd/system/frps.service
[Unit]
Description=FRP Server Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/frps -c /etc/frp/frps.toml
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF'

    systemctl daemon-reload
    systemctl enable frps
    systemctl start frps
}

setup_frpc() {
    echo -e "\033[32m[INFO] Setup frpc service...\033[0m"

    read -p $'\033[032mInput remote server ip address: ' remote_address

    mv frp_0.62.1_linux_amd64/frpc /usr/local/bin/
    chmod +x /usr/local/bin/frpc

    mkdir -p /etc/frp
        bash -c 'cat <<EOF > /etc/frp/frpc.toml
serverAddr = "$remote_adress"
serverPort = 7000

[[proxies]]
name = "ssh"
type = "tcp"
localIP = "127.0.0.1"
localPort = 22
remotePort = 6000
EOF'

    bash -c 'cat <<EOF > /etc/systemd/system/frpc.service
[Unit]
Description=FRP Server Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/frpc -c /etc/frp/frpc.toml
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF'

    systemctl daemon-reload
    systemctl enable frpc
    systemctl start frpc
}

# select frp client/server
echo -e "\033[32m[INFO] frp will be setup, select server side or client side"
echo -e "\033[32m      [1] server\033[0m"
echo -e "\033[32m      [2] client\033[0m"
while true; do
    read -p $'\033[032mInput number to select: \033[0m' frp_num
    case "$frp_num" in
        1)
            frp_select="server"
            setup_frps
            break
            ;;
        2)
            frp_select="client"
            setup_frpc
            break
            ;;
        3)
            echo -e "\033[31m[ERROR]: invalid input, input 1/2 please"
            ;;
    esac
done