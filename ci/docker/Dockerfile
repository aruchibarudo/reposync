ARG RHEL_VERSION=8
ARG IMAGE=registry.access.redhat.com/ubi${RHEL_VERSION}/ubi

FROM ${IMAGE}

ARG RHEL_VERSION=8
ARG RHEL_CERT=src/certs/entitlement.pem
ARG RHEL_KEY=src/certs/entitlement-key.pem
ARG RHEL_CA=src/certs/redhat-uep.pem
ARG RHEL_REPO_FILES=src/rhel${RHEL_VERSION}/*.repo

ENV REPO_DST ""
ENV REPO_LSIT ""
ENV REPOSYNC_OPTS ""

USER root

COPY ${RHEL_CERT} /etc/pki/entitlement/entitlement.pem
COPY ${RHEL_KEY} /etc/pki/entitlement/entitlement-key.pem
COPY ${RHEL_CA} /etc/rhsm/ca/redhat-uep.pem
COPY ${RHEL_REPO_FILES} /etc/yum.repos.d/

RUN yum install -y yum-utils createrepo && \
  yum clean all

COPY src/rhel${RHEL_VERSION}/reposync.sh /app/src/reposync.sh

CMD [ "/bin/bash", "/app/src/reposync.sh" ]
