#!/usr/bin/env bash

set -oue pipefail

authselect enable-feature with-fingerprint
authselect apply-changes
