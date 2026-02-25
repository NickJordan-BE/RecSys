# System Architecture: High-Performance Recommendation Engine

## 1. Overview
This project implements a multi-stage recommendation pipeline designed for **sub-200ms $P99$ latency**. It utilizes a **Polyglot Microservices** approach, leveraging **Java 21 (LTS)** for orchestration and filtering, **Go** for high-speed feature retrieval, and **Python** for ML/AI ranking. The architecture is designed to be deployed via **ArgoCD** on **Kubernetes**, with **Terraform** managing the cloud-native "hardware" layer.

---

## 2. Service Map & Technology Stack

| Service | Language | Core Role | Key Technologies |
| :--- | :--- | :--- | :--- |
| **Ingress** | N/A | SSL Termination & Global Load Balancing. | NGINX Ingress Controller |
| **Orchestrator** | Java 21 | **Smart Gateway**, Auth, & Scatter-Gather. | Spring Boot 3.4, Virtual Threads |
| **Feature Store**| Go | High-speed online user feature retrieval. | Redis Cluster, gRPC |
| **Candidate Gen**| Python | Retrieval (User Tower + Vector Search). | PyTorch, Milvus/Faiss |
| **Filtering** | Java 21 | Business rules & hard constraints. | Spring Boot, Redis Sidecar |
| **Ranking** | Python | Final Scoring & Re-ranking. | FastAPI, XGBoost, Triton |
| **Data Lake** | N/A | Offline storage & ETL Catalog. | AWS S3, Apache Iceberg, Glue |

---

## 3. The Refreshed Online Inference Pipeline

The **Java Orchestrator** manages the inference lifecycle using a non-blocking **Scatter-Gather** pattern, treating external calls as lightweight tasks.

### **Step 1: The Gateway & Context**
Request hits the **NGINX Ingress** and is forwarded to the **Java Orchestrator**. The Orchestrator decodes the JWT, validates the `user_id`, and initiates the parallel fan-out.

### **Step 2: The Scatter Phase (Parallel)**
The Orchestrator spawns Virtual Threads to perform two simultaneous operations:
* **Go Feature Store:** Fetches **User Features** (age, location, recent clicks) from the **Centralized Redis Cluster**.
* **Python Candidate Gen:** Retrieves the top ~500 **Item IDs** using vector similarity search.

### **Step 3: The Filtering Phase**
The Orchestrator passes the 500 IDs + User Features to the **Java Filtering Service**.
* **Logic:** It applies business constraints (e.g., "Out of Stock," "Age Gating").
* **Optimization:** Uses a **Redis Sidecar** for local, sub-millisecond lookups of global item metadata (e.g., stock status).
* **Outcome:** The list is narrowed to ~400 "valid" candidates.

### **Step 4: The Ranking Phase (Feature Fusion)**
The Orchestrator sends the Filtered IDs + User Features to the **Python Ranking Service**.
* **Item Feature Hydration:** The Ranking service fetches **Item Features** (category, brand, price) from its own **Local Redis Sidecar** or the Go service.
* **Model Execution:** The ML model fuses User + Item vectors to generate a score.
* **NVIDIA Triton:** Top 50 items are passed to Triton (GPU) for heavy Deep Learning re-ranking.

### **Step 5: The Gather Phase**
The Orchestrator gathers the ranked results, performs final formatting, and returns a JSON response.

---

## 4. Resilience & Path Failovers
The system is built to handle "Dark Paths" without crashing the entire pipeline:
* **Redis Cache Miss:** If User Features are missing, the **Go Feature Store** returns a "Default Mean Vector."
* **Service Timeout:** If the Ranking service exceeds a 50ms budget, **Resilience4j** triggers a fallback, returning the filtered (but unranked) list to the user.
* **Circuit Breaking:** If the Filtering service starts throwing 5xx errors, the Orchestrator "opens the circuit" to prevent cascading failure, bypassing the service until it's healthy.

---

## 5. Development vs. Production Strategy

### **Development (Inner Loop)**
* **Tooling:** **Kind** (Kubernetes in Docker) + **Tilt**.
* **Workflow:** Code changes are instantly synced into the local Kind cluster. This allows for testing gRPC connectivity and service-to-service communication on a developer's laptop without the 5-minute CI/CD wait.

### **Production (Outer Loop)**
* **Infrastructure:** **Terraform** provisions the EKS/GKE cluster, S3/Iceberg tables, and Redis Cluster.
* **Deployment:** **ArgoCD** follows the **GitOps** model, syncing the **Helm Umbrella Chart** from the main branch to the production environment.
* **Secrets:** Managed via AWS Secrets Manager and injected into Pods at runtime.

---

## 6. Optimization Principles
* **Virtual Threads:** Uses `spring.threads.virtual.enabled=true` for non-blocking I/O.
* **ID-First Protocol:** Only 64-bit Long IDs are passed between internal services; full metadata is only hydrated at the final edge.
* **Sync Waves:** ArgoCD uses annotations to ensure the **Feature Store (Go)** is healthy before the **Orchestrator (Java)** begins receiving traffic.