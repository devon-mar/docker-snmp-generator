# docker-snmp-generator

A Dockerfile to build a snmp exporter generator image with MIBS included.

# Usage
```
docker run -it --rm -v "${PWD}:/opt/generator" devonm/snmp-generator generate
```
