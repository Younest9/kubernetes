#########################################
# On master nodes only
#########################################

kubeadm init --pod-network-cidr=10.244.0.0/16 #--cri-socket unix:///var/run/cri-dockerd.sock  ##If necessary
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

### if you forget to copy the contents after kubeadm init command to print the join command
#kubeadm token create --print-join-command

#install flannel
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/v0.20.2/Documentation/kube-flannel.yml


##Optional
#Bash completion
apt-get install bash-completion

echo "source /usr/share/bash-completion/bash_completion" >> ~/.bashrc
kubectl completion bash | tee /etc/bash_completion.d/kubectl > /dev/null