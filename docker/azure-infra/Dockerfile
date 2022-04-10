FROM alpine

RUN apk update && \
    apk add terraform

WORKDIR /usr/src/terraform

RUN adduser -D terraform
    
COPY --chown=terraform:terraform /home/circleci/project/azure/terraform-azure/ . 

RUN chmod -R 755 /usr/src/terraform/

USER terraform
