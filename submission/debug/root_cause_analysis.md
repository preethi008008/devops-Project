# Root Cause Analysis

Review all files in `data/debug_scenario/` to investigate the incident.

---

## Summary

Edge devices experienced intermittent failures uploading video to AWS services through the IPSec VPN tunnel. Large packets were fragmented and dropped, causing TLS upload failures and increasing queue backlogs. Video data was buffered locally, preventing loss, but processing delays were observed until connectivity was stabilized.

---

## Timeline

| Time (UTC) | Event |
|------------|-------|
| 10:02 | Upload failures begin at multiple sites |
| 10:04 | Error rate increases in edge upload service logs |
| 10:05 | SQS backlog begins growing |
| 10:07 | Edge devices report VPN instability |
| 10:10 | CloudWatch metrics show packet retransmissions increasing |
| 10:20 | MTU mismatch suspected after packet fragmentation observed |
| 10:28 | MTU and MSS tuning tested on affected device |
| 10:35 | VPN stability restored and uploads resume |
| 10:45 | Queue backlog processing returns to normal |

---

## Root Cause

The IPSec VPN tunnel introduced packet fragmentation due to an MTU mismatch between the edge device and the VPN gateway. Packets exceeding the tunnel MTU were dropped, causing TLS upload failures. Logs indicated repeated retransmissions and connection resets, confirming fragmentation-related packet loss.

---

## Contributing Factors

- MTU not tuned to account for IPSec overhead  
- Lack of monitoring for packet fragmentation and retransmissions  
- No MSS clamping configured on edge devices  
- Limited VPN health visibility delayed diagnosis  

---

## Evidence

- Edge logs showing repeated TLS connection resets during uploads  
- Increased packet retransmissions observed in network metrics  
- Queue backlog growth corresponding with upload failures  
- Successful upload restoration immediately after MTU adjustment  
- Reduced packet fragmentation and retransmissions following MSS tuning  