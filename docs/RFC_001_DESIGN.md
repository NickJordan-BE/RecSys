# RFC-001: High-Performance Recommendation System Design

## 1. Abstract
This document outlines the design for a low-latency, polyglot recommendation engine. The system is designed to handle a massive item catalog and user base by utilizing a multi-stage **Scatter-Gather** architecture. It prioritizes **P99 latency**, modularity between ML and Engineering teams, and a production-first deployment strategy using **Java 21**, **Go**, and **Python**.

## 2. Goals and Non-Goals
### Goals
* **Latency:** Achieve sub-200ms end-to-end inference ($P99$).
* **Scalability:** Support millions of concurrent users via Java 21 **Virtual Threads**.
* **Decoupling:** Enable independent scaling of Retrieval (Python), Filtering (Java), and Ranking (Python) services.
* **Reproducibility:** Maintain 1:1 parity between local development (**Kind/Tilt**) and production (**EKS/ArgoCD**).

### Non-Goals
* Building a custom vector database (utilizing Milvus or Faiss).
* Real-time model training (focusing on near-line feature updates via Flink).

## 3. Architecture Overview

### 3.1 Online Inference Pipeline
The online pipeline is a synchronous, non-blocking flow managed by a **Java 21 Orchestrator**.

1.  **Ingress Layer:** NGINX handles SSL termination and routes traffic to the Orchestrator.
2.  **Orchestration (Scatter):** The Java layer initiates parallel gRPC calls to the **Go Feature Store** (User Features) and the **Python Candidate Gen** (Item Retrieval).
3.  **Filtering Service:** A Java-based rules engine removes items based on hard constraints using a **Redis Sidecar** for local metadata lookups.
4.  **Ranking Service:** A Python-based ML layer hydrates **Item Features** and performs scoring. High-complexity models are offloaded to **NVIDIA Triton** (GPU) for scoring.



### 3.2 Offline & Near-line ETL Pipeline
* **Storage:** Data is stored in **AWS S3** using the **Apache Iceberg** table format for ACID compliance.
* **Batch Processing:** **PySpark** jobs run on Iceberg tables to compute long-term user/item embeddings.
* **Online Sink:** Calculated features are pushed to a **Centralized Redis Cluster** for millisecond retrieval.
* **Stream Processing:** **Apache Flink** handles "near-line" updates (e.g., recent clicks) to ensure feature freshness.

### 3.3 CI/CD and Infrastructure
* **Infrastructure as Code:** **Terraform** provisions the EKS cluster, Redis clusters, and S3 buckets.
* **Continuous Delivery:** **ArgoCD** implements a GitOps model, syncing Helm charts to the cluster.
* **Development Loop:** **Kind** and **Tilt** provide a local Kubernetes environment with live-code reloading.

## 4. Alternatives Considered
* **Monolithic Python Service:** Rejected due to the Global Interpreter Lock (GIL) and poor performance in high-concurrency I/O fan-out.
* **Direct Service Chaining:** Rejected to avoid tight coupling; the Orchestrator is required to manage complex failover logic and "Scatter-Gather" coordination.