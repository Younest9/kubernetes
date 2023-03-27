## MetalLB

### What is MetalLB?

MetalLB is a load-balancer implementation for bare metal Kubernetes clusters, using standard routing protocols.

### How does it work?

MetalLB is a network load-balancer implementation for bare metal Kubernetes clusters, using standard routing protocols. It allows you to expose Kubernetes Services onto an external network.

MetalLB runs on your Kubernetes cluster, and announces services by creating BGP announcements. A BGP speaker must be running on your network to route the announcements to the right places.

### Installation

#### Network Addons

MetalLB requires a network addon to be installed on your cluster. The following network addons are supported:
<div style="text-align: center">

| Network Addon | Compatibility | Comments |
| --- | --- | --- |
| [Antrea](https://github.com/jayunit100/k8sprototypes/tree/master/kind/metallb-antrea) | ✅ | |
| [Calico](https://docs.tigera.io/calico/latest/about) | ✅  | (Mostly - [See Known Issues](https://metallb.universe.tf/configuration/calico/)) |
| [Canal](https://docs.projectcalico.org/getting-started/kubernetes/flannel/flannel) | ✅ | |
| [Cilium](https://docs.cilium.io/en/stable/) | ✅ | |
| [Flannel](https://github.com/flannel-io/flannel) | ✅ | |
| [Kube-ovn](https://kubeovn.github.io/docs/v1.11.x/en/start/prepare/) | ✅ | |
| [Kube-router](https://www.kube-router.io/docs/) | ✅  | (Mostly - [See Known Issues](https://metallb.universe.tf/configuration/kube-router/)) |
| [Weave Net](https://www.weave.works/docs/net/latest/kubernetes/kube-addon/) | ✅  | (Mostly - [See Known Issues](https://metallb.universe.tf/configuration/weave/)) |
</div>

#### Configuration

MetalLB can be configured in a number of ways. The following configuration methods are supported:

- [Layer 2](https://metallb.universe.tf/configuration/#layer-2-configuration)
- [BGP](https://metallb.universe.tf/configuration/#bgp-configuration)
- [Advanced BGP Configuration](https://metallb.universe.tf/configuration/_advanced_bgp_configuration/)
- [Advanced Layer 2 Configuration](https://metallb.universe.tf/configuration/_advanced_l2_configuration/)
- [Advanced IPAdressPool Configuration](https://metallb.universe.tf/configuration/_advanced_ipaddresspool_configuration/)

In this example, we will use the Layer 2 configuration.

#### Pre-requisites

If you’re using kube-proxy in IPVS mode, since Kubernetes v1.14.2 you have to enable strict ARP mode.

Note, you don’t need this if you’re using kube-router as service-proxy because it is enabling strict ARP by default.

You can achieve this by editing kube-proxy config in current cluster:

```bash
kubectl edit configmap kube-proxy -n kube-system
```

And set `strictARP: true` in `config.conf`:

```yaml
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
ipvs:
  strictARP: true
```

You can also add this configuration snippet to your kubeadm-config, just append it with --- after the main configuration.

If you are trying to automate this change, these shell snippets may help you:

```bash
# see what changes would be made, returns nonzero returncode if different
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl diff -f - -n kube-system

# actually apply the changes, returns nonzero returncode on errors only
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system
```

#### Layer 2 Configuration

The Layer 2 configuration is the simplest way to get started with MetalLB. It requires no BGP configuration, and works on any network that supports multicast.

- #### Install MetalLB

    To install MetalLB in Layer 2 mode, run the following command:

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.9/config/manifests/metallb-native.yaml
    ```
    > Note: If you want to deploy MetalLB using the FRR mode, apply the manifests:
    > ```bash
    > kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.9/config/manifests/metallb-frr.yaml
    > ```

    This will deploy MetalLB to your cluster, under the metallb-system namespace. The components in the manifest are:

        The metallb-system/controller deployment. This is the cluster-wide controller that handles IP address assignments.
        The metallb-system/speaker daemonset. This is the component that speaks the protocol(s) of your choice to make the services reachable.
        Service accounts for the controller and speaker, along with the RBAC permissions that the components need to function.

    The installation manifest does not include a configuration file. MetalLB’s components will still start, but will remain idle until you start [deploying resources](#configure-metallb).

- #### Configure MetalLB

    Layer 2 mode is the simplest to configure: in many cases, you don’t need any protocol-specific configuration, only IP addresses.

    Layer 2 mode does not require the IPs to be bound to the network interfaces of your worker nodes. It works by responding to ARP requests on your local network directly, to give the machine’s MAC address to clients.

    In order to advertise the IP coming from an `IPAddressPool`, an `L2Advertisement` instance must be associated to the `IPAddressPool`.

    For example, the following configuration gives MetalLB control over IPs from 192.168.1.240 to 192.168.1.250, and configures Layer 2 mode:

    ```yaml
    apiVersion: metallb.io/v1beta1
    kind: IPAddressPool
    metadata:
    name: first-pool
    namespace: metallb-system
    spec:
    addresses:
    - 192.168.1.240-192.168.1.250
    ```

    Now, create a `L2Advertisement` instance that will advertise the IP addresses from the `IPAddressPool`:

    ```yaml
    apiVersion: metallb.io/v1beta1
    kind: L2Advertisement
    metadata:
    name: first-advertisement
    namespace: metallb-system
    ```

    Setting no `IPAddressPool` selector in an `L2Advertisement` instance is interpreted as that instance being associated to all the `IPAddressPools` available.

    So in case there are specialized `IPAddressPools`, and only some of them must be advertised via L2, the list of `IPAddressPools` we want to advertise the IPs from must be declared (alternative, a label selector can be used).

    For example, the following configuration gives MetalLB control over IPs from the first-pool, and configures Layer 2 mode:

    ```yaml
    apiVersion: metallb.io/v1beta1
    kind: L2Advertisement
    metadata:
    name: example
    namespace: metallb-system
    spec:
    ipAddressPools:
    - first-pool
    ```

    Save the above manifests as `ip-address-pool.yaml` and `L2Advertisement.yaml`, and apply them to your cluster:

    ```bash
    kubectl apply -f ip-address-pool.yaml -f L2Advertisement.yaml
    ```

    Now You should be able to create a LoadBalancer service and get an IP address from the range you configured:

    ```bash
    kubectl apply -f service.yaml
    ```

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
    name: nginx
    namespace: default
    spec:
        type: LoadBalancer
        ports:
        - port: 80
            targetPort: 80
        selector:
            app: nginx
    ```
    List the services in your cluster:
    ```bash
    kubectl get svc nginx
    ```

    You should see an IP address assigned to the service:
    ```bash
    NAME    TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
    nginx   LoadBalancer   10.0.0.2        192.168.1.241 80:30080/TCP   1m
    ```

    > For more information about other configuration options, see the [Configuration](https://metallb.universe.tf/configuration/) section of the documentation.


#### References

- MetalLB official documentation: https://metallb.universe.tf/
    - Installation: https://metallb.universe.tf/installation/
    - Configuration: https://metallb.universe.tf/configuration/
    - Network Addons: https://metallb.universe.tf/installation/network-addons/
    - Troubleshooting: https://metallb.universe.tf/troubleshooting/
