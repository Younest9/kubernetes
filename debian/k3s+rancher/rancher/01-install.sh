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


###Install Rancher with Helm and Your Chosen Certificate Option
#This final command to install Rancher requires a domain name that forwards traffic to Rancher. If you are using the Helm CLI to set up a proof-of-concept, you can use a fake domain name when passing the hostname option. An example of a fake domain name would be <IP_OF_LINUX_NODE>.sslip.io, which would expose Rancher on an IP where it is running. Production installs would require a real domain name.

##Rancher-generated Certificates:
helm install rancher rancher-<CHART_REPO>/rancher \
  --namespace cattle-system \
  --set replicas=<NUMBER_OF_REPLICAS>
  --set hostname=<IP_OF_LINUX_NODE>.sslip.io \ #Or specify the domaine name if you have it
  --set bootstrapPassword=<PASSWORD_OF_UI_DASHBOARD>
#If you are installing an alpha version, Helm requires adding the --devel option to the install command:
helm install rancher rancher-alpha/rancher --devel

##Let's Encrypt
#hostname is set to the public DNS record,
#Set the bootstrapPassword to something unique for the admin user.
#ingress.tls.source is set to letsEncrypt
#letsEncrypt.email is set to the email address used for communication about your certificate (for example, expiry notices)
#Set letsEncrypt.ingress.class to whatever your ingress controller is, e.g., traefik, nginx, haproxy, etc.
helm install rancher rancher-<CHART_REPO>/rancher \
  --namespace cattle-system \
  --set hostname=<IP_OF_LINUX_NODE>.sslip.io \ #Or specify the domaine name if you have it
  --set replicas=<NUMBER_OF_REPLICAS> \
  --set bootstrapPassword=<PASSWORD_OF_UI_DASHBOARD> \
  --set ingress.tls.source=letsEncrypt \
  --set letsEncrypt.email=<EMAIL_ADDRESS_OF_LETS_ENCRYPT> \
  --set letsEncrypt.ingress.class=<INGRESS_CONTROLLER>
#for alpha version, it's the same as Rancher-generated Certificates

##Certificates from Files
#Set the hostname.
#Set the bootstrapPassword to something unique for the admin user.
#Set ingress.tls.source to secret.
helm install rancher rancher-<CHART_REPO>/rancher \
  --namespace cattle-system \
  --set hostname=<IP_OF_LINUX_NODE>.sslip.io \ #Or specify the domaine name if you have it
  --set replicas=<NUMBER_OF_REPLICAS> \
  --set bootstrapPassword=<PASSWORD_OF_UI_DASHBOARD> \
  --set ingress.tls.source=secret
#for alpha version, it's the same as Rancher-generated Certificates
#If you are using a Private CA signed certificate , add --set privateCA=true to the command:
helm install rancher rancher-<CHART_REPO>/rancher \
  --namespace cattle-system \
  --set hostname=<IP_OF_LINUX_NODE>.sslip.io \ #Or specify the domaine name if you have it
  --set replicas=<NUMBER_OF_REPLICAS> \
  --set bootstrapPassword=<PASSWORD_OF_UI_DASHBOARD> \
  --set privateCA=true
  
##Verify that the Rancher Server is Successfully Deployed
#Wait for Rancher to be rolled out:
kubectl -n cattle-system rollout status deploy/rancher
#Waiting for deployment "rancher" rollout to finish: 0 of 3 updated replicas are available...
#deployment "rancher" successfully rolled out

#If you see the following error: error: deployment "rancher" exceeded its progress deadline, you can check the status of the deployment by running the following command:
kubectl -n cattle-system get deploy rancher
#NAME      DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
#rancher   3         3         3            3           3m

###Save Your Options
##Make sure you save the --set options you used. You will need to use the same options when you upgrade Rancher to new versions with Helm.

###Finishing Up
##That's it. You should have a functional Rancher server.
##In a web browser, go to the DNS name that forwards traffic to your load balancer. Then you should be greeted by the colorful login page.