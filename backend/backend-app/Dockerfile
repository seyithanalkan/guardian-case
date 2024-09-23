# Use Python base image
FROM python:3.9-slim

# Create a non-root user
RUN useradd -ms /bin/bash appuser

# Set working directory
WORKDIR /app

# Install PostgreSQL development libraries
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev

# Set AWS region environment variable
ENV AWS_DEFAULT_REGION=eu-north-1 

# Copy the requirements file and install dependencies
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

# Copy the rest of the application files
COPY . .

# Change ownership to the non-root user
RUN chown -R appuser:appuser /app

# Switch to the non-root user
USER appuser

# Command to run the application
CMD ["python", "app.py"]