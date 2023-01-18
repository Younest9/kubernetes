helm repo add traefik https://traefik.github.io/charts # https://helm.traefik.io/traefik  ##helm chart of traefik

helm repo update

helm install traefik traefik/traefik --values=traefik-values.yaml

#Access dashboard on localhost

kubectl port-forward -n kube-system “$(kubectl get pods -n kube-system| grep ‘^traefik-‘ | awk ‘{print $1}’)” 9000:9000

#Now you can access it here : http://localhost:9000/dashboard/
