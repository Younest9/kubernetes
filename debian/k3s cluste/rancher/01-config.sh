###Prequisities

###config rancher on k3s cluster

##add Helm chart repository that contains charts to install Rancher
#Latest: Recommended for trying out the newest features
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
#Stable: Recommended for production environments
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
#Alpha: Experimental preview of upcoming releases.
helm repo add rancher-alpha https://releases.rancher.com/server-charts/alpha

###Create a Namespace for Rancher
kubectl create namespace cattle-system

###Choose your SSL Configuration
#Rancher Generated Certificates (Default)	: ingress.tls.source=rancher : Requires cert-manager : yes
#Let’s Encrypt : ingress.tls.source=letsEncrypt : Requires cert-manager : yes
#Certificates from Files : ingress.tls.source=secret : Requires cert-manager : no
##Install cert-manager (Required case only)

#This step is only required to use certificates issued by Rancher's generated CA (ingress.tls.source=rancher) or to request Let's Encrypt issued certificates (ingress.tls.source=letsEncrypt).
# If you have installed the CRDs manually instead of with the `--set installCRDs=true` option added to your Helm install command, you should upgrade your CRD resources before upgrading the Helm chart:
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.crds.yaml

# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Update your local Helm chart repository cache
helm repo update

# Install the cert-manager Helm chart
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.7.1
#Verify if it is deployed correctly by checking the cert-manager namespace for running pods
kubectl get pods --namespace cert-manager