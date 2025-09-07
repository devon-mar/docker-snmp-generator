# Modified from https://github.com/prometheus/snmp_exporter/blob/850835b5e5363db63678c98b89c3b7622733cedf/generator/Makefile

# Copyright 2018 The Prometheus Authors
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

MIBDIR   := mibs
MIB_PATH := 'mibs'

CURL_OPTS ?= -L --no-progress-meter --retry 3 --retry-delay 3 --fail

DOCKER_IMAGE_NAME ?= snmp-generator
DOCKER_IMAGE_TAG  ?= $(subst /,-,$(shell git rev-parse --abbrev-ref HEAD))
DOCKER_REPO       ?= prom

APC_URL           := https://raw.githubusercontent.com/prometheus-community/snmp/refs/heads/main/apc/PowerNet-MIB
CISCO_URL         := https://github.com/cisco/cisco-mibs/archive/refs/heads/main.tar.gz
IANA_CHARSET_URL  := https://www.iana.org/assignments/ianacharset-mib/ianacharset-mib
IANA_IFTYPE_URL   := https://www.iana.org/assignments/ianaiftype-mib/ianaiftype-mib
IANA_PRINTER_URL  := https://www.iana.org/assignments/ianaprinter-mib/ianaprinter-mib
KEEPALIVED_URL    := https://raw.githubusercontent.com/acassen/keepalived/v2.2.7/doc/KEEPALIVED-MIB.txt
VRRP_URL          := https://raw.githubusercontent.com/acassen/keepalived/v2.2.7/doc/VRRP-MIB.txt
VRRPV3_URL        := https://raw.githubusercontent.com/acassen/keepalived/v2.2.7/doc/VRRPv3-MIB.txt
MIKROTIK_URL      := 'https://box.mikrotik.com/f/a41daf63d0c14347a088/?dl=1'
NET_SNMP_URL      := https://raw.githubusercontent.com/net-snmp/net-snmp/v5.9/mibs

.DEFAULT: all

.PHONY: all
all: mibs

clean:
	rm -rvf \
		$(MIBDIR)/* \
		$(MIBDIR)/cisco_v2 \
		$(MIBDIR)/.net-snmp

.PHONY: mibs
mibs: mib-dir \
  $(MIBDIR)/apc-powernet-mib \
  $(MIBDIR)/cisco_v2 \
  $(MIBDIR)/IANA-CHARSET-MIB.txt \
  $(MIBDIR)/IANA-IFTYPE-MIB.txt \
  $(MIBDIR)/IANA-PRINTER-MIB.txt \
  $(MIBDIR)/KEEPALIVED-MIB \
  $(MIBDIR)/VRRP-MIB \
  $(MIBDIR)/VRRPv3-MIB \
  $(MIBDIR)/MIKROTIK-MIB \
  $(MIBDIR)/.net-snmp

mib-dir:
	@mkdir -p -v $(MIBDIR)

$(MIBDIR)/apc-powernet-mib:
	@echo ">> Downloading apc-powernet-mib"
	@curl $(CURL_OPTS) -o $(MIBDIR)/apc-powernet-mib "$(APC_URL)"
	# Workaround to make DisplayString available (#867)
	@sed -i.bak -E 's/(DisplayString[[:space:]]*FROM )RFC1213-MIB/\1SNMPv2-TC/' $(MIBDIR)/apc-powernet-mib
	@rm $(MIBDIR)/apc-powernet-mib.bak

$(MIBDIR)/cisco_v2:
	$(eval TMP := $(shell mktemp))
	@echo ">> Downloading cisco_v2"
	@mkdir -p $(TMP).extract
	@curl $(CURL_OPTS) -o $(TMP) $(CISCO_URL)
	tar --no-same-owner -C $(TMP).extract --strip-components=1 -zxvf $(TMP)
	@mv $(TMP).extract/v2 $(MIBDIR)/cisco_v2
	@rm -rf $(TMP).extract
	@rm -v $(TMP)

$(MIBDIR)/IANA-CHARSET-MIB.txt:
	@echo ">> Downloading IANA charset MIB"
	@curl $(CURL_OPTS) -o $(MIBDIR)/IANA-CHARSET-MIB.txt $(IANA_CHARSET_URL)

$(MIBDIR)/IANA-IFTYPE-MIB.txt:
	@echo ">> Downloading IANA ifType MIB"
	@curl $(CURL_OPTS) -o $(MIBDIR)/IANA-IFTYPE-MIB.txt $(IANA_IFTYPE_URL)

$(MIBDIR)/IANA-PRINTER-MIB.txt:
	@echo ">> Downloading IANA printer MIB"
	@curl $(CURL_OPTS) -o $(MIBDIR)/IANA-PRINTER-MIB.txt $(IANA_PRINTER_URL)

$(MIBDIR)/KEEPALIVED-MIB:
	@echo ">> Downloading KEEPALIVED-MIB"
	@curl $(CURL_OPTS) -o $(MIBDIR)/KEEPALIVED-MIB $(KEEPALIVED_URL)

$(MIBDIR)/VRRP-MIB:
	@echo ">> Downloading VRRP-MIB"
	@curl $(CURL_OPTS) -o $(MIBDIR)/VRRP-MIB $(VRRP_URL)

$(MIBDIR)/VRRPv3-MIB:
	@echo ">> Downloading VRRPv3-MIB"
	@curl $(CURL_OPTS) -o $(MIBDIR)/VRRPv3-MIB $(VRRPV3_URL)

$(MIBDIR)/MIKROTIK-MIB:
	@echo ">> Downloading MIKROTIK-MIB"
	@curl $(CURL_OPTS) -o $(MIBDIR)/MIKROTIK-MIB $(MIKROTIK_URL)

$(MIBDIR)/.net-snmp:
	@echo ">> Downloading NET-SNMP mibs"
	@curl $(CURL_OPTS) -o $(MIBDIR)/HCNUM-TC $(NET_SNMP_URL)/HCNUM-TC.txt
	@curl $(CURL_OPTS) -o $(MIBDIR)/HOST-RESOURCES-MIB $(NET_SNMP_URL)/HOST-RESOURCES-MIB.txt
	@curl $(CURL_OPTS) -o $(MIBDIR)/IF-MIB $(NET_SNMP_URL)/IF-MIB.txt
	@curl $(CURL_OPTS) -o $(MIBDIR)/INET-ADDRESS-MIB $(NET_SNMP_URL)/INET-ADDRESS-MIB.txt
	@curl $(CURL_OPTS) -o $(MIBDIR)/IPV6-TC $(NET_SNMP_URL)/IPV6-TC.txt
	@curl $(CURL_OPTS) -o $(MIBDIR)/NET-SNMP-MIB $(NET_SNMP_URL)/NET-SNMP-MIB.txt
	@curl $(CURL_OPTS) -o $(MIBDIR)/NET-SNMP-TC $(NET_SNMP_URL)/NET-SNMP-TC.txt
	@curl $(CURL_OPTS) -o $(MIBDIR)/SNMP-FRAMEWORK-MIB $(NET_SNMP_URL)/SNMP-FRAMEWORK-MIB.txt
	@curl $(CURL_OPTS) -o $(MIBDIR)/SNMPv2-MIB $(NET_SNMP_URL)/SNMPv2-MIB.txt
	@curl $(CURL_OPTS) -o $(MIBDIR)/SNMPv2-SMI $(NET_SNMP_URL)/SNMPv2-SMI.txt
	@curl $(CURL_OPTS) -o $(MIBDIR)/SNMPv2-TC $(NET_SNMP_URL)/SNMPv2-TC.txt
	@curl $(CURL_OPTS) -o $(MIBDIR)/UCD-SNMP-MIB $(NET_SNMP_URL)/UCD-SNMP-MIB.txt
	@curl $(CURL_OPTS) -o $(MIBDIR)/UCD-DISKIO-MIB $(NET_SNMP_URL)/UCD-DISKIO-MIB.txt
	@touch $(MIBDIR)/.net-snmp
