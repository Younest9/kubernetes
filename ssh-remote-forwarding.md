# remote forwading
```bash
ssh -J dev@172.20.51.18:2222 root@nginx
```
To succesfully make a tunnel you need to activate AllowTcpForward on /etc/ssh/sshd_config:
```bash
sed -e 's/AllowTcpForward no/AllowTcpForward yes/' /etc/ssh/sshd_config
```
or
```bash
sed -e 's/#AllowTcpForward yes/AllowTcpForward yes/' /etc/ssh/sshd_config
```
