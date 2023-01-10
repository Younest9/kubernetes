#disable tls on docker because i don't have ssl certs
sudo ros config set rancher.docker.tls false

#restart docker
sudo system-docker restart docker

#Run a docker container with rancher in it
docker run -d --restart=unless-stopped -p <HOST_PORT_HTTP>:80 -p <HOST_PORT_HTTPS>:443 --privileged --name <CONTAINER_NAME> rancher/rancher:<TAG> # stable - latest - alpha
docker run -d --restart=unless-stopped -p 9080:80 -p 9443:443 --privileged --name rancher-server rancher/rancher:stable
