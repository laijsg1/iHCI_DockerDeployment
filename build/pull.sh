docker-compose down
docker login
docker tag docker_ihci:latest laisg/_ihci:latest
docker push laisg/docker_ihci:latest
