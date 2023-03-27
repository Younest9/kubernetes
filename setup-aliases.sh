#!/bin/bash

# Change default editor for kubernetes cluster
echo "# Change default editor for kubernetes cluster"
echo "export KUBE_EDITOR=<FAVORITE_EDITOR>" >>~/.bash_profile

################################################################

# Aliases
echo "">>~/.bashrc
echo "# Alias definitions." >>~/.bashrc
echo "# You may want to put all your additions into a separate file like" >>~/.bashrc
echo "# ~/.bash_aliases, instead of adding them here directly." >>~/.bashrc
echo "# See /usr/share/doc/bash-doc/examples in the bash-doc package." >>~/.bashrc
echo "if [ -f ~/.bash_aliases ]; then">>~/.bashrc
echo "    . ~/.bash_aliases" >>~/.bashrc
echo "fi">>~/.bashrc

echo "# Bash completion">>~/.bash_aliases
echo "source /usr/share/bash-completion/bash_completion">>~/.bash_aliases
echo "" >>~/.bash_aliases

echo "# Some aliases for kubectl" >>~/.bash_aliases
echo "alias k=kubectl" >>~/.bash_aliases
echo "alias kg='kubectl get'" >>~/.bash_aliases
echo "alias kgnd='kubectl get nodes'" >>~/.bash_aliases
echo "alias kgns='kubectl get namespaces'" >>~/.bash_aliases
echo "alias kgp='kubectl get pods'" >>~/.bash_aliases
echo "alias kgd='kubectl get deploy'" >>~/.bash_aliases
echo "alias kgs='kubectl get svc'" >>~/.bash_aliases
echo "alias kgi='kubectl get ingress'" >>~/.bash_aliases
echo "alias kgsct='kubectl get secret'">>~/.bash_aliases
echo "alias kga='kubectl get all'" >>~/.bash_aliases
echo "alias kgaa='kubectl get all -A'" >>~/.bash_aliases
echo "alias kgan='kubectl get all -n'" >>~/.bash_aliases
echo "alias kl='kubectl logs'" >>~/.bash_aliases
echo "alias klf='kubectl logs -f'" >>~/.bash_aliases
echo "alias ke='kubectl edit'" >>~/.bash_aliases
echo "alias kd='kubectl delete'" >>~/.bash_aliases
echo "alias kc='kubectl create'" >>~/.bash_aliases
echo "alias kcf='kubectl create -f'" >>~/.bash_aliases
echo "alias kaf='kubectl apply -f'" >>~/.bash_aliases
echo "alias kdf='kubectl delete -f'" >>~/.bash_aliases
echo "alias kn='kubectl config set-context --current --namespace '" >>~/.bash_aliases
echo "alias kdn='kubectl delete ns'">>~/.bash_aliases
echo "alias kdi='kubectl delete ingress'">>~/.bash_aliases
echo "alias kdsvc='kubectl delete svc'">>~/.bash_aliases
echo "alias kdd='kubectl delete deploy'">>~/.bash_aliases
echo "alias kdsct='kubectl delete secret'">>~/.bash_aliases

echo "# Autocompletion kubectl" >>~/.bash_aliases
echo 'complete -o default -F __start_kubectl k' >>~/.bash_aliases
# Apply aliases
exec bash
# Apply aliases after reboot
echo "# Apply aliases after reboot" >>~/.bash_profile
echo "source ~/.bashrc" >>~/.bash_profile
