#Make sure it's not reserved (<range-of-ip-addresses>)

cat <<EOF | tee /root/metallb-pool.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - <range-of-ip-addresses>
EOF

kubectl apply -f /root/metallb-pool.yaml
