cat <<EOF | tee ~/traefik-update.yaml
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: traefik
  namespace: kube-system
spec:
  valuesContent: |-
    additionalArguments:
      - "--api.dashboard=true"
      - "--log.level=DEBUG"
      #- "--certificatesresolvers.le.acme.email=<MAIL_ADDRESS>"
      #- "--certificatesresolvers.le.acme.storage=/data/acme.json"
      #- "--certificatesresolvers.le.acme.tlschallenge=true"
      #- "--certificatesresolvers.le.acme.caServer=https://acme-staging-v02.api.letsencrypt.org/directory"
EOF
kubectl apply -f ~/traefik-update.yaml
