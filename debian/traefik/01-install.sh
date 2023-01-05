helm repo add traefik https://traefik.github.io/charts

helm repo update

helm install traefik traefik/traefik --values=traefik-values.yaml
