# Kubernetes

## Overview 

Kubernetes is an open-source system for automating deployment, scaling, and management of containerized applications.

It groups containers that make up an application into logical units for easy management and discovery. 

## Why Kubernetes ?

Containers are a good way to bundle and run your applications. In a production environment, you need to manage the containers that run the applications and ensure that there is no downtime. For example, if a container goes down, another container needs to start. Wouldn't it be easier if this behavior was handled by a system?

That's how Kubernetes comes to the rescue! Kubernetes provides you with a framework to run distributed systems resiliently. It takes care of scaling and failover for your application, provides deployment patterns, and more. For example: Kubernetes can easily manage a canary deployment for your system.

Kubernetes provides you with:

- <strong>Service discovery and load balancing</strong> Kubernetes can expose a container using the DNS name or using their own IP address. If traffic to a container is high, Kubernetes is able to load balance and distribute the network traffic so that the deployment is stable.
- <strong>Storage orchestration</strong>Kubernetes allows you to automatically mount a storage system of your choice, such as local storages, public cloud providers, and more.
- <strong>Automated rollouts and rollbacks </strong>You can describe the desired state for your deployed containers using Kubernetes, and it can change the actual state to the desired state at a controlled rate.
  - For example, you can automate Kubernetes to create new containers for your deployment, remove existing containers and adopt all their resources to the new container.
- <strong>Automatic bin packing</strong>You provide Kubernetes with a cluster of nodes that it can use to run containerized tasks. You tell Kubernetes how much CPU and memory (RAM) each container needs. Kubernetes can fit containers onto your nodes to make the best use of your resources.
- <strong>Self-healing</strong> Kubernetes restarts containers that fail, replaces containers, kills containers that don't respond to your user-defined health check, and doesn't advertise them to clients until they are ready to serve.
- <strong>Secret and configuration management</strong> Kubernetes lets you store and manage sensitive information, such as passwords, OAuth tokens, and SSH keys. You can deploy and update secrets and application configuration without rebuilding your container images, and without exposing secrets in your stack configuration.
## What Kubernetes is not 
Kubernetes is not a traditional, all-inclusive PaaS (Platform as a Service) system. Since Kubernetes operates at the container level rather than at the hardware level, it provides some generally applicable features common to PaaS offerings, such as deployment, scaling, load balancing, and lets users integrate their logging, monitoring, and alerting solutions. However, Kubernetes is not monolithic, and these default solutions are optional and pluggable. Kubernetes provides the building blocks for building developer platforms, but preserves user choice and flexibility where it is important.

Kubernetes:

- Does not limit the types of applications supported. Kubernetes aims to support an extremely diverse variety of workloads, including stateless, stateful, and data-processing workloads. If an application can run in a container, it should run great on Kubernetes.
- Does not deploy source code and does not build your application. Continuous Integration, Delivery, and Deployment (CI/CD) workflows are determined by organization cultures and preferences as well as technical requirements.
- Does not provide application-level services, such as middleware (for example, message buses), data-processing frameworks (for example, Spark), databases (for example, MySQL), caches, nor cluster storage systems (for example, Ceph) as built-in services. Such components can run on Kubernetes, and/or can be accessed by applications running on Kubernetes through portable mechanisms, such as the Open Service Broker.
- Does not dictate logging, monitoring, or alerting solutions. It provides some integrations as proof of concept, and mechanisms to collect and export metrics.
- Does not provide nor mandate a configuration language/system (for example, Jsonnet). It provides a declarative API that may be targeted by arbitrary forms of declarative specifications.
- Does not provide nor adopt any comprehensive machine configuration, maintenance, management, or self-healing systems.
- Additionally, Kubernetes is not a mere orchestration system. In fact, it eliminates the need for orchestration. The technical definition of orchestration is execution of a defined workflow: first do A, then B, then C. In contrast, Kubernetes comprises a set of independent, composable control processes that continuously drive the current state towards the provided desired state. It shouldn't matter how you get from A to C. Centralized control is also not required. This results in a system that is easier to use and more powerful, robust, resilient, and extensible.

## Distributions

There are a lot of distributions that kubernetes comes in, but the most known are:
- The traditional distribution, known as <strong>k8s</strong> : -> [Documentation](k8s/README.md)
- <strong>Openshift</strong>, which is a kubernetes distribution with a lot of extra features, such as a web console, a CLI, a lot of pre-installed operators, and more: -> [Documentation](https://github.com.younest9/ocp/)
- <Strong>OKD</Strong>, which is the upstream version of Openshift (Community version). -> [Documentation](https://github.com.younest9/okd/)
- <strong>Minikube</strong>, which is a single-node kubernetes cluster that runs on your local machine. It's a great way to test kubernetes without having to install it on your machine.
- <strong>Microk8s</strong>, which is a low-ops, minimal production Kubernetes.  It provides the functionality of core Kubernetes components, in a small footprint, scalable from a single node to a high-availability production cluster.
- <strong>K3s</strong>, which is a lightweight kubernetes distribution that runs as a single binary, it's similar to k8s but it's a lot lighter: -> [Documentation](k3s/README.md)
- <strong>K3d</strong>, which is a lightweight wrapper to run <strong>k3s</strong> in docker.

## Aliases - Optional

You can check aliases that are in the [setup-aliases.sh](setup-aliases.sh).
If you want to use them, you can run the script and it will add them to your .bashrc file.
Run the following command:
```bash
chmod +x setup-aliases.sh
./setup-aliases.sh
```
>Notes:
>
>- You can also add other aliases manually to your .bashrc file.
>- You can also remove the aliases that you don't want to use.

Sources: 
- https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/
- https://microk8s.io/docs
- https://k3s.io/docs/
- https://k3d.io/
- https://docs.openshift.com/
- https://docs.okd.io/