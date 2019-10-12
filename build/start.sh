curl -sSL https://get.docker.com | sudo sh
if [[$1]];then
    sudo usermod -aG docker $1
fi
sudo systemctl start docker
sudo pip3 install docker-compose
mkdir Docker && cd Docker
docker-compose up -d
