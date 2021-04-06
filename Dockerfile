# Start from a Debian image with the latest version of Go installed
# and a workspace (GOPATH) configured at /go.
FROM registry.access.redhat.com/ubi8/ubi-minimal:latest

RUN  microdnf update -y \
        && rpm -e --nodeps tzdata \
        && microdnf install tzdata \
        && microdnf install git \
        && microdnf install openssh-clients \
        && microdnf install curl \
        && microdnf install procps \
        && microdnf install tar \
        && microdnf clean all

ENV USER_UID=1001 \
    USER_NAME=app-backend \
    ZONEINFO=/usr/share/timezone

COPY COMPONENT_VERSION /COMPONENT_VERSION

RUN curl -LO https://dl.google.com/go/go1.16.3.linux-amd64.tar.gz
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go1.16.3.linux-amd64.tar.gz
RUN mkdir -p /go/bin /go/src /go/pkg

ENV GOPATH="/go"
ENV PATH=$PATH:/usr/local/go/bin

RUN export COMPONENT_VERSION=$(cat /COMPONENT_VERSION); git clone -b release-${COMPONENT_VERSION} --single-branch https://github.com/open-cluster-management/applifecycle-backend-e2e.git /opt/e2e

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin

RUN curl -kLo oc.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.6.4/openshift-client-linux-4.6.4.tar.gz
RUN mkdir oc-unpacked
RUN tar -xzf oc.tar.gz -C oc-unpacked
RUN chmod +x ./oc-unpacked/oc
RUN mv ./oc-unpacked/oc /usr/local/bin/oc
RUN rm -rf ./oc-unpacked ./oc.tar.gz

WORKDIR /opt/e2e/client/canary

# the test data is in the binary format
ENTRYPOINT go test -v -timeout 30m

# Document that the service listens on port 8765.
EXPOSE 8765
