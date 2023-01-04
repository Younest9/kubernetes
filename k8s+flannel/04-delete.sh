kubeadm reset -f

#remove all files related to kubernetes
rm -rf /etc/cni /etc/kubernetes /var/lib/dockershim /var/lib/etcd /var/lib/kubelet /var/run/kubernetes ~/.kube/*

iptables -F && iptables -X
iptables -t nat -F && iptables -t nat -X
iptables -t raw -F && iptables -t raw -X
iptables -t mangle -F && iptables -t mangle -X

apt-get purge kubeadm kubectl kubelet kubernetes-cni kube*
apt-get remove docker docker-engine docker.io containerd runc

apt-get autoremove