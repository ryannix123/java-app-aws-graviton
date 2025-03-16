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

# Create images directory in httpd document root and copy the image files
RUN mkdir -p /var/www/html/images
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