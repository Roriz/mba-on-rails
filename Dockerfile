# Use the official Ruby 3.4.5 image (slim version to keep it lightweight)
FROM ruby:3.4.5-slim

# Set the working directory inside the container
WORKDIR /app

# Install basic development utilities (curl, build-essential, git, etc.)
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy all repository files into the container
COPY . .

# Default command is interactive shell so users can run any chat script easily
CMD ["/bin/bash"]
