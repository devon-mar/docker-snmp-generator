# For main
ARG FROM=alpine:latest

FROM golang:alpine as builder
ARG SNMP_EXPORTER_VERSION=latest

RUN apk add net-snmp-dev p7zip unzip build-base && \
    go install "github.com/prometheus/snmp_exporter/generator@$SNMP_EXPORTER_VERSION"


# Stage 2
FROM $FROM as main

RUN apk add net-snmp-libs

COPY --from=builder /go/bin/generator /generator

RUN mkdir /opt/mibs /opt/generator

ARG MIBS_DIR=./mibs/
COPY ${MIBS_DIR} /opt/mibs

WORKDIR "/opt/generator"

ENTRYPOINT ["/generator"]

ENV MIBDIRS /opt/mibs:/opt/mibs/cisco_v2

CMD ["generate"]
