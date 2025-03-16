# Running the Java Hello World Application with Podman

This guide provides instructions for building and running the Java Hello World application in a container using Podman on RHEL or another Linux distribution.

## Prerequisites

- Podman installed on your system
- Basic familiarity with container concepts
- Git (optional, for cloning the repository)

## Step 1: Prepare the Files

Create the following files in your working directory:

**1. HelloWorld.java**

```java
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Welcome to Red Hat Enterprise Linux 9 on AWS Graviton!");
    }
}
```

**2. index.html**

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RHEL 9 on AWS Graviton</title>
    <style>
        body {
            font-family: 'Red Hat Text', Arial, sans-serif;
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            background-color: #f5f5f5;
        }
        
        .banner {
            background-color: #ee0000;
            color: white;
            width: 100%;
            padding: 20px 0;
            text-align: center;
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 30px;
        }
        
        .logo-container {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 40px;
            margin-bottom: 30px;
        }
        
        .logo {
            height: 150px;
            object-fit: contain;
        }
        
        @media (max-width: 768px) {
            .logo-container {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <div class="banner">
        Welcome to Red Hat Enterprise Linux 9 on AWS Graviton!
    </div>
    
    <div class="logo-container">
        <img src="https://upload.wikimedia.org/wikipedia/commons/d/d8/Red_Hat_logo.svg" alt="Red Hat Logo" class="logo">
        <img src="https://d2908q01vomqb2.cloudfront.net/da4b9237bacccdf19c0760cab7aec4a8359010b0/2021/11/29/Site-Merch_EC2-Graviton3_Blog.png" alt="AWS Graviton Logo" class="logo">
    </div>
</body>
</html>
```

**3. Dockerfile**

```dockerfile
# Use CentOS 9 Stream as base image
FROM quay.io/centos/centos:stream9

# Set maintainer label
LABEL maintainer="Red Hat Solutions Architect"

# Install OpenJDK and httpd
RUN dnf -y install java-17-openjdk-devel httpd && \
    dnf clean all

# Create app directory
WORKDIR /app

# Copy the Java source code
COPY HelloWorld.java /app/

# Copy the HTML file to httpd's document root
COPY index.html /var/www/html/

# Configure httpd to listen on port 8080 instead of 80
RUN sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf && \
    # Also update any references to port 80 in the welcome page configs
    sed -i 's/:80/:8080/g' /etc/httpd/conf.d/welcome.conf

# Compile the Java code
RUN javac HelloWorld.java

# Expose port 8080 for httpd
EXPOSE 8080

# Create start script
RUN echo '#!/bin/bash' > /app/start.sh && \
    echo 'httpd -k start' >> /app/start.sh && \
    echo 'java HelloWorld' >> /app/start.sh && \
    chmod +x /app/start.sh

# Run both the web server and the Java application
CMD ["/app/start.sh"]
```

## Step 2: Build the Container Image

Build the container image using Podman:

```bash
podman build -t hello-rhel9-graviton .
```

## Step 3: Run the Container Locally

Run the container with Podman:

```bash
podman run -p 8080:8080 hello-rhel9-graviton
```

This will:
1. Start the Apache web server on port 8080
2. Run the Java application that prints "Welcome to Red Hat Enterprise Linux 9 on AWS Graviton!"

The terminal will display the Java application output, and you can access the web interface at http://localhost:8080

## Step 4: Build for Different Architectures (Optional)

If you need to build for ARM64 architecture (AWS Graviton):

```bash
# Requires Podman v4.0+
podman build --arch arm64 --os linux -t hello-rhel9-graviton:arm64 .
```

## Step 5: Push to a Registry (Optional)

To share your image or deploy it to OpenShift later:

```bash
# Tag the image
podman tag hello-rhel9-graviton quay.io/yourusername/hello-rhel9-graviton:latest

# Push to registry (login first if needed)
podman login quay.io
podman push quay.io/yourusername/hello-rhel9-graviton:latest
```

## Troubleshooting

- **Permission Issues**: If you encounter permission issues, try adding `--security-opt label=disable` to your `podman run` command.
- **Port Conflicts**: If port 8080 is already in use, change the port mapping (e.g., `-p 8081:8080`).
- **SELinux Issues**: On RHEL with SELinux, you might need to use `:z` or `:Z` volume options for persistent volumes.