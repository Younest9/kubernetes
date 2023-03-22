###Copy config file to .kube directory
cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config

###change file permissions
chmod 644 $HOME/.kube/config

### Send the kubeconfig file to your personal workstation to interact with the cluster from there
## Warning!!! do not forget to backup any kubeconfig file located in ~/.kube/ because this command below will overwrite any existing kubeconfig
scp $HOME/.kube/config <USERNAME>@<IP_ADDRESS_OF_WORKSTATION>:~/.kube/config
#Or
#scp <USERNAME>@<IP_ADDRESS_OF_WORKSTATION>:~/.kube/config ~/.kube/config
