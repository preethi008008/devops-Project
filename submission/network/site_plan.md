# Site Network Plan

Review `data/site_spec.json` for the customer site specification.

---

## VLAN Design

| VLAN ID | Name | Subnet | Purpose |
|---------|------|--------|---------|
| 10 | Camera Network | 192.168.10.0/24 | IP cameras and video streaming |
| 20 | Management | 192.168.20.0/24 | Edge device management & maintenance |
| 30 | Corporate | 192.168.30.0/24 | Customer business network (isolated) |

---

## IP Addressing Scheme

### Static Assignments
- Edge Device (Camera NIC): 192.168.10.2  
- Edge Device (Management NIC): 192.168.20.2  
- Management Gateway: 192.168.20.1  

### DHCP Range (Cameras)
192.168.10.50 – 192.168.10.200  

This ensures predictable addressing while supporting scalable camera deployments.

---

## Camera Network Isolation

Camera traffic is isolated using VLAN segmentation and firewall enforcement:

- Cameras exist only on VLAN 10.
- Cameras have **no direct internet access**.
- Only the edge device can communicate with cameras.
- Routing between VLAN 10 and VLAN 30 is blocked.
- Firewall rules restrict camera communication to RTSP (554) and ONVIF (3702).
- Management access is allowed only from VLAN 20.

This prevents lateral movement and protects the corporate network.

---

## Edge Device Network Configuration

The edge device uses two network interfaces:

### eth0 — Camera VLAN (10)
- IP: 192.168.10.2  
- Receives RTSP video streams from cameras  

### eth1 — Management VLAN (20)
- IP: 192.168.20.2  
- Connects to VPN and cloud services  
- Used for SSH management and updates  

Routing rules ensure camera traffic does not exit directly to the internet.

---

## Traffic Flow

1. Cameras stream video via RTSP to the edge device on VLAN 10.  
2. The edge device performs local AI inference.  
3. Video fragments are encrypted and buffered.  
4. Data is transmitted through the IPSec VPN tunnel.  
5. Video is uploaded to Amazon S3.  
6. Metadata and inference results are sent to Amazon SQS.  

If VPN connectivity is lost, the edge device buffers video locally until the connection is restored.