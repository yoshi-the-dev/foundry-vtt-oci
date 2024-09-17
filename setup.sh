#!/bin/bash

sudo iptables -I INPUT 6 -m state --state NEW -p tcp --match multiport --dports 80,443,3000 -j ACCEPT && sudo netfilter-persistent save && \
sudo apt install -y ca-certificates curl gnupg nodejs nano unzip && \
sudo mkdir -p /etc/apt/keyrings && \
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list && \
sudo apt update && \
sudo npm install pm2 -g && \
pm2 startup && \
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu && \
mkdir ~/foundry && \
wget --output-document ~/foundry/foundryvtt.zip "TEMPLINK" && \
unzip ~/foundry/foundryvtt.zip -d ~/foundry && \
rm -rf ~/foundry/foundryvtt.zip && \
mkdir -p ~/foundryuserdata && \
pm2 start "node /home/ubuntu/foundry/resources/app/main.js --dataPath=/home/ubuntu/foundryuserdata" --name foundry && \
pm2 save
