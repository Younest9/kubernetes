#Join k3s agent (worker node) to the server (k3s cluster) 
curl -sfL https://get.k3s.io | K3S_TOKEN=<TOKEN> INSTALL_K3S_EXEC="agent" sh -s - --server https://<IP-ADDRESS-OF-SERVER>:6443 -


#Labeling k3s agent (worker node)
kubectl label nodes <HOSTNAME-OF-THE-NODE>  kubernetes.io/role=workernode # --overwrite if necessary