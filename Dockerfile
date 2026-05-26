# Use the official Ruby 3.4.5 image (slim version to keep it lightweight)
FROM ruby:3.4.5-slim

# Set the working directory inside the container
WORKDIR /app

# Enable system package modifications for pip globally in the container (PEP 668 bypass)
ENV PIP_BREAK_SYSTEM_PACKAGES=1

# Install basic development utilities plus python3 and python3-pip
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Install Microsoft Presidio and Spacy model dependencies globally in container
RUN pip3 install --no-cache-dir --break-system-packages presidio-analyzer presidio-anonymizer click spacy && \
    python3 -m spacy download en_core_web_sm

# Install active_genie gem globally inside the container
RUN gem install active_genie

# Copy all repository files into the container
COPY . .

# Default command is interactive shell so users can run any chat script easily
CMD ["/bin/bash"]
