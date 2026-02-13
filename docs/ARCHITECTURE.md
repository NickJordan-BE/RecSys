# System Architecture: High-Performance Recommendation Engine

## 1. Overview
This project implements a multi-stage recommendation pipeline designed for sub-200ms $P99$ latency. The system utilizes a **Polyglot Microservices** approach, leveraging **Java Spring Boot** for robust orchestration, **Go** for high-speed feature serving, and **Python** for ML/AI tasks.



---

## 2. Service Map & Technology Stack

| Service | Language | Core Role | Key Technologies |
| :--- | :--- | :--- | :--- |
| **API Gateway** | Go | Auth, Rate Limiting, Ingress. | Gin, JWT, gRPC-Web |
| **Orchestrator** | Java | Scatter-Gather coordination & Fan-out. | Spring Boot 3.4+, Virtual Threads |
| **Candidate Gen** | Python | Retrieval (User Tower + Vector Search). | PyTorch, Milvus/Faiss |
| **Feature Service** | Go | High-speed online feature fetching. | Redis (MGET), gRPC |
| **Filtering** | Java | Business logic & Hard constraints. | Spring Boot, Virtual Threads |
| **Ranking** | Python | Scoring & Re-ranking (GBDT + DL). | FastAPI, XGBoost, Triton |
| **Feedback Loop**| Java | Near-line feature updates. | Apache Flink, Kafka |
| **Offline ETL** | Python | Model training & Batch processing. | PySpark, Airflow, MLflow |

---

## 3. The Online Inference Lifecycle (The "Happy Path")

The **Java Orchestrator** manages the inference lifecycle using a non-blocking **Scatter-Gather** pattern:

1. **Ingress:** Request hits the **Go API Gateway** $\to$ forwarded to **Java Orchestrator**.
2. **Scatter Phase (Parallel):**
    * The **Orchestrator** spawns Virtual Threads to call **Python Candidate Gen** (Top 500 IDs) and the **Go Feature Service** (User Features) simultaneously.
3. **Filtering Phase:** The Orchestrator passes IDs + User Features to the **Java Filtering Service**.
4. **Ranking Phase (The Cascade):**
    * **Light Ranking:** **Python Ranking Service** scores 500 items via local GBDT.
    * **Heavy Ranking:** Top 50 items are sent to **NVIDIA Triton** (GPU) for Deep Learning scoring.
5. **Gather Phase:** Final re-ranking occurs in the Python layer before the **Java Orchestrator** gathers and returns the final JSON response.

---

## 4. Key Java Orchestration Optimizations
* **Virtual Threads (Project Loom):** By enabling `spring.threads.virtual.enabled=true`, the Orchestrator can handle thousands of concurrent fan-out requests without thread-pool exhaustion.
* **Structured Concurrency:** Uses `StructuredTaskScope` to ensure that if one service call (e.g., Feature Store) fails, all other related parallel calls are cancelled immediately to save resources.
* **Resilience4j Integration:** The Java layer utilizes native circuit breakers and retries to handle transient failures in the Python/Go downstream services.

---

## 5. Data & Feature Strategy
* **Online Store (Redis):** Logical partitioning with `batch:` (Spark) and `stream:` (Flink) prefixes.
* **Sidecar Pattern:** Redis sidecars are attached to the **Python Ranking** nodes for zero-latency item feature lookups.

---

## 6. Optimization Principles
* **ID-First Protocol:** Orchestrator only passes 64-bit Long IDs. Metadata hydration only happens at the Gateway edge.
* **JIT Warmup:** The Orchestrator is configured with a warmup period to allow the JVM to optimize hot execution paths before receiving peak production traffic.