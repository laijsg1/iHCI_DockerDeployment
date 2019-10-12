curl -sSL https://get.docker.com | sudo sh
if [[$1]];then
    sudo usermod -aG docker $1
fi
sudo systemctl start docker
sudo pip3 install docker-compose
docker-compose up -d
