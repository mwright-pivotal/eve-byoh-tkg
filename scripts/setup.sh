#!/bin/bash -x
sudo apt update
sudo apt-get install socat ebtables ethtool conntrack -y

wget https://github.com/vmware-tanzu/cluster-api-provider-bringyourownhost/releases/download/v0.2.0/byoh-hostagent-linux-amd64
chmod a+x byoh-hostagent-linux-amd64
sudo mv byoh-hostagent-linux-amd64 /usr/local/bin/.

sudo mkdir /etc/byoh-tkg
sudo touch /etc/byoh-tkg/management-cluster.conf

cat > /etc/systemd/system/tkg-byoh.service << EOF

[Unit]
Description=TKG BYOH agent

[Service]
User=root
WorkingDirectory=/var/tmp
ExecStart=/usr/local/bin/byoh-hostagent-linux-amd64 --kubeconfig /etc/byoh-tkg/management-cluster.conf > /var/log/agent.log 2>&1
Restart=always

StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=VMwareTKG

[Install]
WantedBy=multi-user.target

EOF

sudo systemctl daemon-reload
sudo systemctl enable  tkg-byoh.service
sudo systemctl start tkg-byoh.service
sudo systemctl enable ssh
sudo systemctl start ssh


