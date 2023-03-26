## k3s cluster setup

You can select which part you want by jumping to the section you want.

### Table of Contents

- [Overview](#overview)
- [What is K3s?](#what-is-k3s)
- [Naming](#naming)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [References](#references)

### Overview

K3s is a Lightweight Kubernetes. Easy to install, half the memory, all in a binary of less than 100 MB.

Great for:

- Edge
- IoT
- CI
- Development
- ARM
- Embedding K8s
- Situations where a PhD in K8s clusterology is infeasible

### What is K3s?

K3s is a fully compliant Kubernetes distribution with the following enhancements:

- Packaged as a single binary
- Lightweight storage backend based on SQLite3 as the default storage mechanism. etcd3, MySQL, and Postgres also still available.
- Wrapped in simple launcher that handles a lot of the complexity of TLS and options.
- Secure by default with reasonable defaults for lightweight environments.
- Simple but powerful "batteries-included" features have been added, such as:
  - Service load balancer
  - Helm controller
  - Local storage provider
  - Traefik ingress controller

- Operation of all Kubernetes control plane components is encapsulated in a single binary and process. This allows K3s to automate and manage complex cluster operations like distributing certificates.
- External dependencies have been minimized (just a modern kernel and cgroup mounts needed). K3s packages the required dependencies, including:
  - containerd
  - Flannel (CNI)
  - CoreDNS
  - Host utilities (iptables, socat, etc)
  - Ingress controller (traefik)
  - Embedded service load balancer (klipper-lb)
  - Embedded network policy controller (kube-router)
  - Embedded local-path-provisioner

### Naming

K3s installation is an installation of Kubernetes that is half the size in terms of memory footprint. Kubernetes is a 10-letter word stylized as K8s. So something half as big as Kubernetes would be a 5-letter word stylized as K3s. There is no long form of K3s and no official pronunciation.

### Architecture

![Architecture](./Architecture%20k3s.svg)

### Prerequisites

K3s is very lightweight, but has some minimum requirements as outlined below.

Whether you're configuring K3s to run in a container or as a native Linux service, each node running K3s should meet the following minimum requirements. These requirements are baseline for K3s and its packaged components, and do not include resources consumed by the workload itself.

- Two nodes cannot have the same hostname.

    >If multiple nodes will have the same hostname, or if hostnames may be reused by an automated provisioning system, use the --with-node-id option to append a random suffix for each node, or devise a unique name to pass with --node-name or $K3S_NODE_NAME for each node you add to the cluster.
- <Strong>Architecture:</Strong> K3s is available for the following architectures:

    - x86_64
    - armhf
    - arm64/aarch64
        >On `arm64/aarch64` systems, the OS must use a 4k page size. RHEL9, Ubuntu, and SLES all meet this requirement.
    - s390x
- <Strong>Operating Systems:</Strong> K3s is expected to work on most modern Linux systems. Some OSs have specific requirements:
    - If you are using (Red Hat/CentOS) Enterprise Linux, follow [these steps]() for additional setup (SELinux, firewalld, etc.)
    - If you are using Raspberry Pi OS, follow [these steps]() to switch to legacy iptables.
    >For more information on which OSs were tested with Rancher managed K3s clusters, refer to the [Rancher support and maintenance terms](https://rancher.com/support-maintenance-terms/).
- <Strong>Hardware:</Strong> Hardware requirements scale based on the size of your deployments. Minimum recommendations are outlined here.

    | Spec | Minimum | Recommended |
    | --- | --- | --- |
    | CPU	| 1 core	| 2 cores |
    | RAM	| 512 MB	| 1 GB |


    >[Resource Profiling](https://docs.k3s.io/reference/resource-profiling) captures the results of tests to determine minimum resource requirements for the K3s agent, the K3s server with a workload, and the K3s server with one agent. It also contains analysis about what has the biggest impact on K3s server and agent utilization, and how the cluster datastore can be protected from interference from agents and workloads.

    - <Strong>Disks:</Strong> K3s performance depends on the performance of the database. To ensure optimal speed, we recommend using an SSD when possible. Disk performance will vary on ARM devices utilizing an SD card or eMMC.

- <strong>Networking:</Strong> Inbound Rules for K3s Server Nodes:

    | Protocol | Port | Source | Destination | Description |
    | --- | --- | --- | --- | --- |
    | TCP | 2379-2380 | Servers	| Servers |	Required only for HA with embedded etcd |
    | TCP |	6443 | Agents | Servers | K3s supervisor and Kubernetes API Server |
    | UDP |	8472 | All nodes | All nodes | Required only for Flannel VXLAN |
    | TCP |	10250 |	All nodes | All nodes |	Kubelet metrics |
    | UDP |	51820 |	All nodes |	All nodes |	Required only for Flannel Wireguard with IPv4 |
    | UDP | 51821 |	All nodes |	All nodes |	Required only for Flannel Wireguard with IPv6 |

    Typically, all outbound traffic is allowed.

    Additional changes to the firewall may be required depending on the OS used. See [Additional OS Preparations](https://docs.k3s.io/advanced#additional-os-preparations).


- Configure iptables (If necessary)
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

### Installation

- Deploy k3s server (cluster)
    
    ```bash
    curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=<RELEASE_VERSION> K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="server" K3S_TOKEN=<TOKEN> sh -s - server --cluster-init
    ```
    >- Replace `<RELEASE_VERSION>` with the version of k3s you want to install. For example, `v1.21.3+k3s1`. If you don't specify a version, the latest version will be installed.
    >
    >- Replace `<TOKEN>` with the token you want to use to join the cluster. If you don't specify a token, a random token will be generated.
    >
    >- You can also specify the `--cluster-cidr` flag to specify the CIDR range for the cluster. For example, `--cluster-cidr=10.244.0.0/16`".
    >
    >- You can pretty much disable anything you don't want to run on the server by adding `--disable` flags. For example, `--disable traefik` or `--disable servicelb` or `--disable local-storage`"`.
    >
    >- You can Also disable flannel by adding `--disable-network-policy` flag. For example, `--disable-network-policy"`.
    >
    >- You can also use `--flannel-backend=none` to disable flannel.
    >
    >- You can also specify the `--node-label` flag to specify the labels for the node. For example, `--node-label=foo=bar`".
    >
    >- You can add --nocacert flag to disable the generation of the CA certificate and key.
    >
    >For more information about the installation options, see [Install Options](https://docs.k3s.io/installation/install-options/).

- Deploy k3s agent (node)

    ```bash
    curl -sfL https://get.k3s.io | K3S_TOKEN=<TOKEN> INSTALL_K3S_EXEC="agent" sh -s - --server https://<IP-ADDRESS-OF-SERVER>:6443 -
    ```
    >- Replace `<TOKEN>` with the token you want to use to join the cluster. If you don't specify a token, a random token will be generated.
    >
    >- Replace `<SERVER_IP>` with the IP address of the server.
    >
    >- You can also specify the `--node-label` flag to specify the labels for the node. For example, `--node-label=foo=bar`".

### Configuration
> It's best to run the following commands in root user to avoid any permission issues.
- Config file location:

    - K3s Server:

        ```bash
        /etc/rancher/k3s/k3s.yaml
        ```

    - K3s Agent:

        ```bash
        /etc/rancher/k3s/k3s.yaml
        ```
- Copy config file to .kube directory

    ```bash
    sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
    ```
- Set config file permissions

    ```bash
    sudo chmod 600 ~/.kube/config
    ```
- Set config file ownership

    ```bash
    sudo chown $(id -u):$(id -g) ~/.kube/config
    ```
- Install kubectl

    ```bash
    sudo apt-get update && apt-get install -y apt-transport-https
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
    sudo apt-get install -y kubectl
    ```

- Install helm

    ```bash
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    ```
- Export the kubeconfig file to your personal workstation to interact with the cluster from there (Optional)

    ```bash
    scp root@<SERVER_IP>:/etc/rancher/k3s/k3s.yaml ~/.kube/config
    ```
> Replace `<SERVER_IP>` with the IP address of the server.

### Uninstallation
- Uninstall k3s server (cluster)
    ```bash
    /usr/local/bin/k3s-uninstall.sh
    ```
- Uninstall k3s agent (worker node)
    ```bash
    /usr/local/bin/k3s-agent-uninstall.sh
    ```

### Troubleshooting
- Check k3s server logs

    ```bash
    journalctl -u k3s
    ```
- Check k3s agent logs

    ```bash
    journalctl -u k3s-agent
    ```
- Check k3s server status

    ```bash
    systemctl status k3s
    ```
- Check k3s agent status

    ```bash
    systemctl status k3s-agent
    ```
- Check k3s server version

    ```bash
    k3s --version
    ```
- Check k3s agent version

    ```bash
    k3s --version
    ```
- Check k3s process (server and agent)

    ```bash
    ps -ef | grep k3s
    ```

#### References

- K3s documentation: https://k3s.io/
    - K3s install options: https://docs.k3s.io/installation/install-options/
    - K3s uninstall: https://rancher.com/docs/k3s/latest/en/installation/uninstall/
    - K3s troubleshooting: https://rancher.com/docs/k3s/latest/en/advanced/#troubleshooting
- Flannel GitHub: https://github.com/flannel-io/flannel#deploying-flannel-manually
- Helm: https://helm.sh/docs/intro/install/
- Kubectl: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
