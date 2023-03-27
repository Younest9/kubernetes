## SSH Remote forwading

We are going to create a bastion host with SSH server and enable remote forwarding for a specific user (dev). This user will be able to connect to a remote host using SSH tunnel.

- Create a Docker image with SSH server (bastion host) and enable remote forwarding for a specific user : dev (based on linuxserver/openssh-server image)

    ```Dockerfile
    FROM lscr.io/linuxserver/openssh-server:latest
    RUN echo "Match User dev" >> /etc/ssh/sshd_config
    RUN echo "  AllowTcpForwarding yes" >> /etc/ssh/sshd_config
    RUN echo "  X11Forwarding yes" >> /etc/ssh/sshd_config
    RUN echo "  AllowAgentForwarding yes" >> /etc/ssh/sshd_config
    ```
    >Note:
    >- The user `dev` must be created with env variables `USER_NAME` and `USER_PASSWORD` in the deployment.
    >- The 3 following lines are added to the `sshd_config` file to enable remote forwarding for the user `dev`, it has to be done on the remote host too.

- Create a Deployment with the image created above

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
        name: <name>
        namespace: <namespace>
    labels:
        app: <name>
    spec:
        replicas: 1
        selector:
            matchLabels:
            app: <name>
        template:
            metadata:
            labels:
                app: <name>
            spec:
            containers:
            - name: <name>
                image: <image-name>
                ports:
                - containerPort: 2222
                env:
                - name: PUID # optional
                value: "1000" # optional
                - name: PGID # optional
                value: "1000" # optional
                - name: TZ # optional
                value: "Europe/Paris" # optional
                - name: USER_NAME
                value: "dev"
                - name: USER_PASSWORD
                value: <password> # I
                - name: PASSWORD_ACCESS
                value: "true"
                - name: SUDO_ACCESS # optional
                value: "true" # optional
    ```

- Create a Service to expose the SSH server 

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
        name: <name>
        namespace: <namespace> 
        labels:
            app: <name>
    spec:
        type: ClusterIP # optional (default)
        
        ports:
        - port: 22 
          targetPort: 2222 
        protocol: TCP
        selector:
            app: <name>
    ```

- Create an ingressRoute 

    ```yaml
    apiVersion: traefik.containo.us/v1alpha1
    kind: IngressRouteTCP
    metadata:
        name: <name>
        namespace: <namespace>
    spec:
        entryPoints:
            - ssh # entrypoint defined in traefik config
        routes:
            - match: HostSNI(`*`) # match all hosts
            services:
                - name: <service-name>
                  port: <service-port>
    ```

- SSH tunnel

    - Use this command:

        ```bash
        ssh -J dev@<bastion-hostname>:<port> <user-on-remote-host>@<remote-hostname>
        ```