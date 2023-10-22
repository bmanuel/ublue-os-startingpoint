#!/usr/bin/env bash

set -oue pipefail

rpm-ostree override remove fprintd fprintd-pam \
	--install open-fprintd \
	--install python3-validity \
	--install fprintd-clients \
	--install fprintd-clients-pam
