#!/usr/bin/env bash

set -oue pipefail

rpm-ostree override remove fprintd --install open-fprintd
rpm-ostree install python3-validity fprintd-clients
