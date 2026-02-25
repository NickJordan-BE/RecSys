# Service Level Objectives (SLO) & Agreements (SLA)

## 1. Document Purpose
This document defines the performance benchmarks and reliability targets for the Recommendation Engine. These metrics guide the **Error Budget** and alerting thresholds for the production environment.

## 2. Service Level Indicators (SLI)

### 2.1 Latency
* **Inference Latency:** Time measured from the Orchestrator receiving a request to returning a response.
* **Downstream Latency:** Time for individual gRPC calls to the Ranking and Feature services.

### 2.2 Availability
* **Uptime:** The percentage of time the `/v1/recommend` endpoint returns a `200 OK` status.
* **Success Rate:** Ratio of successful recommendations to total requests.

### 2.3 Freshness
* **Feature Age:** The time elapsed since a user interaction occurred and when it is reflected in the Redis Online Store.

## 3. Service Level Objectives (SLO)

| Metric | Target | Measurement Window |
| :--- | :--- | :--- |
| **P99 Latency** | < 200ms | Rolling 5-minute average |
| **P50 Latency** | < 50ms | Rolling 5-minute average |
| **Availability** | 99.9% | Monthly |
| **Feature Freshness** | < 5 minutes | Continuous (via Flink) |
| **Error Rate** | < 0.1% | Rolling 10-minute window |

## 4. Service Level Agreements (SLA)
* **System Degradation:** If $P99$ latency exceeds 500ms for more than 15 minutes, the on-call engineer is paged.
* **Critical Outage:** If availability drops below 95% for 5 minutes, the automated fallback (default rankings) is engaged and a status incident is created.

## 5. Fallback & Error Handling Policy
* **Ranking Failure:** If the Python Ranking Service is unavailable, the system must return the filtered candidate list in its original order.
* **Feature Store Failure:** If the Go Feature Store or Redis is unavailable, the system must use "Mean/Default" feature vectors to ensure a response is still served.