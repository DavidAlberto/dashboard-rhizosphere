# Base image
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    sudo \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clone the repo
WORKDIR /app
RUN git clone https://github.com/DavidAlberto/dashboard-rhizosphere.git

# Run the setup script
WORKDIR /app/dashboard-rhizosphere
RUN chmod +x setup.sh && ./setup.sh

# Expose the port for the dashboard
# EXPOSE 3838

# Run the Quarto and Shiny dashboards
# CMD quarto preview && R -e "shiny::runApp('app', host='0.0.0.0', port=3838)"