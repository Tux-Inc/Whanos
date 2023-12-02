# Whanos 🦄
Don't let your applications be snapped by Thanos 🫰
## Introduction
### What is Whanos?
Whanos is a tool that allows you to easily Dockerize your applications and deploy them to a Kubernetes cluster. It uses a Jenkins instance to build and push the Docker images to a private Docker registry and a Helm chart to deploy the applications to the Kubernetes cluster.

### Goals
- Easily deploy applications to a Kubernetes cluster
- Easily build and push Docker images to a private Docker registry

The mail goal of Whanos is for a developer to focus on the application code and not on the infrastructure.

By simply starting a Jenkins job, the developer will be able to Dockerize his application. 

If the developer want to deploy the application to the Kubernetes cluster, he will simply have to add a file called `whanos.yaml` to the root of his project and start a Jenkins job. Whanos will take care of building the Docker image, pushing it to the private Docker registry and deploying the application to the Kubernetes cluster.

## Table of contents
- [Introduction](#introduction)
  - [What is Whanos?](#what-is-whanos)
  - [Goals](#goals)
- [Installation](#installation)
  - [Using ansible](#using-ansible)
- [How it works](#how-it-works)
  - [What ansible does on the machines](#what-ansible-does-on-the-machines)
    - [Install prerequisites](#install-prerequisites)
    - [Deploy the cluster](#deploy-the-cluster)
    - [Install docker registry](#install-docker-registry)
- [Usage](#usage)

## Authors
- [**Gwenaël HUBLER**](https://github.com/Neeptossss)