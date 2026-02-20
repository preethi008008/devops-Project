#!/usr/bin/env bash
set -e

echo "Applying MTU and MSS remediation..."

# Set lower MTU to prevent IPSec fragmentation
ip link set dev eth0 mtu 1400

# Adjust TCP MSS to avoid packet fragmentation
iptables -t mangle -A FORWARD -p tcp --tcp-flags SYN,RST SYN \
  -j TCPMSS --set-mss 1360

echo "Restarting VPN service..."
systemctl restart strongswan || systemctl restart ipsec

echo "Remediation complete."