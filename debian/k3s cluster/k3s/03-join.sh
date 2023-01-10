#Join k3s agent (worker node) to the server (k3s cluster) 
curl -sfL https://get.k3s.io | K3S_TOKEN=<TOKEN> INSTALL_K3S_EXEC="agent" sh -s - --server https://<IP-ADDRESS-OF-SERVER>:6443 -
#curl -sfL https://get.k3s.io | K3S_TOKEN=z2b8l0n@k3s INSTALL_K3S_EXEC="agent" sh -s - --server https://172.20.51.6:6443 -

#Labeling k3s agent (worker node)
kubectl label nodes <HOSTNAME-OF-THE-NODE>  kubernetes.io/role=worker # --overwrite if necessary
#kubectl label nodes workernode  kubernetes.io/role=worker
