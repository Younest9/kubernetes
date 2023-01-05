sudo ros config set rancher.docker.tls false
docker run -d --restart=unless-stopped -p 9080:80 -p 9443:443 --privileged --name rancher-server rancher/rancher:latest