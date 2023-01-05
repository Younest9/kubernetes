#########################################
# On master and worker nodes both
#########################################

#pre processing

## this will disable swap temporarily, will not presist after a reboot
swapoff -a

## add a hash here before the swap or swap file if present and do a reboot
nano /etc/fstab


# Official docker installation guide :: https://docs.docker.com/engine/install/ubuntu/
apt-get remove docker docker-engine docker.io containerd runc

# Make a directory to keep the keys (it will do nothing if the directory is already present)
mkdir -p /etc/apt/keyrings

# Get Docker gpg key for ubuntu
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
# Add the repo for docker in ubuntu
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null


# Official Kubernetes installation guide ::  https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list


#install
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

docker run hello-world

groupadd docker

usermod -aG docker $USER

apt-get install -y kubelet kubeadm kubectl
# important, so that apt doesn't do an auto upgrade to these packages as newer version maybe incompatible with currect configuration
apt-mark hold kubelet kubeadm kubectl

systemctl enable docker.service
systemctl disable conatinerd.service
systemctl stop containerd.service


cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sysctl --system

git clone https://github.com/Mirantis/cri-dockerd.git
# Run these commands as root
###Install GO###
wget https://storage.googleapis.com/golang/getgo/installer_linux
chmod +x ./installer_linux
./installer_linux
source ~/.bash_profile

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

#cleanup
cd
rm -r installer_linux cri-dockerd/ go/