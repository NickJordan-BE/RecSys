# System Architecture: High-Performance Recommendation Engine

## 1. Overview
This project implements a production-grade Recommendation System (RecSys) built on a **Lambda Architecture**, strictly designed for **sub-200ms $P99$ latency**. It utilizes a **Polyglot Microservices** approach, leveraging **Java 21 (LTS)** for asynchronous orchestration and filtering, **Go** for high-speed I/O feature retrieval, and **Python** for machine learning compute. The cloud-native infrastructure is provisioned via **Terraform** and deployed continuously via **ArgoCD** on **Kubernetes**.



---

## 2. Service Map & Technology Stack

| Service | Language | Core Role | Key Technologies |
| :--- | :--- | :--- | :--- |
| **Ingress** | N/A | SSL Termination & Global Load Balancing. | NGINX Ingress Controller |
| **Orchestrator** | Java 21 | **Smart Gateway**, Auth, & Scatter-Gather. | Spring Boot 3.4, Virtual Threads |
| **Feature Store** | Go | High-speed online user feature retrieval. | Redis Cluster, gRPC |
| **Candidate Gen** | Python / Native | Retrieval (User Tower + Vector Search). | Qdrant / Milvus |
| **Filtering** | Java 21 | Business rules & hard constraints. | Spring Boot, Redis Sidecar |
| **Ranking** | Python | Final Scoring & Re-ranking. | FastAPI, XGBoost, Triton |
| **ETL / Stream** | Java / Python | Real-time & batch feature engineering. | Kafka, Flink, Spark, Airflow |
| **Data Lake** | N/A | Offline storage & Golden Dataset Catalog. | AWS S3, Apache Iceberg |
| **Observability** | N/A | Centralized logging, metrics, and tracing. | PLG Stack, Prometheus, OpenTelemetry |

---

## 3. The Online Inference Pipeline (The "Fast Path")
The **Java Orchestrator** manages the inference lifecycle using a non-blocking **Scatter-Gather** pattern, treating external network calls as lightweight tasks via Java 21 Virtual Threads. 

### **Step 1: The Gateway & Context**
The request hits the **NGINX Ingress** and is forwarded to the **Java Orchestrator**. The Orchestrator decodes the JWT, validates the `user_id`, generates an OpenTelemetry `trace_id`, and initiates the parallel fan-out.

### **Step 2: The Scatter Phase (Parallel Fan-Out)**
The Orchestrator spawns Virtual Threads to perform simultaneous operations:
* **Go Feature Store:** Fetches **User Features** (age, location, recent clicks) and the pre-computed **User Embedding**.
* **Candidate Gen:** Passes the User Embedding to **Qdrant** (Vector DB) to retrieve the top 500 **Item IDs** via Approximate Nearest Neighbor (ANN) search.



### **Step 3: The Filtering Phase**
The Orchestrator passes the 500 IDs + User Features to the **Java Filtering Service**.
* **Logic:** Applies business constraints (e.g., age-gating, already-seen items).
* **Optimization:** Uses a **Redis Sidecar** for local, sub-millisecond lookups of global item metadata (e.g., out-of-stock status).
* **Outcome:** The list is narrowed to ~100 "valid" candidates.



### **Step 4: The Ranking Phase (Late Enrichment & Fusion)**
The Orchestrator sends the Filtered IDs + User Features to the **Python Ranking Service**.
* **Item Feature Hydration:** Using an **ID-First Protocol**, full item features are only hydrated at this final stage to save bandwidth, fetched from the Go service or a local cache.
* **Coarse Ranker:** A local GBDT model (XGBoost) fuses User + Item vectors to generate an initial score, keeping the top 50 items.
* **Fine Ranker:** Top 50 items are converted to NumPy tensors and passed to **NVIDIA Triton** for heavy Deep Learning re-ranking.

### **Step 5: The Gather Phase**
The Orchestrator gathers the ranked results, performs final JSON formatting, returns the Top 10 list to the user, and asynchronously fires an Inference Log to Kafka.

---

## 4. Resilience & Path Failovers
The system is built to handle "Dark Paths" to prevent cascading failures and protect the $P99$ latency budget:
* **Redis Cache Miss:** If User Features are missing, the Go Feature Store returns a "Default Mean Vector" rather than failing the request.
* **Service Timeout:** If the Python Ranking service exceeds a strict latency budget, **Resilience4j** triggers a fallback, returning the filtered (but unranked) list to the user.
* **Circuit Breaking:** If the Filtering service starts throwing 5xx errors, the Orchestrator "opens the circuit," bypassing the service until health probes report it is stable.



---

## 5. Data & Feature Store Strategy
* **Online Feature Store (Redis):** Acts as the primary low-latency cache. Uses a **Push Model** for Item Features (all catalog items stay in RAM to avoid scatter-gather latency tails) and a **Cache-Aside Model** with a 7-day TTL for User Features.
* **Cold User Storage (Cassandra):** Stores the complete user base. Triggers an async repopulation of Redis upon a cache miss for inactive users.
* **Offline Feature Store (AWS S3 / Iceberg):** The system's "photographic memory" for high-throughput Spark batch jobs and point-in-time correct ML training.

---

## 6. Offline & Near-Line Pipeline (The Intelligence Loop)
* **Event Bus (Kafka):** Ingests `inference_logs` and `user_clicks`.
* **Near-Line Stream Processing (Java Flink):** Consumes streams to calculate real-time behavioral features (e.g., "last 5 clicks") and instantly materializes updates into Redis to prevent feature drift.
* **Batch & Continuous Training (Airflow + Spark):** Airflow orchestrates Spark to join logs into a labeled Golden Dataset, triggers Python training scripts, and pushes new model weights to the registry.



---

## 7. Development vs. Production Strategy

### **Development (Inner Loop)**
* **Tooling:** **Kind** (Kubernetes in Docker) + **Tilt**.
* **Workflow:** Code changes are instantly synced into the local Kind cluster, allowing for live gRPC connectivity testing without waiting for CI/CD builds.

### **Production (Outer Loop)**
* **Infrastructure as Code:** **Terraform** provisions the EKS/GKE cluster, S3/Iceberg tables, and managed databases.
* **GitOps Deployment:** **ArgoCD** syncs the **Helm Umbrella Chart** from the main branch to the production environment.
* **Sync Waves:** ArgoCD uses annotations to ensure the Feature Store and Databases are healthy before the Java Orchestrator begins receiving traffic.
* **Secrets:** Managed via AWS Secrets Manager and injected into Pods at runtime.

---

## 8. Core Optimization Principles
* **Virtual Threads:** `spring.threads.virtual.enabled=true` ensures the Java Orchestrator never blocks OS threads during heavy I/O waits.
* **ID-First Protocol:** Only 64-bit Long IDs are passed between internal services; heavy text/metadata is hydrated strictly at the edge to reduce network payload sizes.
* **Centralized Observability:** Every request is tracked via OpenTelemetry `trace_id`s, with logs aggregated in Loki and metrics scraped by Prometheus to drive Horizontal Pod Autoscaling (HPA).