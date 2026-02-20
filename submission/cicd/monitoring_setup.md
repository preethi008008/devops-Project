# Monitoring and Observability Setup

## Metrics

### Application Metrics
- API request latency (p50, p95, p99)
- Error rate (% of failed requests)
- Request throughput (requests/sec)
- Inference processing time
- Queue processing latency

### Infrastructure Metrics
- CPU & memory utilization (EKS nodes)
- GPU utilization (inference workloads)
- Disk I/O and storage usage
- Network throughput and packet loss
- Pod restart count & node health

### Business Metrics
- Video chunks processed per minute
- Upload success vs failure rate
- Inference events generated per site
- Camera connectivity uptime
- Event delivery latency to customers

### Edge Device Metrics
- Device uptime & heartbeat status
- VPN connectivity status
- Local disk buffer usage
- Camera stream availability
- Temperature & hardware health

---

## SLOs (Service Level Objectives)

### Availability
- 99.9% platform availability monthly
- Edge device uptime ≥ 99.5%

### Latency
- API response time < 300 ms (p95)
- Inference processing < 2 seconds

### Data Freshness
- Video data upload delay < 60 seconds
- In case of VPN outage, backlog processed within 15 minutes after recovery

### Reliability
- Video upload success rate ≥ 99.5%
- Camera connectivity success ≥ 98%

---

## Alerting

### Critical Alerts (Page On-Call)
- Platform availability drops below SLO
- VPN connectivity lost for > 2 minutes
- GPU inference service unavailable
- Queue backlog exceeds critical threshold
- Edge device offline

### Warning Alerts (Create Ticket)
- CPU usage > 85% for 10 minutes
- Disk usage > 80%
- Increased error rate > 3%
- Camera offline > 5 minutes
- Upload retry rate exceeds threshold

### Alert Fatigue Prevention
- Deduplicate repeated alerts
- Group alerts by site/location
- Silence non-critical alerts during maintenance windows
- Use threshold windows instead of instant triggers

---

## Escalation

### L1 — Automated Response
- Restart failed pods
- Restart camera streams
- Retry uploads
- Auto-scale workloads

### L2 — On-Call Engineer
- Investigate alerts
- Validate service health
- Restore connectivity issues
- Review logs and metrics

### L3 — Senior Engineer / Specialist
- Network/VPN failures
- GPU inference failures
- Data loss risk
- System-wide outages

### Customer Notification
Customers are notified if:
- outage exceeds 15 minutes
- video processing delays impact service
- site connectivity is lost

---

## Dashboards

### Operations Dashboard
- System health overview
- Active alerts
- Node & pod health
- VPN connectivity status

### Application Performance Dashboard
- API latency & error rates
- Throughput metrics
- Inference response times

### Edge Device Dashboard
- Device uptime
- Camera connectivity
- Buffer usage
- VPN health per site

### Business Dashboard
- Video processed per hour
- Inference events generated
- Site activity trends
- Upload success rate

### Capacity & Cost Dashboard
- GPU utilization
- Storage growth trends
- Compute usage trends
- Forecasted capacity needs