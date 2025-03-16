# Running the Java Hello World Application with Podman

This guide provides simple instructions for building and running the Java Hello World application in a container using Podman.

## Prerequisites

- Podman installed on your system
- Git installed (for cloning the repository)

## Step 1: Clone the Repository

```bash
git clone https://github.com/ryannix123/java-app-aws-graviton.git
cd java-app-aws-graviton
```

## Step 2: Build the Container Image

```bash
podman build -t hello-rhel9-graviton .
```

## Step 3: Run the Container

```bash
podman run -p 8080:8080 hello-rhel9-graviton
```

Access the web interface at http://localhost:8080 to see the HTML page with Red Hat and AWS Graviton logos.

To run the container in the background:

```bash
podman run -d --name hello-rhel9-container -p 8080:8080 localhost/hello-rhel9-graviton httpd -DFOREGROUND
```

## Additional Options

### Building for ARM64 (AWS Graviton)

```bash
# Requires Podman v4.0+
podman build --arch arm64 --os linux -t hello-rhel9-graviton:arm64 .
```

### Pushing to a Registry

```bash
# Tag the image
podman tag hello-rhel9-graviton quay.io/yourusername/hello-rhel9-graviton:latest

# Login to the registry
podman login quay.io

# Push the image
podman push quay.io/yourusername/hello-rhel9-graviton:latest
```