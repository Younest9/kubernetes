## SSH Remote forwading

- ### Create a Docker image with SSH server (bastion host) and enable remote forwarding for a specific user : dev 

    ```Dockerfile
    FROM lscr.io/linuxserver/openssh-server:latest
    RUN echo "Match User dev" >> /etc/ssh/sshd_config
    RUN echo "  AllowTcpForwarding yes" >> /etc/ssh/sshd_config
    RUN echo "  X11Forwarding yes" >> /etc/ssh/sshd_config
    RUN echo "  PermitTunnel yes" >> /etc/ssh/sshd_config
    RUN echo "  AllowAgentForwarding yes" >> /etc/ssh/sshd_config
    ```

- ### Create a Deployment with the image created above

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
    name: openssh
    namespace: dev
    labels:
        app: openssh
    spec:
    replicas: 1
    selector:
        matchLabels:
        app: openssh
    template:
        metadata:
        labels:
            app: openssh
        spec:
        containers:
        - name: openssh
            image: <image-name>
            ports:
            - containerPort: 2222
            env:
            - name: PUID
            value: "1000"
            - name: PGID
            value: "1000"
            - name: TZ
            value: "Europe/Paris"
            - name: USER_NAME
            value: "dev"
            - name: USER_PASSWORD
            value: " "
            - name: PASSWORD_ACCESS
            value: "true"
            - name: SUDO_ACCESS
            value: "true"
    ```

- ### Create a Service to expose the SSH server 

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
    name: openssh
    namespace: dev
    labels:
        app: openssh
    spec:
    type: ClusterIP
    
    ports:
    - port: 22
        targetPort: 2222
        protocol: TCP
    selector:
        app: openssh
    ```

- ### Create an ingressRoute 

    ```yaml
    apiVersion: traefik.containo.us/v1alpha1
    kind: IngressRouteTCP
    metadata:
    name: openssh
    namespace: dev
    spec:
    entryPoints:
        - ssh
    routes:
        - match: HostSNI(`*`)
        services:
            - name: openssh
            port: 22
    ```

- ### SSH tunnel

    Use this command:

    ```bash
    ssh -J dev@<bastion-hostname>:<port> root@<remote-hostname>
    ```