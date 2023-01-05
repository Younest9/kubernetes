###Copy config file to .kube directory
cp /etc/rancher/k3s/k3s.yaml /root/.kube/config

###change file permissions
chmod 700 /root/.kube/config

###install helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash