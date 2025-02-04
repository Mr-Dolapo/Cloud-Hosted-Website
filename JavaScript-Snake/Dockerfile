# Use the latest official NGINX image as the base image.
FROM nginx:latest

# Copy the contents of the current directory (website files) into the container's 
# Default NGINX content directory (/usr/share/nginx/html/), so NGINX can serve the files.
COPY . /usr/share/nginx/html/

# Expose port 80 for HTTP traffic.
EXPOSE 80

# Expose port 443 for HTTPS traffic.
EXPOSE 443
