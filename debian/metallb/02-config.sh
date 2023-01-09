#In order to assign an IP to the services, MetalLB must be instructed to do so via the IPAddressPool CR.
#All the IPs allocated via IPAddressPools contribute to the pool of IPs that MetalLB uses to assign IPs to services.
#Note: metallb hand out ip addresses to services type "LoadBalancer" only 
cat <<EOF | tee /root/metallb-pool.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  #Make sure it's not reserved
  - <range-of-ip-addresses>
EOF


#Apply the manifest to specify the ip address pool of metallb 
kubectl apply -f metallb-pool.yaml
