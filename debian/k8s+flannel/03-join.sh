#########################################
# On worker nodes only
#########################################

 
kubeadm join <ip-address-of-cluster>:6443 --token <token-generated> \
        --discovery-token-ca-cert-hash sha256:<sha256-hash-generated> #--cri-socket unix:///var/run/cri-dockerd.sock  ##If necessary