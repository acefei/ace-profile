# syntax=docker/dockerfile:experimental
FROM ubuntu:22.04 as build-devops-box
ENV DEBIAN_FRONTEND noninteractive
ARG KUBECTL_VERSION="v1.25.2"
RUN apt update -y && apt install -y curl vim-nox dnsutils && \
    curl -sSL https://aka.ms/InstallAzureCLIDeb | bash && \
    curl -sSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash && \
    curl -sSL https://webinstall.dev/k9s | bash && cp -L /root/.local/bin/k9s /usr/local/bin/ && \
    curl -sSL https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl
