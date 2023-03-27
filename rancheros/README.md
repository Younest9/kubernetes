## RancherOS

### What is RancherOS?

RancherOS is a tiny Linux distribution that runs the entire OS as a Docker container. It is designed to run Docker containers instead of traditional Linux applications. RancherOS is a great choice for running Docker in production.

### Installation

#### Prerequisites

- A machine with a minimum of 1GB RAM and 8GB of disk space
- A machine with a minimum of 2GB RAM and 8GB of disk space if you want to run RancherOS in a VM
- A machine with a minimum of 4GB RAM and 8GB of disk space if you want to run RancherOS in a VM and use Rancher
- A machine with a minimum of 8GB RAM and 8GB of disk space if you want to run RancherOS in a VM and use Rancher with Kubernetes
- A machine with a minimum of 16GB RAM and 8GB of disk space if you want to run RancherOS in a VM and use Rancher with Kubernetes and Rancher Monitoring

#### Install RancherOS

1. Download the latest version of RancherOS from the [releases page](https://github.com/rancher/os/releases) and unzip it.

2. Install RancherOS on your machine using the following command:

    ```bash
    sudo ros install -d /dev/sda -c cloud-config.yml -t generic
    ```
    >**Notes:** 
    >- Replace `/dev/sda` with the device name of your machine.
    >- Replace `cloud-config.yml` with the path to your cloud-config file (You can use this [cloud-config](cloud-config.yml) file as a template).
    >- Replace `generic` with the type of your machine. For example, `vmware` or `virtualbox`.
    >- If you are installing RancherOS on a VM, you can use the `--no-reboot` flag to prevent the machine from rebooting after installation.
    >- If you are installing RancherOS on a VM, you can use the `--append` flag to append additional kernel parameters. For example, `--append "console=ttyS0"`.
    >- You can customize the installation more by modifying the `cloud-config.yml` file. For more information, see [Customizing RancherOS](https://rancher.com/docs/os/v1.x/en/installation/configuration/custom-config/).
    
3. Reboot your machine.


#### References

- RancherOS GitHub: https://github.com/rancher/os
- RancherOS Documentation: https://rancher.com/docs/os/v1.x/en/
    - RancherOS Installation: https://rancher.com/docs/os/v1.x/en/installation/
    - Customizing RancherOS: https://rancher.com/docs/os/v1.x/en/installation/configuration/custom-config/
    - RancherOS Cloud-Config: https://rancher.com/docs/os/v1.x/en/installation/configuration/cloud-config/
    - RancherOS Cloud-Config Examples: https://rancher.com/docs/os/v1.x/en/installation/configuration/examples/

