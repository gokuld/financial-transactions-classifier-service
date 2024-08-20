## Overview

This repository provides a service for classifying product
descriptions into predefined categories. It encompasses the end to end
workflow from building and training a machine learning model to
deploying it as a REST API service. The service processes product
descriptions and returns the appropriate product category as a string.

The initial implementation features a baseline model trained on a
sample dataset. The sample dataset is included in the repository. This
model serves as a starting point for predictions. During deployment,
the repository code sets up the Airflow workflow to train the initial
baseline model, log experiments with MLflow, and deploy the model as
an API service.


## System Architecture

The architecture of this solution is designed for efficient management
and deployment of the product classification service. The components
of the system include:

1. **MLflow Server**:
- Deployed on an EC2 instance.
- Used for tracking experiments and managing model versions.

2. **Apache Airflow**:
- Also deployed on an EC2 instance.
- Orchestrates the model training process and other workflows.

3. **BentoML Service**:
- Deployed on a separate EC2 instance.
- Hosts the trained model as an API service and provides a Swagger UI
  for testing the product category prediction.

4. **Data Storage**:
- **S3 Bucket**: Stores both the training dataset and MLflow
  artifacts. The bucket is private and has a VPC endpoint, ensuring
  that only internal services within the VPC can access it.

5. **Databases**:
- Both MLflow and Airflow use local databases for their operations.

6. **Infrastructure Automation**:
- **Infrastructure as Code (IaC)**: Managed with Terraform, automating
  the setup of EC2 instances, S3 buckets, and network
  configurations. This approach ensures consistency, scalability,
  maintainability, and minimizes errors.


## Setup, Deployment, and Usage

### Prerequisites

Ensure you have the following tools and configurations:

- **AWS Account**: With permissions to create and manage resources.
- **Terraform**: For infrastructure automation.
- **Git**: For cloning the repository.

### Setup

1. **Clone the Repository and switch to the `dev` branch**:
   ```sh
   git clone git@github.com:gokuld/product-category-prediction.git
   cd product-category-prediction
   git checkout dev
   ```
2. **Create AWS Key Pairs**:

- Create the following key pairs in AWS and store the private keys in
  the specified locations:

| Key Name       | Location                                              |
|----------------|-------------------------------------------------------|
| Model Service  | `./terraform/modules/model_service/Model Service.pem` |
| AirFlow Server | `./terraform/modules/airflow/AirFlow Server.pem`      |

This step allows for uploading local files to the AWS EC2 instance,
such as the Airflow DAG scripts directory to the Airflow server.

3. **Deploy the Infrastructure**:
   ```sh
   cd terraform
   terraform init
   terraform apply
   ```
- During the `terraform apply` step, Terraform will prompt for values
  for any variables that are not predefined. Here is an example of
  values you may need to provide:

| Variable                               | Example Value        |
|----------------------------------------|----------------------|
| `aws_region`                           | `ap-south-1`         |
| `availability_zone_a`                  | `ap-south-1a`        |
| `availability_zone_b`                  | `ap-south-1b`        |
| `mlflow_artifact_store_s3_bucket_name` | `product-categorize` |
| `dataset_bucket_name`                  | `product-categorize` |

- After Terraform finishes applying, note the URIs for the MLflow
server, Airflow server, and model API service (public IP and host)
from the Terraform output.

4. **Trigger Model Training**:
- Open the Airflow UI using the URI provided in the Terraform output.
- Trigger the DAG named predict_category_model_training_dag. This will
  train the model, track it on MLflow, and register it.

5. **Test the Prediction Service**:
Access the Swagger UI of the model prediction API using the URL
provided in the Terraform output. To evaluate the model, input a
sample product description, such as "A set of paring knives." The
model should return the predicted category, in this case, "Kitchen and
Dining."


## Code Quality and Continuous Integration

1. **Code Formatting and Linting**:
   - **Black**: Used for consistent code formatting across the Python
     codebase.
   - **Flake8**: Ensures the code adheres to Python style guidelines
     and catches potential issues.
   - **isort**: Automatically sorts imports to maintain a consistent
     import order.
   - **mypy**: Used for static type checking to catch type errors
     early in the development process.

2. **Pre-Commit Hooks**:
   - Pre-commit hooks are configured to automatically check code
     quality before each commit, including running the above tools and
     additional checks.

3. **Security and Secrets Management**:
   - **Bandit**: Scans code for common security issues and prevents
     secrets or credentials from being accidentally pushed to the
     repository.

4. **Infrastructure Security**:
   - **Trivy**: Integrated into the CI pipeline to automatically scan
     Terraform code for infrastructure security misconfigurations,
     ensuring a secure deployment.

5. **Continuous Integration (CI)**:
   - A CI pipeline is set up using **GitHub Actions** to automate code
     quality checks, infrastructure security scans, and other
     validation tasks, ensuring that every change is rigorously tested
     before being merged.


## Roadmap

1. **Scalable Deployment**:
   - Implement scalable deployment options using **ECS** (Elastic
     Container Service) or **Kubernetes** with Docker to handle
     increased load and ensure high availability.

2. **Monitoring and Observability**:
   - Integrate **Prometheus** and **Grafana** for robust monitoring
     and observability, enabling detailed metrics, alerts, and visual
     dashboards to track the performance of the system.

3. **Security and Reliability**:
   - Set up **HTTPS** and a domain name for secure, encrypted
     communication with the services.
   - Use **Amazon Route 53** to configure persistent URIs for MLflow,
     Airflow, and the model API service, ensuring they are
     consistently reachable.

4. **API Management**:
   - Implement **API Gateway** to manage, secure, and scale the model
     API service, providing a unified entry point for API consumers
     and enabling more advanced features like throttling and caching.

5. **Testing**:
   - Implement **unit tests** and **integration tests**.
