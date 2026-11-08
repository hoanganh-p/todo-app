
# Todo Application - AWS EC2 Deployment

A Todo REST API built with Golang and PostgreSQL, with a focus on Linux server administration, containerization, cloud deployment, and DevOps automation.

The project aims to demonstrate practical experience in developing, deploying, and operating a web application on AWS infrastructure.

## Architecture

### Planned Architecture

```text
                  User / Browser
                        |
                      HTTPS
                        |
                  AWS EC2 Instance
                   Ubuntu Linux
                        |
                      Nginx
                  (Reverse Proxy)
                        |
                  Golang REST API
                        |
                    PostgreSQL
                 (Persistent Volume)


          CI/CD: GitHub Actions
          Infrastructure: AWS EC2
          Monitoring: AWS CloudWatch
```

> Note: The deployment architecture is currently under development.
> Components will be added incrementally.

## Tech Stack

| Category | Technology |
|---|---|
| Backend | Golang |
| Database | PostgreSQL |
| Cloud Platform | AWS |
| Compute | Amazon EC2 |
| Operating System | Ubuntu Linux |
| Containerization | Docker |
| Container Orchestration | Docker Compose |
| Web Server | Nginx |
| CI/CD | GitHub Actions |
| Monitoring | Amazon CloudWatch |

## Project Goals

- Build a RESTful Todo API using Golang.
- Integrate PostgreSQL for persistent data storage.
- Containerize the application using Docker.
- Deploy the application on AWS EC2 running Ubuntu Linux.
- Configure Nginx as a reverse proxy.
- Implement automated deployment using GitHub Actions.
- Practice Linux server administration and troubleshooting.
- Implement application monitoring and logging.

## Features

- Create a Todo
- Retrieve Todo items
- Update a Todo
- Delete a Todo
- Persistent data storage with PostgreSQL
- Application health check


## Development Roadmap

### Phase 1: Application Development
- [ ] Implement RESTful Todo API using Golang.
- [ ] Integrate PostgreSQL.
- [ ] Implement database migrations.
- [ ] Add application configuration through environment variables.
- [ ] Implement health check endpoint.

### Phase 2: Containerization
- [ ] Create a Dockerfile using multi-stage builds.
- [ ] Configure Docker Compose.
- [ ] Set up PostgreSQL persistent volumes.
- [ ] Configure Docker networking.
- [ ] Test the application locally.

### Phase 3: AWS EC2 Deployment
- [ ] Launch an Ubuntu EC2 instance.
- [ ] Configure SSH access and Security Groups.
- [ ] Install and configure Docker.
- [ ] Deploy application containers.
- [ ] Configure Nginx as a reverse proxy.
- [ ] Configure HTTPS using Let's Encrypt.

### Phase 4: CI/CD Automation
- [ ] Create GitHub Actions workflows.
- [ ] Automate Go application testing.
- [ ] Build and publish Docker images.
- [ ] Automate deployment to EC2.
- [ ] Implement post-deployment health checks.

### Phase 5: Monitoring and Reliability
- [ ] Configure application logging.
- [ ] Monitor EC2 metrics using CloudWatch.
- [ ] Implement PostgreSQL backup and restore.
- [ ] Document troubleshooting procedures.


