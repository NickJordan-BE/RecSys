# Engineering Style Guide & Conventions

This document defines the coding standards for our polyglot microservices architecture. Consistency across **Java**, **Go**, and **Python** is paramount for maintainability, especially in a high-performance environment like a recommendation engine.

---

## 1. Language Style Guides
We utilize industry-standard guides to ensure the codebase remains professional and readable:

* **Java:** [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html)
* **Go:** [Uber Go Style Guide](https://github.com/uber-go/guide/blob/master/style.md)
* **Python:** [PEP 8](https://peps.python.org/pep-0008/) and the [Google Python Style Guide](https://google.github.io/styleguide/pyguide.html)

---

## 2. Naming Conventions

### 2.1 Cross-Language Grammar
| Entity | Java | Go | Python | Protobuf |
| :--- | :--- | :--- | :--- | :--- |
| **Classes/Types** | `PascalCase` | `PascalCase` | `PascalCase` | `PascalCase` |
| **Methods/Funcs** | `camelCase` | `PascalCase`* | `snake_case` | N/A |
| **Variables** | `camelCase` | `camelCase` | `snake_case` | `snake_case` |
| **Constants** | `SCREAMING_SNAKE` | `PascalCase` | `SCREAMING_SNAKE` | `SCREAMING_SNAKE` |
| **Files** | `PascalCase.java` | `snake_case.go` | `snake_case.py` | `snake_case.proto` |

*\*In Go, PascalCase denotes an exported (public) function or field.*

### 2.2 Protobuf Specifics
Always use **snake_case** for field names in `.proto` files. The compiler will automatically handle the conversion to the idiomatic format for each language (e.g., `user_id` becomes `getUserId()` in Java and `UserId` in Go).

---

## 3. Tooling & Automation
We use automated formatters and linters to enforce these styles. **Run these tools before every commit.**

### **Java (Spotless & Checkstyle)**
* **Apply Format:** `./mvnw spotless:apply`
* **Check Style:** `./mvnw checkstyle:check`

### **Go (gofmt & golangci-lint)**
* **Format:** `go fmt ./...`
* **Lint:** `golangci-lint run`

### **Python (Ruff)**
We use **Ruff** for lightning-fast linting and formatting.
* **Lint & Fix:** `ruff check --fix`
* **Format:** `ruff format`

---

## 4. Directory Structure
Our monorepo follows a predictable structure to keep infrastructure and application logic separate:

/recsys-project
├── services/           # Application Microservices
│   ├── filtering/      # Java
│   ├── ranking/        # Python
│   └── feature-store/  # Go
├── infra/              # Infrastructure as Code
│   ├── terraform/      # Cloud Provisioning
│   ├── helm/           # Kubernetes Blueprints
│   └── argocd/         # GitOps Manifests
├── dev/                # Local Development (Tilt/Kind)
└── docs/               # RFCs, ADRs, and SLOs
---

## 5. Commit Message Standards
We follow the Conventional Commits specification to ensure a readable and automated commit history:

**Format**: type(scope): description

**Common Types**:

* feat: A new feature (e.g., feat(filter): add redis sidecar for item metadata)

* fix: A bug fix

* docs: Documentation only changes

* perf: A code change that improves performance

* refactor: A code change that neither fixes a bug nor adds a feature

---