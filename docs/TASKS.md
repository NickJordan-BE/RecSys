Phase 1: Day 0 - The Foundation (Infrastructure)
Goal: Establish the underlying compute, networking, and stateful backing services required for the cluster to operate. No application logic yet.

Kubernetes & Cluster Configuration
[X] Add readinessProbe and livenessProbe definitions to the base Helm chart.

[ ] Deploy NGINX Ingress Controller to Kubernetes cluster

[ ] Setup online repos for docker images and helm charts 

[ ] Add S3 lock to terraform environment

[ ] Refactor terraform to use EKS and AWS services for Kubernetes cluster

Stateful Services Provisioning
[ ] Deploy Redis (Online Feature Store) via Helm.

[ ] Deploy Cassandra (User Profile DB) via Helm.

[ ] Deploy Qdrant (Vector Database for Candidate Gen) via Helm.

[ ] Deploy MinIO (Local S3 alternative for Offline Feature Store / Data Lake).

Phase 2: Day 1 - The Walking Skeleton (CI/CD)
Goal: Automate the testing and deployment pipeline before writing complex application logic to maximize developer velocity.

Continuous Integration (GitHub Actions)
[ ] Create GitHub Action workflow for Java Orchestrator: Run JUnit tests, build Docker image, push to local registry.

[ ] Create GitHub Action workflow for Go Feature Store: Run Go tests, build Docker image, push to local registry.

[ ] Create GitHub Action workflow for Python Ranking Service: Run PyTest, build Docker image, push to local registry.

Continuous Deployment (GitOps)
[ ] Install ArgoCD into the recsys-ops namespace.

[ ] Connect ArgoCD to the GitHub repository containing the Helm charts.

[ ] Create an ArgoCD Application manifest to automatically sync changes from the main branch to the recsys-core namespace.

Phase 3: Day 1.5 - Online Inference Pipeline
Goal: Build the fast-path microservices, ensuring strict latency budgets using gRPC and parallel execution.

Java Orchestrator (The Gateway)
[ ] Define Protobuf (.proto) contracts for communication between Java, Go, and Python services.

[ ] Scaffold Spring Boot application with gRPC server/client dependencies.

[ ] Implement CompletableFuture fan-out to simultaneously request User Embedding (from Go) and global trending items.

[ ] Implement Candidate Generation client to query Qdrant directly using the User Embedding.

[ ] Implement Filtering Service logic (hard rules: remove seen items, out-of-stock items).

[ ] Implement "Late Enrichment" batch gRPC call to Go Feature Store for the filtered Item IDs.

Go Feature Store (High-Speed I/O)
[ ] Scaffold Go service with gRPC server.

[ ] Implement Redis client pool for sub-millisecond feature retrieval.

[ ] Implement "Cache-Aside" logic for Users: Query Redis -> On miss, query Cassandra -> Async write back to Redis with 7-day TTL.

[ ] Implement "Push Only" fetch logic for Items: Query Redis batch -> Drop missing items (no Cassandra fallback to protect latency).

Python Ranking Service & Triton (Precision ML)
[ ] Deploy Triton Inference Server via Helm, pointing to a mock model in MinIO.

[ ] Scaffold Python service (FastAPI or pure gRPC) to receive User + Item features.

[ ] Implement Coarse Ranker: Load local GBDT (XGBoost) model into Python memory to score and prune 500 items down to 50.

[ ] Implement Fine Ranker: Convert top 50 item features into NumPy Tensors and execute gRPC call to Triton Server.

[ ] Sort final scores and return Top 10 to Java Orchestrator.

Phase 4: Day 2 - Operation & Observability
Goal: Gain visibility into the system using centralized logging and distributed tracing.

Centralized Logging (The PLG Stack)
[ ] Deploy Loki and Promtail via Helm to aggregate logs.

[ ] Deploy Grafana and connect it to the Loki datasource.

[ ] Configure Java (Logback), Go (Zap), and Python (Loguru) to output strict JSON formatted logs to stdout.

Distributed Tracing & Metrics
[ ] Implement OpenTelemetry middleware in the Java Orchestrator to generate a trace_id on incoming requests.

[ ] Propagate the trace_id through gRPC headers to the Go and Python services.

[ ] Install Prometheus and Kubernetes Metrics Server.

[ ] Configure Horizontal Pod Autoscaler (HPA) to scale the Python Ranking service based on CPU utilization.

Phase 5: Day 3 - The Intelligence Loop (ETL & CT)
Goal: Close the feedback loop. Ingest clicks, update real-time features, and train the models.

Event Ingestion (Kafka)
[ ] Deploy Kafka cluster using the Strimzi Operator.

[ ] Provision inference_logs and user_clicks Kafka topics.

[ ] Update Java Orchestrator to asynchronously publish served recommendations to the inference_logs topic.

Near-Line Processing (Flink)
[ ] Scaffold Java Flink streaming application.

[ ] Implement windowed stream job to consume user_clicks, calculate real-time aggregations (e.g., "last 5 categories clicked").

[ ] Configure Flink sink to instantly materialize (write) these updated features into Redis.

Batch Processing & Model Training (Airflow & Spark)
[ ] Deploy Apache Airflow via Helm to manage DAGs.

[ ] Set up Kafka Connect (or a basic script) to dump Kafka topics into MinIO (S3) as Parquet files.

[ ] Write Spark job to generate historical Item Features (e.g., 30-day conversion rate) and materialize results to Redis.

[ ] Write Spark job to join Inference Logs with Click Logs to create the "Golden Dataset" (Labels: 1 or 0).

[ ] Create Airflow DAG to trigger a Python training script (updating the XGBoost and Triton models) and push new weights to the Model Registry.