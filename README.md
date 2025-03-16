# Running the Java Hello World Application with Podman

This guide provides instructions for building and running the Java Hello World application in a container using Podman on RHEL or another Linux distribution.

## Prerequisites

- Podman installed on your system
- Basic familiarity with container concepts
- The image files (RedHat.png and Graviton.png) in an "images" directory

## Step 1: Prepare the Directory Structure

First, create a project directory with the correct structure:

```bash
# Create project directory
mkdir -p hello-rhel9-app
cd hello-rhel9-app

# Create images directory for the logo files
mkdir -p images
```

Place your logo files in the images directory:
- `images/RedHat.png`
- `images/Graviton.png`

Your directory structure should look like this:
```
hello-rhel9-app/
├── images/
│   ├── RedHat.png
│   └── Graviton.png
```

## Step 2: Create the Required Files

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
        <img src="/images/RedHat.png" alt="Red Hat Logo" class="logo">
        <img src="/images/Graviton.png" alt="AWS Graviton Logo" class="logo">
    </div>
</body>
</html>
```

**3. Directory Structure**

Create a directory for the images:

```bash
mkdir -p images
```

Place the following files in the images directory:
- images/RedHat.png
- images/Graviton.png

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

# Create images directory in httpd document root
RUN mkdir -p /var/www/html/images

# Copy the image files to httpd's document root
COPY images/RedHat.png /var/www/html/images/
COPY images/Graviton.png /var/www/html/images/

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

## Step 3: Verify Your Directory Structure

Before building, make sure your directory structure looks like this:

```
hello-rhel9-app/
├── Dockerfile
├── HelloWorld.java
├── index.html
└── images/
    ├── RedHat.png
    └── Graviton.png
```

You can verify this with:

```bash
find . -type f | sort
```

The output should include these files:
```
./Dockerfile
./HelloWorld.java
./images/Graviton.png
./images/RedHat.png
./index.html
```

## Step 4: Build the Container Image

Build the container image using Podman:

```bash
podman build -t hello-rhel9-graviton .
```

During the build process, you should see the steps from the Dockerfile being executed, including:
- Installing OpenJDK and httpd
- Copying the Java file, HTML file, and image files
- Creating the images directory
- Compiling the Java code

If you encounter any errors related to missing image files, verify that:
1. The `images` directory exists in the same directory as your Dockerfile
2. The image files are named exactly `RedHat.png` and `Graviton.png`
3. The files are directly inside the `images` directory (not in subdirectories)

## Step 5: Run the Container Locally

Run the container with Podman:

```bash
podman run -p 8080:8080 hello-rhel9-graviton
```

This will:
1. Start the Apache web server on port 8080
2. Run the Java application that prints "Welcome to Red Hat Enterprise Linux 9 on AWS Graviton!"

The terminal will display the Java application output, and you can access the web interface at http://localhost:8080

To verify that the images are being served correctly:
1. Open http://localhost:8080 in your browser
2. You should see both logos displayed side by side
3. If the images don't appear, check your browser's developer tools (F12) to see if there are any 404 errors for the image paths

To run the container in the background:

```bash
podman run -d --name hello-rhel9-container -p 8080:8080 hello-rhel9-graviton
```

You can then check the logs with:

```bash
podman logs hello-rhel9-container
```

## Step 6: Build for Different Architectures (Optional)

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