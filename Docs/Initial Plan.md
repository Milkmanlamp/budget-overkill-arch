![[Pasted image 20260305182725.png]]
## Compute: ECS on Fargate

 - Supports Server-Side Rendering (SSR) natively, avoiding the cold starts and workarounds required by AWS Lambda.

- **ECS instead of EKS:** No control-plane tax. Significantly cheaper than running a Kubernetes (EKS) cluster.

- **Serverless:** No underlying EC2 instances to patch, scale, or manage. Billed strictly for allocated vCPU and RAM.

- **Networking (**⁠awsvpc **mode):** Automatically provisions a dedicated Elastic Network Interface (ENI) for the task, allowing for dedicated security groups and a public IP.

**Container Registry**

- **Amazon ECR:** Hosts the Next.js Docker images.

## Networking & Security

- **Topology:** 3 Availability Zones with 3 Public Subnets.

- **Budget-Optimized Design:** Avoided Private Subnets and NAT Gateways to save the $32/month idle cost. Security is enforced via strict Security Groups instead of network isolation.

- **ALB Security Group:** Allows inbound traffic on ports 80/443 from ⁠0.0.0.0/0.

- **Fargate Security Group:** Restricts inbound traffic on port 3000 to _only_ accept requests originating from the ALB Security Group.

- **VPC Gateway Endpoints:** Securely routes traffic from the Fargate containers directly to DynamoDB (and S3) bypassing the public internet

## Edge & DNS

- **Domain:** Domain registered externally; nameservers mapped to an Amazon Route 53 Public Hosted Zone.

- **Caching / CDN:** Amazon CloudFront sits in front of the ALB to cache static assets globally.

## Storage & Data Pipeline

- **Hot Storage:** DynamoDB for fast, serverless read/writes.

- **Event-Driven Pipeline:** DynamoDB Streams capture changes and push data through Kinesis Firehose directly into S3.

- **Athena Analytics:** AWS Glue (Data Catalog) defines the schema, allowing Amazon Athena to run standard SQL queries directly against the S3 data lake.

- **Secrets & Encryption:** AWS Systems Manager (SSM) Parameter Store handles application credentials. AWS Certificate Manager (ACM) manages the SSL/TLS certificates.

- **Data archiving:** S3 Lifecycle Rules automatically transition older data/backups into cheaper S3 Glacier archive storage.

## Observability & Health Tracking

- **External Synthetic Monitoring:** An EventBridge cron rule triggers a Lambda function every 5 minutes. Lambda pings the public CloudFront URL (checking if it resolves and returns correct content) and writes the test results to DynamoDB.

- **Internal Auto-Healing:** The ALB Target Group monitors container health. If a Fargate container fails its health check, ECS automatically terminates and replaces it.

- **Dashboards:** CloudWatch Dashboards aggregate infrastructure health metrics, combined with automated billing alarms to track full-site costs and prevent budget overruns.