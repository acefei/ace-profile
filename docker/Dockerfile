# syntax=docker/dockerfile:experimental
FROM ubuntu:22.04 as base
ARG KUBECTL_VERSION="v1.25.2"
RUN apt-get update -y && apt-get install -y curl && \
    curl -sSL https://aka.ms/InstallAzureCLIDeb | bash && \
    curl -sSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash && \
    curl -sSL https://webinstall.dev/k9s | bash && cp -L /root/.local/bin/k9s /usr/local/bin/ && \
    curl -sSL https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl

FROM ubuntu:22.04 as devops-box
COPY --from=base --chmod=755 /usr/local/bin/. /usr/local/bin
