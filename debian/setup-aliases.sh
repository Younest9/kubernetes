#Aliases

echo 'alias k=kubectl' >>~/.bashrc
echo "alias kg='kubectl get'" >>~/.bashrc
echo "alias kgnd='kubectl get nodes'" >>~/.bashrc
echo "alias kgns='kubectl get namespaces'" >>~/.bashrc
echo "alias kgp='kubectl get pods'" >>~/.bashrc
echo "alias kgd='kubectl get deploy'" >>~/.bashrc
echo "alias kgs='kubectl get svc'" >>~/.bashrc
echo "alias kgi='kubectl get ingress'" >>~/.bashrc
echo "alias kgas='kubectl get all -n kube-system'" >>~/.bashrc
echo "alias kga='kubectl get all'" >>~/.bashrc
echo "alias kgaa='kubectl get all -A'" >>~/.bashrc
echo "alias kgan='kubectl get all -n'" >>~/.bashrc
echo "alias kl='kubectl logs'" >>~/.bashrc
echo "alias klf='kubectl logs -f'" >>~/.bashrc
echo "alias ke='kubectl edit'" >>~/.bashrc
echo "alias kd='kubectl delete'" >>~/.bashrc
echo "alias kcf='kubectl create -f'" >>~/.bashrc
echo "alias kaf='kubectl apply -f'" >>~/.bashrc
echo "alias kdf='kubectl delete -f'" >>~/.bashrc
echo "alias kn='kubectl config set-context --current --namespace '" >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
exec bash