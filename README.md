# Project Overview

This project is designed to deploy and manage Kubernetes-based applications using **Terraform**, **ArgoCD**, and **GitHub Actions (CI/CD)**. It includes backend and frontend services, all managed in a modular and scalable way.

## Key Features

1. **Modular Infrastructure with Terraform**:
   - The infrastructure is designed using Terraform in a modular structure. This allows easy management based on environment or project using `.tfvars` files.
   - The setup includes network, EKS cluster and components, ArgoCD server, and ArgoCD applications.
   - Passwords and sensitive information are securely stored using **AWS Secrets Manager**, and applications can access them as needed.

2. **Backend Application**:
   - The backend service inserts node data into an RDS Postgres DB and provides this data via the `/nodes` endpoint.
   - A service account is defined for the backend pod, which gives access to RDS, Secrets Manager, autoscaling resources, and other AWS services.
   - It ensures secure interaction between the backend and the database.

3. **React Frontend Application**:
   - The React frontend application displays the node data from the backend API’s `/nodes` endpoint on the homepage.
   - It is integrated with the backend to provide real-time data to the users.

4. **CI/CD Pipeline**:
   - The CI/CD process is fully automated using **GitHub Actions** with 3 different jobs.
   - For **Terraform** changes: If the commit message contains the word "terraform", and there are changes in the `terraform` folder, the pipeline triggers.
   - For **Backend**: If there are changes in the `backend-app` folder and the commit message contains the word "backend", a Docker image is built, pushed to ECR with a GitHub SHA tag, and then the version is updated in the `backend-guardian` folder’s `values.yml` file. ArgoCD then detects the change and deploys the new version automatically.
   - The same process is followed for **Frontend** changes as well.

5. **Autoscaling and Monitoring**:
   - Horizontal Pod Autoscaler (HPA) and cluster autoscaling are configured via Terraform.
   - **Metrics Server** is set up to monitor the system, and logs are sent to **CloudWatch** using **Fluentbit**.
   - Additionally, an **SNS** notification is configured for autoscaling alerts, ensuring the infrastructure remains healthy and scalable.
   - For testing **Cluster Autoscaling**, a `terraform/dev/stress.yaml` file is included. You can deploy the stress test by running `kubectl apply -f terraform/dev/stress.yaml`, which triggers autoscaling based on the load generated.

6. **Running Locally**:
   - To run the project locally, you need to configure your AWS credentials (`AWS_ACCESS_KEY`, `AWS_SECRET_KEY` and DEFAULT_REGION) in your shell or OS environment.
   - In the `provider.tf`, define the **S3 bucket** for remote state management.
   - Modify the `.tfvars` file based on your environment, then navigate to the `terraform/dev` folder and run `terraform init` followed by `terraform apply` to deploy the infrastructure.
   - The recommended Terraform version is `v1.5.7`, which has been tested and works both locally and within GitHub Actions.
   - After deploying the infrastructure, commit a small change (such as a comment) to any file in the `backend-app` or `frontend-app` folders to trigger the deployment.
   - Retrieve the ArgoCD admin password from Secrets Manager and use the ArgoCD server's service URL to check the status of your applications.

7. **End-to-End Kubernetes Deployment**:
   - This setup ensures an end-to-end Kubernetes application deployment using ArgoCD. You can manage your Kubernetes clusters, backend, and frontend applications all in one automated pipeline.

8. **Screenshots for Verification**:
   - In the `Screenshots` folder, you will find images confirming that the program is working as expected. These screenshots provide a visual confirmation of the application's functionality, infrastructure deployment, and seamless CI/CD pipeline operations.

## Conclusion

This project provides a comprehensive solution for deploying Kubernetes applications from infrastructure to microservices in an automated and secure way. With the use of Terraform, GitHub Actions, and ArgoCD, all components work seamlessly together, making it easy to deploy, scale, and manage backend and frontend services. Additionally, stress tests for cluster autoscaling can be easily performed using the provided `stress.yaml` file.

