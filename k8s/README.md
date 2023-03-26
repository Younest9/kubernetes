## k8s cluster setup
You can select which part you want by jumping to the section you want.

### Table of Contents

- [0. Disable swap](#0-disable-swap)
- [1. Install Docker](#1-install-docker)
    - [Debian](#debian)
    - [Ubuntu](#ubuntu)
- [2. Install kubeadm, kubelet and kubectl](#2-install-kubeadm-kubelet-and-kubectl)
- [3. Initialize the master node](#3-initialize-the-master-node)
- [4. Join the worker nodes to the cluster](#4-join-the-worker-nodes-to-the-cluster)
- [5. Install a pod network](#5-install-a-pod-network)
- [References](#references)

Please run everything in the root user to avoid permission issues.

### Components

![k8s components](./components-of-kubernetes.svg)

### Architecture

![k8s architecture](./Architecture.png)

### 0. Disable swap

>On both master and worker nodes you need to disable swap. This is required for the kubelet to work properly.

this will disable swap temporarily, will not presist after a reboot:

```bash
swapoff -a
```
Add a hash here before the swap or swap file if present and do a reboot
    
```bash
sed -i '/ swap / s/^/#/' /etc/fstab
```

### 1. Install Docker

- #### Debian

    Uninstall old versions:

    ```bash
    apt-get remove docker docker-engine docker.io containerd runc
    ```

    Set up the repository:
    
    - Update the apt package index and install packages to allow apt to use a repository over HTTPS:
    
        ```bash
        apt-get update
        apt-get install \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg-agent \
            software-properties-common
        ```
    - Add Docker’s official GPG key:
    
        ```bash
        curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
        ```

    - Use the following command to set up the repository:
        
        ```bash
        echo \
        "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
        "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        ```
    Install Docker Engine
    >This procedure works for Debian on `x86_64` / `amd64`, `armhf`, `arm64`, and `Raspbian`.

    - Update the apt package index:
    
        ```bash
        apt-get update
        ```
        > If you are receiving a GPG error when running `apt-get update`, try granting read permission for the Docker public key file before updating the package index:  
        >    ```bash
        >    chmod a+r /etc/apt/keyrings/docker.gpg
        >    apt-get update
        >    ```

    - Install Docker Engine, containerd, and Docker Compose:
        >To install the latest version, run:

        ```bash
        apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        ```
    - Verify that the Docker Engine installation is successful by running the hello-world image:
    
        ```bash
        docker run hello-world
        ```
        >This command downloads a test image and runs it in a container. When the container runs, it prints a confirmation message and exits.

    - Create docker group (optional when using root user)
    
        ```bash
        groupadd docker
        ```
        >This command creates the docker group and adds your user to it. If you need to use Docker as a non-root user or make changes to the Docker daemon configuration, add your user to the docker group.
        >
        >```bash
        >usermod -aG docker $USER
        >```
        >This command logs you out and back in so that your group membership is re-evaluated. If testing on a virtual machine, it may be necessary to restart the virtual machine for changes to take effect.

- #### Ubuntu

    Uninstall old versions:

    ```bash
    apt-get remove docker docker-engine docker.io containerd runc
    ```

    Set up the repository:
    
    - Update the apt package index and install packages to allow apt to use a repository over HTTPS:
    
        ```bash
        apt-get update
        apt-get install \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg-agent \
            software-properties-common
        ```
    - Add Docker’s official GPG key:
    
        ```bash
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
        ```

    - Use the following command to set up the repository:
        
        ```bash
        echo \
        "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        ```
    Install Docker Engine
    >This procedure works for Ubuntu on `x86_64` / `amd64`, `armhf`, `arm64`, and `Raspbian`.

    - Update the apt package index:
    
        ```bash
        apt-get update
        ```
        > If you are receiving a GPG error when running `apt-get update`, try granting read permission for the Docker public key file before updating the package index:  
        >    ```bash
        >    chmod a+r /etc/apt/keyrings/docker.gpg
        >    apt-get update
        >    ```

    - Install Docker Engine, containerd, and Docker Compose:
        >To install the latest version, run:

        ```bash
        apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        ```
    - Verify that the Docker Engine installation is successful by running the hello-world image:
    
        ```bash
        docker run hello-world
        ```
        >This command downloads a test image and runs it in a container. When the container runs, it prints a confirmation message and exits.

    - Create docker group (optional when using root user)
    
        ```bash
        groupadd docker
        ```
        >This command creates the docker group and adds your user to it. If you need to use Docker as a non-root user or make changes to the Docker daemon configuration, add your user to the docker group.
        >
        >```bash
        >usermod -aG docker $USER
        >```
        >This command logs you out and back in so that your group membership is re-evaluated. If testing on a virtual machine, it may be necessary to restart the virtual machine for changes to take effect.

### 2. Install kubeadm, kubelet, and kubectl

- Install and configure prerequisites
  >The following steps apply common settings for Kubernetes nodes on Linux.
  
  Forwarding IPv4 and letting iptables see bridged traffic
    >The following commands enable IPv4 forwarding and allow iptables to see bridged traffic:
    
    ```bash	
    cat <<EOF | tee /etc/modules-load.d/k8s.conf
    overlay
    br_netfilter
    EOF

    sudo modprobe overlay
    sudo modprobe br_netfilter

    # sysctl params required by setup, params persist across reboots
    cat <<EOF | tee /etc/sysctl.d/k8s.conf
    net.bridge.bridge-nf-call-iptables  = 1
    net.bridge.bridge-nf-call-ip6tables = 1
    net.ipv4.ip_forward                 = 1
    EOF

    # Apply sysctl params without reboot
    sudo sysctl --system
    ```
    Verify that the `br_netfilter`, `overlay` modules are loaded by running below instructions:
    
    ```bash
    lsmod | grep br_netfilter
    lsmod | grep overlay
    ```
    Verify that the `net.bridge.bridge-nf-call-iptables`, `net.bridge.bridge-nf-call-ip6tables`, `net.ipv4.ip_forward` system variables are set to 1 in your sysctl config by running below instruction:
        
    ```bash
    sysctl net.bridge.bridge-nf-call-iptables
    sysctl net.bridge.bridge-nf-call-ip6tables
    sysctl net.ipv4.ip_forward
    ```
    >If the output is not 1, run the following commands to set the variables:
    >
    >```bash
    >sysctl -w net.bridge.bridge-nf-call-iptables=1
    >sysctl -w net.bridge.bridge-nf-call-ip6tables=1
    >sysctl -w net.ipv4.ip_forward=1
    >```

    Minimum requirements for the nodes:
    
    - The Kubernetes control plane (the API server, scheduler, and controller manager) can run on any Linux machine in the cluster. However, for each node that you want to add to the cluster, you need to install the following minimum requirements:
    - 1 GB or more of RAM per machine (any less will leave little room for your apps).
    - 2 CPUs or more.
    - Full network connectivity between all machines in the cluster (public or private network is fine).
    - Unique hostname, MAC address, and product_uuid for every node. See [here](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#verify-mac-address) for more details.
    - Certain ports are open on your machines. See [here](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#check-required-ports) for more details.
    - Swap disabled. You MUST disable swap in order for the kubelet to work properly [(see `Disable Swap`)](#0-disable-swap).

    Installing a container runtime:
    >Kubernetes supports several container runtimes: `Docker`, `containerd`, `CRI-O`, and any implementation of the Kubernetes CRI (Container Runtime Interface). You can read more about the Kubernetes CRI [here](https://kubernetes.io/docs/setup/production-environment/container-runtimes/).
    >
    >The container runtime that you use depends on the container runtime that your Kubernetes nodes use. For example, if you have nodes that use Docker, then Docker is a requirement for your Kubernetes cluster.
    >
    >If you are using Docker, it is recommended to use Docker as the container runtime for Kubernetes as well. This is because Docker is tightly integrated with Kubernetes through the built-in `dockershim` CRI implementation. Using `Docker` as the container runtime for Kubernetes allows you to leverage work already done by the Kubernetes community.
    >
    >If you are not using Docker, you need to choose and install a container runtime that is compatible with the CRI interface used by Kubernetes. The Kubernetes community has tested and maintains a list of compatible container runtimes and `CRI-Containerd` and `CRI-O` are the two recommended runtimes. You can read more about the `CRI-Containerd` [here](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd) and `CRI-O` [here](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#cri-o).
    >
    - If you are using `Docker`, you can install it using the following commands:
        >For now, we will use `Docker` as the container runtime, because i tried `containerd` and it didn't work.
    
        ```bash
        git clone https://github.com/Mirantis/cri-dockerd.git
        # Install GO
        wget https://storage.googleapis.com/golang/getgo/installer_linux
        chmod +x ./installer_linux
        ./installer_linux
        source ~/.bash_profile
        # Install cri-dockerd
        cd cri-dockerd
        mkdir bin
        go build -o bin/cri-dockerd
        mkdir -p /usr/local/bin
        install -o root -g root -m 0755 bin/cri-dockerd /usr/local/bin/cri-dockerd
        cp -a packaging/systemd/* /etc/systemd/system
        sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
        systemctl daemon-reload
        systemctl enable cri-docker.service
        systemctl enable --now cri-docker.socket
        ```
        >If you are using `Docker` as the container runtime, you can skip the next step.

    - If you are using `containerd` or `CRI-O`, you can install it using the following commands:
        >As i mentied before, i tried `containerd` and it didn't work, you can try it if you want.
        
        ```bash
        # Install containerd
        apt-get update && apt-get install -y containerd
        # Configure containerd
        mkdir -p /etc/containerd
        containerd config default | tee /etc/containerd/config.toml
        # Restart containerd
        systemctl restart containerd
        ```
        >If you are using `containerd` or `CRI-O` as the containerruntime, you can skip the next step.

        Also, you need to configure the kubelet to use a remote CRI runtime. See [here](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd) for more details.

- Installing `kubeadm`, `kubelet`, and `kubectl`:
    - Debian-based distributions:

        ```bash
        # Update the apt package index and install packages needed to use the Kubernetes apt repository:
        apt-get update
        apt-get install -y apt-transport-https ca-certificates curl
        # Add the Google Cloud public signing key:
        curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
        # Add the Kubernetes apt repository:
        deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main | tee /etc/apt/sources.list.d/kubernetes.list
        # Update apt package index, and install packages needed for kubeadm, and pin their version:
        apt-get update
        apt-get install -y kubelet kubeadm kubectl
        apt-mark hold kubelet kubeadm kubectl
        ```
    - Red Hat-based distributions:

        ```bash
        cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
        [kubernetes]
        name=Kubernetes
        baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
        enabled=1
        gpgcheck=1
        gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
        exclude=kubelet kubeadm kubectl
        EOF

        # Set SELinux in permissive mode (effectively disabling it)
        sudo setenforce 0
        sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

        sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

        sudo systemctl enable --now kubelet
        ```
        >Notes:
        >
        >- Setting SELinux in permissive mode by running setenforce 0 and sed ... effectively disables it. This is required to allow containers to access the host filesystem, which is needed by pod networks for example. You have to do this until SELinux support is improved in the kubelet.
        >
        >- You can leave SELinux enabled if you know how to configure it but it may require settings that are not supported by kubeadm.
        >
        >- If the baseurl fails because your Red Hat-based distribution cannot interpret basearch, replace \$basearch with your computer's architecture. Type uname -m to see that value. For example, the baseurl URL for x86_64 could be: https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64.

    Verify that the installation was successful:

    ```bash
    kubeadm version
    ```
    
- Cleanup (Optional)
    ```bash	
    # Delete the cri-dockerd folder, and the go folder and the installer_linux file
    cd
    rm -r installer_linux cri-dockerd/ go/
    ```
### 3. Creating a single control-plane cluster with `kubeadm`:


- Initializing the control-plane node:

    ```bash
    # We are using the docker container runtime, so we are using the --cri-socket flag, and we are naming the node cp-1
    kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock --node-name=cp-1  # You can use any CIDR range
    ```
    >Notes:
    >
    >- You can use any CIDR range, but it is recommended to use the default CIDR range. In this example, we are using 10.244.0.0/16 as the CIDR range because it is the default CIDR range for the `flannel` pod network (Refer to [this](https://github.com/flannel-io/flannel#deploying-flannel-manually) for more information).
    >
    >- You can use the `--cri-socket` flag to set the CRI socket to use. If you do not set the socket, `kubeadm` will use the default socket for the container runtime you are using.
    >
    >- You can use the `--dry-run` flag to see what the `kubeadm` command will do without actually running it.
    >
    >- You can use the `--node-name` flag to set the node name. If you do not set the name, `kubeadm` will use the node's hostname as the name.
    >
    >- You can use the `--ignore-preflight-errors` flag to ignore one or more preflight errors. If you do not set this flag, `kubeadm` will stop if it encounters a preflight error.
    >
    >I stated just the important flags up here, to add more, see the [kubeadm reference documentation](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/).

    The output should look like this:

    ```bash
    [init] Using Kubernetes version: v1.20.2
    [preflight] Running pre-flight checks
    [preflight] Pulling images required for setting up a Kubernetes cluster
    [preflight] This might take a minute or two, depending on the speed of your internet connection
    [preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
    [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
    [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
    [kubelet-start] Starting the kubelet
    [certs] Using certificateDir folder "/etc/kubernetes/pki"
    [certs] Generating "ca" certificate and key
    [certs] Generating "apiserver" certificate and key
    ...
    [certs] Generating "apiserver-kubelet-client" certificate and key
    [certs] Generating "front-proxy-ca" certificate and key
    [certs] Generating "front-proxy-client" certificate and key
    [certs] Generating "etcd/ca" certificate and key
    [certs] Generating "etcd/server" certificate and key
    ...
    [certs] Generating "etcd/peer" certificate and key
    [certs] Generating "etcd/healthcheck-client" certificate and key
    [certs] Generating "apiserver-etcd-client" certificate and key
    [certs] Generating "sa" key and public key
    [kubeconfig] Using kubeconfig folder "/etc/kubernetes"
    [kubeconfig] Writing "admin.conf" kubeconfig file
    [kubeconfig] Writing "kubelet.conf" kubeconfig file
    [kubeconfig] Writing "controller-manager.conf" kubeconfig file
    [kubeconfig] Writing "scheduler.conf" kubeconfig file
    [control-plane] Using manifest folder "/etc/kubernetes/manifests"
    [control-plane] Creating static Pod manifest for "kube-apiserver"
    [control-plane] Creating static Pod manifest for "kube-controller-manager"
    [control-plane] Creating static Pod manifest for "kube-scheduler"
    ...
    [etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
    [wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
    [apiclient] All control plane components are healthy after 31.501735 seconds
    [upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
    [kubelet] Creating a ConfigMap "kubelet-config-1.20" in namespace kube-system with the configuration for the kubelets in the cluster
    [upload-certs] Skipping phase. Please see --upload-certs
    [mark-control-plane] Marking the node cp-1 as control-plane by adding the label "node-role.kubernetes.io/master=''"
    [mark-control-plane] Marking the node cp-1 as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]

    ```
    >Notes:
    >

    >- The `kubeadm init` command will create a `kube-system` namespace, and a `kubeadm-config` ConfigMap in that namespace.
    >


- Copying the kubeconfig file to the `~/.kube` directory:

    ```bash
    mkdir -p $HOME/.kube
    cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    chown $(id -u):$(id -g) $HOME/.kube/config
    ```

- Installing the pod network add-on:

    You need to choose a pod network add-on, and a container runtime. You can install a pod network add-on `flannel` with the following command:

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
    ```
    >Notes:
    >  
    >  - You can install other pod network add-ons instead of `flannel` like `Calico`.
    >
    >  - You can install a pod network add-on with the following command:
    >
    >    ```bash
    >    kubectl apply -f <add-on.yaml>
    >    ```
    >    You can find more information about pod networks [here](https://kubernetes.io/docs/concepts/cluster-administration/addons/).


- Checking the status of the cluster:

    ```bash
    kubectl get pods --all-namespaces
    ```

### 4. Joining nodes:

    You can join any number of worker nodes by running the following on each as root:
    ```bash
    kubeadm join <ip-address-of-cluster>:6443 --token <token-generated> \
            --discovery-token-ca-cert-hash sha256:<sha256-hash-generated> --cri-socket unix:///var/run/cri-dockerd.sock
    ```

    >#### Notes:
    >
    >  - You can get the token and hash by running the following command on the master node:
    >
    >    ```bash
    >    kubeadm token list
    >    ```
    >
    >  - You can get the token and hash by running the following command on the master node:
    >
    >    ```bash
    >    kubeadm token create --print-join-command
    >    ```

### 5. Deleting the cluster:

You can delete the cluster by running the following command on the master node:
```bash
kubeadm reset
```
>Notes:
>
>- You can use `-f` flag to force reset.
>- You can delete the cluster by running the following command on the worker nodes:
>
>    ```bash
>    kubeadm reset
>    ```
>   You can use `-f` flag to force reset on worker nodes as well

### 6. Cleaning up the nodes:

You can clean up the nodes by running the following commands on the master and worker nodes:
```bash
rm -rf /etc/cni /etc/kubernetes /var/lib/dockershim /var/lib/etcd /var/lib/kubelet /var/run/kubernetes ~/.kube/*
```
> This will delete all the files and directories created by kubeadm.

You can reset the iptables by running the following commands on the master and worker nodes:
```bash
iptables -F && iptables -X
iptables -t nat -F && iptables -t nat -X
iptables -t raw -F && iptables -t raw -X
iptables -t mangle -F && iptables -t mangle -X
```

You can uninstall docker and kubernetes related packages by running the following commands on the master and worker nodes:
```bash
apt-get purge kubeadm kubectl kubelet kubernetes-cni kube*
apt-get remove docker docker-engine docker.io containerd runc

apt-get autoremove
```

#### References:

- Kubernetes documentation: https://kubernetes.io/docs/home/
    - Kubeadm: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
    - Container runtime : https://kubernetes.io/docs/setup/production-environment/container-runtimes/
    - Pod network add-ons: https://kubernetes.io/docs/concepts/cluster-administration/addons/
    - kubeadm reset: https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-reset/
    - kubeadm token: https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-token/
    - kubeadm token create --print-join-command: https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-token/create/#options
    - Kubeadm documentation: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/
- Docker documentation: https://docs.docker.com/engine/install
    - Ubuntu: https://docs.docker.com/engine/install/ubuntu/
    - Debian: https://docs.docker.com/engine/install/debian/
- Flannel documentation: 
    - Flannel GitHub: https://github.com/flannel-io/flannel#deploying-flannel-manually
- NetworkChuck k8s video: https://www.youtube.com/watch?v=7bA0gTroJjw&t=890s