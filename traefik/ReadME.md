# Traefik

Traefik is a reverse proxy and load balancer that routes traffic to different backends. It is a cloud native edge router that is built for dynamic environments. It is designed to integrate with Kubernetes and Docker. It is also designed to be dynamic and self-configuring. It is a single binary that is written in Go. It is also designed to be highly scalable and highly available. It is also designed to be highly modular and pluggable. It is also designed to be highly extensible and flexible. It is also designed to be highly configurable and customizable. It is also designed to be highly secure and reliable. It is also designed to be highly performant and efficient.

## Table of Contents

- [Installation](#installation)
  - [Prerequisites](#prerequisites)
  - [Install Traefik](#install-traefik)
- [Setup Traefik](#setup-traefik)
  - [Setup Traefik Dashboard](#setup-traefik-dashboard)
  - [Setup Traefik Ingress Controller](#setup-traefik-ingress-controller)
  - [Setup Traefik Ingress Route](#setup-traefik-ingress-route)
- [References](#references)

## Installation

### Prerequisites

- A Kubernetes Cluster (k3s, k8s, minikube, microk8s, etc.)
  - For k3s, Traefik is already installed by default
- kubectl
  - Debian-based Linux distributions

    ```bash
    sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2 curl
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    sudo apt-get update && sudo apt-get install -y kubectl
    ```

  - Red Hat-based Linux distributions

    ```bash
    sudo yum install -y kubectl
    ```

  - macOS

    ```bash
    brew install kubectl
    ```

- Helm
  - Debian-based Linux distributions

    ```bash
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    ```

  - Red Hat-based Linux distributions

    ```bash
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    ```

  - macOS

    ```bash
    brew install helm
    ```

### Install Traefik

- Connect to your Kubernetes Cluster
  - You can use kubectl to connect to your Kubernetes Cluster

    ```bash
    kubectl cluster-info
    ```

  - If you aren't connected to your Kubernetes Cluster, you need to copy the kubeconfig file from your Kubernetes Cluster to your local machine

    ```bash
    # For k3s
    scp root@<kubernetes-cluster-ip>:/etc/rancher/k3s/k3s.yaml ~/.kube/config
    # For k8s
    scp root@<kubernetes-cluster-ip>:/etc/kubernetes/admin.conf ~/.kube/config
    # For minikube
    scp root@<kubernetes-cluster-ip>:/root/.kube/config ~/.kube/config
    ```

  - Check if you are connected to your Kubernetes Cluster by running the following command:

    ```bash
    kubectl get nodes
    ```

- Install Traefik using Helm
  - It is recommended to install Traefik in the kube-system namespace (it's already created by default, so you just need to change the namespace in the command below)

    ```bash
    helm repo add traefik https://helm.traefik.io/traefik
    helm repo update
    helm install traefik traefik/traefik -n kube-system
    ```

    - If you want to install Traefik in a different namespace, you need to create the namespace first

        ```bash
        kubectl create namespace <namespace-name>
        ```

    - Then, you need to install Traefik in that namespace

        ```bash
        helm repo add traefik https://helm.traefik.io/traefik
        helm repo update
        helm install traefik traefik/traefik -n <namespace-name>
        ```

## Setup Traefik

### Setup Traefik Dashboard

Traefik doesn't come with a dashboard by default, so you need to enable it.

The dashboard is a web UI that allows you to see the status of your Traefik instance and the services that are running on it.

It doesn't come with authentication by default, so you need to enable it.

- Create a file called `traefik-dashboard-auth.yaml` and add the following content to it:

    ```yaml
    apiVersion: traefik.containo.us/v1alpha1
    kind: Middleware
    metadata:
    name: dashboard-auth
    namespace: kube-system
    spec:
    basicAuth:
        secret: traefik-dashboard-auth-secret
    ```

- Create a file called `traefik-dashboard-auth-secret.yaml` and add the following content to it:

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
        name: traefik-dashboard-auth-secret
        namespace: kube-system
    type: Opaque
    data:
        USERNAME: <base64 encoded username>
        PASSWORD: <base64 encoded password>
    ```

    >Note:
    >
    >- You can change the username and password to whatever you want, but you need to make sure that you encode them in base64.
    >- You can encode them in base64 by running the following command:
    >
    >    ```bash
    >    echo -n '<username>' | base64
    >    echo -n '<password>' | base64
    >    ```
    >
    >- You can also use the following website to encode them in base64: <https://www.base64encode.org/>

- Create a file called `traefik-dashboard.yaml` and add the following content to it:

    ```yaml
    apiVersion: traefik.containo.us/v1alpha1
    kind: IngressRoute
    metadata:
      name: traefik-dashboard
      namespace: kube-system
    spec:
      entryPoints:
        - web
      routes:
        - match: Host(`traefik.example.com`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))
          kind: Rule
          services:
            - name: api@internal
              kind: TraefikService
    ```

    >Note:
    >
    >- You can change the host to whatever you want, but you need to make sure that you have a DNS record for that host.
    >- You can change the path to whatever you want, but you need to make sure that you don't have any other service running on that path.

- Apply the changes

    ```bash
    kubectl apply -f traefik-dashboard-auth.yaml -f traefik-dashboard-auth-secret.yaml -f traefik-dashboard.yaml
    ```

- Check if the changes are applied

    ```bash
    kubectl get ingressroute -n kube-system
    ```

- Check if the secret is created

    ```bash
    kubectl get secret -n kube-system
    ```

- Check if the middleware is created

    ```bash
    kubectl get middleware -n kube-system
    ```

- If you want to use the dashboard on https, you need to change the entrypoint from `web` to `websecure` in the `traefik-dashboard.yaml` file

    ```yaml
    apiVersion: traefik.containo.us/v1alpha1
    kind: IngressRoute
    metadata:
      name: traefik-dashboard
      namespace: kube-system
    spec:
      entryPoints:
        - websecure # web (80) -> websecure (443)
      routes:
        - match: Host(`traefik.example.com`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))
          kind: Rule
          services:
            - name: api@internal
              kind: TraefikService
    ```

- Check if the dashboard is working by going to the host that you specified in the `traefik-dashboard.yaml` file (e.g. `traefik.example.com/dashboard` or `traefik.example.com/api`)

- If you want to tweak traefik configuration, you can do that by creating a file called `traefik-config.yaml` and adding the following content to it:

    ```yaml
    apiVersion: helm.cattle.io/v1
    kind: HelmChartConfig
    metadata:
      name: traefik
      namespace: kube-system
    spec:
      valuesContent: |-
        # Add your custom configuration here 
    ```

    >Note:
    >- You can find an example of a custom configuration in the [`enable-acme.yaml`](templates/enable-acme.yaml) file in the `templates` directory)

    Or you can install Traefik using Helm and pass the configuration as a parameter

    ```bash
    helm repo add traefik https://helm.traefik.io/traefik
    helm repo update
    helm install traefik traefik/traefik -n kube-system --values=traefik-values.yaml
    ```

    >Note:
    >
    >- You can find the [`traefik-values.yaml`](traefik-values.yaml) file in this repository.

### Setup Traefik Ingress Controller

Ingress is a Kubernetes resource that allows you to expose your services to the outside world.

Traefik is an Ingress Controller, which means that it can be used to expose your services to the outside world.

You can use the templates in the [`templates`](templates/Ingress/) directory to create an Ingress resource for your service.

### Setup Traefik Ingress Route

IngressRoute is a Traefik resource that allows you to expose your services to the outside world.

You can use the templates in the [`templates`](templates/IngressRoute/) directory to create an IngressRoute resource for your service.

## References

Here are some references that I used to create this documentation:

- Helm : <https://helm.sh/docs/>

- Traefik Installation : <https://doc.traefik.io/traefik/getting-started/install-traefik/>

- Traefik as an Ingress controller (in french) : <https://www.youtube.com/watch?v=89k4FV6TTlQ>

- How to use Traefik as a Reverse Proxy in Kubernetes : <https://www.youtube.com/watch?v=n5dpQLqOfqM&t=956s>

- Kubernetes Traefik Helm Deployment : <https://github.com/ChristianLempa/boilerplates/tree/main/kubernetes/traefik>

- K3S - Ingress Controller Traefik (in french) <https://gitlab.com/xavki/presentations-kubernetes/-/blob/master/50-k3s-ingress-controller/slides.md>

- Traefik Proxy 2.x and Kubernetes 101 : <https://traefik.io/blog/traefik-proxy-kubernetes-101/>
