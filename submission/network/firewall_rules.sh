#!/usr/bin/env bash
#
# firewall_rules.sh — Edge device firewall configuration
#

set -euo pipefail

# Define networks
CAMERA_VLAN="192.168.10.0/24"
MGMT_VLAN="10.50.1.0/24"

# Interfaces
MGMT_IF="eno1"
CAMERA_IF="eno2"

# --- Flush existing rules ---
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

# --- Default policies ---
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# --- Loopback ---
iptables -A INPUT -i lo -j ACCEPT

# --- Established/Related ---
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# --- Allow ICMP (ping & diagnostics) ---
iptables -A INPUT -p icmp -j ACCEPT

# --- SSH from management VLAN only ---
iptables -A INPUT -i $MGMT_IF -p tcp --dport 22 -s $MGMT_VLAN -j ACCEPT

# --- RTSP from camera VLAN only ---
iptables -A INPUT -i $CAMERA_IF -p tcp --dport 554 -s $CAMERA_VLAN -j ACCEPT
iptables -A INPUT -i $CAMERA_IF -p udp --dport 554 -s $CAMERA_VLAN -j ACCEPT

# --- HTTPS outbound for cloud uploads ---
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# --- Camera VLAN isolation ---
# Block camera VLAN from reaching management VLAN
iptables -A FORWARD -i $CAMERA_IF -s $CAMERA_VLAN -d $MGMT_VLAN -j DROP

# Block camera VLAN from reaching other internal networks
iptables -A FORWARD -i $CAMERA_IF -s $CAMERA_VLAN -j DROP

# --- Logging dropped packets (optional but useful) ---
iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "DROP_INPUT: "
iptables -A FORWARD -m limit --limit 5/min -j LOG --log-prefix "DROP_FORWARD: "

echo "Firewall rules applied successfully"