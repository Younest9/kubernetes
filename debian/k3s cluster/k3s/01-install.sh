##Preconfig (prerequisites)
#Forwarding IPv4 and letting iptables see bridged traffic
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

##Deploy k3s server (cluster) without embedded DB etcd and without traefik
curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=<RELEASE_VERSION> K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="server" K3S_TOKEN=<TOKEN> sh -s - server --cluster-init --disable servicelb #--disable traefik  --cluster-cidr=<SUBNET> # --nocacerts ## ignorer les certificats tls
#curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="server" K3S_TOKEN=z2b8l0n@k3s sh -s - server --cluster-init --disable traefik  --cluster-cidr=10.244.0.0/16 --disable servicelb # disable default Loadbalancer

#Install kubectl to interact with the cluster
apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubectl

##install helm to deploy apps to the cluster easily
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
