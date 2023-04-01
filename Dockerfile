FROM ubuntu:focal-20220404

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt install apt-utils gnupg2 gettext-base moreutils git-all -y \
    && apt install software-properties-common zip unzip curl azure-cli -y

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip && ./aws/install

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
    && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    && apt-get update && apt-get install terraform -y

WORKDIR /usr/src/infra

RUN adduser --disabled-password infra-admin
    
COPY --chown=infra-admin:infra-admin azure . 

RUN mv create-azure-infra /usr/local/bin \
    && mv deploy-test-in-azure /usr/local/bin \
    && mv deploy-prod-in-azure /usr/local/bin \
    && mv destroy-azure-infra /usr/local/bin

RUN chmod -R 755 /usr/src/infra/

USER infra-admin