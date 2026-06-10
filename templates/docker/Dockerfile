FROM ubuntu:22.04 as build-devops-box
ENV DEBIAN_FRONTEND noninteractive
ARG KUBECTL_VERSION="v1.25.2"
RUN apt update -y && apt install -y curl vim-nox dnsutils && \
    curl -sSL https://aka.ms/InstallAzureCLIDeb | bash && \
    curl -sSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash && \
    curl -sSL https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl && \
    echo "source <(kubectl completion bash)" >> ~/.bashrc && \
    k9s_download_url=$( curl  -w "%{redirect_url}" -o /dev/null -s https://github.com/derailed/k9s/releases/latest | perl -pe "s/tag/download/" ) && \
    (cd /usr/local/bin/ && curl -sSL $k9s_download_url/k9s_Linux_amd64.tar.gz | tar zxvf -)
