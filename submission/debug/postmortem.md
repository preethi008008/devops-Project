# Incident Postmortem

## Summary
A VPN MTU mismatch caused packet fragmentation and TLS failures during video uploads.

## What Went Well
- Monitoring detected backlog growth quickly
- Edge buffering prevented data loss
- Root cause identified rapidly

## What Went Wrong
- MTU settings were not validated during deployment
- VPN health metrics were limited
- No automated detection of fragmentation issues

## Action Items
- Standardize MTU configuration for all edge devices
- Add VPN health and packet loss monitoring
- Implement automated MTU validation during provisioning
- Enhance alerting for upload failures

## Prevention Measures
- Include MTU tuning in golden image
- Add MSS clamping rules by default
- Continuous VPN performance monitoring