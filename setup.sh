#!/usr/bin/env bash

# =============================================================================
# Setup Script for Dashboard Rhizosphere Project
# This script sets up the complete development environment including:
# - Git clone of the repository
# - Miniconda installation
# - Creation Python and R environment
# - Quarto installation
# =============================================================================

# Fail on any error, undefined variable, or pipe failure
set -euo pipefail

# Colors and logging configuration
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions for better visibility and debugging
log_error() { echo -e "${RED}[ERROR] $1${NC}" >&2; }
log_success() { echo -e "${GREEN}[SUCCESS] $1${NC}"; }
log_info() { echo -e "${BLUE}[INFO] $1${NC}"; }
log_warning() { echo -e "${YELLOW}[WARNING] $1${NC}"; }

# Function to handle errors
handle_error() {
    log_error "An error occurred on line $1"
    log_error "Context: $2"
    exit 1
}

# Set up error trap to catch failures with line numbers
trap 'handle_error ${LINENO} "$BASH_COMMAND"' ERR

# Function to display success messages
success() {
    echo -e "${GREEN}$1${NC}"
}

# Check if a command exists
check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "Required command '$1' not found"
        return 1
    fi
}

# Validate environment creation
validate_env() {
    local env_path=$1
    if [ ! -d "$env_path" ]; then
        log_error "Environment at $env_path was not created successfully"
        return 1
    fi
    log_success "Environment at $env_path validated successfully"
}

# Function to check if conda is initialized
check_conda_init() {
    log_info "Checking conda initialization..."

    # Check if conda command exists in path
    if ! command -v conda &> /dev/null; then
        log_warning "Conda command not found in PATH"
        return 1
    fi

    # Check if conda is initialized in current shell
    if ! conda info --envs &> /dev/null; then
        log_warning "Conda exists but is not properly initialized"
        return 1
    fi
    log_success "Conda is properly initialized"
    return 0
}

# Function to initialize conda in the current shell
initialize_conda() {
    log_info "Initializing conda for current shell..."

    # Ensure conda is in PATH
    if [[ ! ":$PATH:" == *":$HOME/miniconda/bin:"* ]]; then
        export PATH="$HOME/miniconda/bin:$PATH"
    fi

    # Initialize conda for current shell session
    if [ -f "$HOME/miniconda/etc/profile.d/conda.sh" ]; then
        log_info "Sourcing conda.sh..."
        . "$HOME/miniconda/etc/profile.d/conda.sh"
    else
        log_warning "conda.sh not found, trying alternative initialization..."
        eval "$(conda shell.bash hook)" || handle_error ${LINENO} "Failed to set up conda shell hooks"
    fi

    # Initialize conda for future shell sessions
    conda init bash || handle_error ${LINENO} "Failed to initialize conda for bash"

    # Reload shell configuration
    if [ -f ~/.bashrc ]; then
        log_info "Reloading shell configuration..."
        . ~/.bashrc
    fi

    # Verify initialization
    if ! conda info --envs &> /dev/null; then
        handle_error ${LINENO} "Conda initialization failed verification"
    fi
    log_success "Conda initialized successfully"
}

# Function to check and configure conda channels
configure_conda_channels() {
    log_info "Checking conda channels..."
    channels=$(conda config --show channels)
    
    # Check if conda-forge channel is already configured
    if [[ "$channels" != *"conda-forge"* ]]; then
        log_info "Adding conda-forge channel"
        conda config --add channels conda-forge
    fi

    # Check if bioconda channel is already configured
    if [[ "$channels" != *"bioconda"* ]]; then
        log_info "Adding bioconda channel"
        conda config --add channels bioconda
    fi

    # Check if defaults channel is already configured
    if [[ "$channels" != *"defaults"* ]]; then
        log_info "Adding defaults channel"
        conda config --add channels defaults
    fi

    # Check if nodefaults channel is already configured
    if [[ "$channels" != *"nodefaults"* ]]; then
        log_info "Adding nodefaults configuration"
        conda config --set channel_priority strict
        conda config --add channels nodefaults
    fi

    log_success "Conda channels configured successfully"
}

# Check prerequisites
log_info "Checking prerequisites..."

# Check for git installation
check_command "git" || handle_error ${LINENO} "Git is required but not installed. Please install it and try again"

# Repository setup
log_info "Setting up repository..."

# Clone the repository
if [ ! -d "dashboard-rhizosphere" ]; then
    log_info "Cloning repository..."
    # git clone https://github.com/DavidAlberto/dashboard-rhizosphere.git || \
        # handle_error ${LINENO} "Failed to clone the repository"
    # for testing
    git clone -b dev --single-branch https://github.com/DavidAlberto/dashboard-rhizosphere.git || \
        handle_error ${LINENO} "Failed to clone the repository"
fi
cd dashboard-rhizosphere || handle_error ${LINENO} "Failed to enter the project directory"

# Conda Installation and Setup
log_info "Setting up Conda..."

# Download and install Miniconda if not installed
if ! command -v conda &> /dev/null; then
    log_info "Installing Miniconda..."
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh || \
        handle_error ${LINENO} "Failed to download Miniconda"
    bash miniconda.sh -b -p $HOME/miniconda || \
        handle_error ${LINENO} "Failed to install Miniconda"
    
    # Add conda to PATH for current session
    export PATH="$HOME/miniconda/bin:$PATH"

    # Clean up installer
    rm miniconda.sh
    initialize_conda
fi

# Configure conda channels
configure_conda_channels

# Ensure conda is initialized
if ! check_conda_init; then
    initialize_conda
fi

# Function to create and configure environment
setup_env() {
    local env_dir=$1
    local env_name=$2
    local env_version=$3
    shift 3
    local packages=("$@")

    log_info "Setting up environment: $env_name"
    
    # Ensure conda is initialized before proceeding
    if ! check_conda_init; then
        initialize_conda
    fi

    # Clean up existing environment if present
    if [ -d "$env_dir" ]; then
        log_warning "Removing existing environment: $env_dir"
        conda env remove -p "$env_dir" -y
    fi

    # Create new environment
    log_info "Creating $env_name environment with version $env_version"
    conda create -p "$env_dir" "$env_name"="$env_version" -y || \
        handle_error ${LINENO} "Failed to create $env_name environment"

    # Activate environment using absolute path
    local full_env_path="$(pwd)/$env_dir"
    log_info "Activating environment: $full_env_path"
    CONDA_BASE=$(conda info --base)
    source "$CONDA_BASE/etc/profile.d/conda.sh"
    conda activate "$full_env_path" || handle_error ${LINENO} "Failed to activate conda environment"

    # Verify activation
    if [ "$CONDA_DEFAULT_ENV" != "$full_env_path" ]; then
        log_warning "Direct verification failed, trying alternative verification..."
        
        # Alternative verification using conda env list
        if ! conda env list | grep -q "*.*$full_env_path"; then
            handle_error ${LINENO} "Environment activation verification failed"
        fi
    fi

    # Install requested packages if any
    if [ ${#packages[@]} -ne 0 ]; then
        log_info "Installing conda packages: ${packages[*]}"
        conda install -c conda-forge "${packages[@]}" -y || \
            handle_error ${LINENO} "Failed to install conda packages"
    fi
}

# Set up Python environment
# log_info "Setting up Python environment..."
# setup_env ".venv" "python" "3.12"
# pip install -r requirements.txt --extra-index-url https://download.pytorch.org/whl/cu118 || \
#     handle_error ${LINENO} "Failed to install Python dependencies"
# conda deactivate || handle_error ${LINENO} "Failed to deactivate Miniconda"

# Set up R environment
log_info "Setting up R environment..."
setup_env ".renv" "r-base" "4.4.1" r-essentials r-tidyverse r-quarto
Rscript setup.R || handle_error ${LINENO} "Failed to install R packages"
conda deactivate || handle_error ${LINENO} "Failed to deactivate Miniconda"

# Install Quarto
log_info "Setting up Quarto..."
if ! command -v quarto &> /dev/null; then
    log_info "Downloading and installing Quarto..."
    wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.3.450/quarto-1.3.450-linux-amd64.deb || \
        handle_error ${LINENO} "Failed to download Quarto"
    sudo dpkg -i quarto-1.3.450-linux-amd64.deb || \
        handle_error ${LINENO} "Failed to install Quarto"
    sudo apt-get install -f -y || \
        handle_error ${LINENO} "Failed to install Quarto dependencies"
    rm quarto-1.3.450-linux-amd64.deb
    # Verify installation
    quarto --version || handle_error ${LINENO} "Failed to verify Quarto installation"
else
    log_info "Quarto is already installed"
fi

# Final Validation
log_info "Performing final validation..."

# Validate Python environment
# validate_env ".venv" || handle_error ${LINENO} "Python environment validation failed"

# Validate R environment
validate_env ".renv" || handle_error ${LINENO} "R environment validation failed"

# Final success message
log_success "Setup completed successfully!"
# log_info "You can now activate the Python environment with: conda activate $(pwd)/.venv"
log_info "Or the R environment with: conda activate $(pwd)/.renv"