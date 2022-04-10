FROM alpine

RUN apk update && \
    apk add terraform

WORKDIR /usr/src/terraform

RUN adduser -D terraform
    
COPY --chown=terraform:terraform aws/terraform-aws/ .

RUN chmod -R 755 /usr/src/terraform/

USER terraform
