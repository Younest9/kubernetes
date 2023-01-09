#PreConfig

#If you’re using kube-proxy in IPVS mode, since Kubernetes v1.14.2 you have to enable strict ARP mode.
#Note, you don’t need this if you’re using kube-router as service-proxy because it is enabling strict ARP by default.
#You can achieve this by editing kube-proxy config in current cluster by using these commands:
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system


#To install MetalLB, apply the manifest
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml