# Use a lightweight official Python image as the base
FROM python:3.9-slim-buster

# Set the working directory in the container
WORKDIR /app

# Install Flask, a minimal web framework for Python
# `pip install --no-cache-dir` ensures a smaller image size by not storing package caches
RUN pip install --no-cache-dir Flask

# Copy the Flask application code into the container
# This assumes you have a file named 'server.py' in the same directory as your Dockerfile
COPY server.py .

# Expose port 80, indicating that the container listens on this port
# This is for documentation and network configuration, not actual binding
EXPOSE 80

# Define the command to run the Flask application
# It tells Flask to listen on all available interfaces (0.0.0.0) on port 80
CMD ["python", "server.py"]
