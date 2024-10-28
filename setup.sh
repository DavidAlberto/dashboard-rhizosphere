#!/usr/bin/env bash

# =============================================================================
# Setup Script for Dashboard Rhizosphere Project
# This script sets up the complete development environment including:
# - Python environment with ML libraries
# - R environment with tidyverse
# - Quarto for documentation
# - Project dependencies and configurations
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
    # Initialize conda for current shell session
    eval "$(conda shell.bash hook)" || \
        handle_error ${LINENO} "Failed to set up conda shell hooks"
    # Initialize conda for future shell sessions
    conda init bash || \
        handle_error ${LINENO} "Failed to initialize conda for bash"
    # Source bashrc to apply changes in current session
    source ~/.bashrc || \
        handle_error ${LINENO} "Failed to source ~/.bashrc"
    log_success "Conda initialized successfully"
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
    git clone https://github.com/DavidAlberto/dashboard-rhizosphere.git || \
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

# Ensure conda is initialized
if ! check_conda_init; then
    initialize_conda
fi

# Function to create and configure environment
setup_env() {
    local env_name=$1
    local python_version=$2
    shift 2
    local packages=("$@")
    log_info "Setting up environment: $env_name"
    # Clean up existing environment if present
    if [ -d "$env_name" ]; then
        log_warning "Removing existing environment: $env_name"
        conda env remove -p "$env_name" -y
    fi
    # Create new environment
    if [ -n "$python_version" ]; then
        log_info "Creating Python environment with version $python_version"
        conda create -p "$env_name" python="$python_version" -y || \
            handle_error ${LINENO} "Failed to create Python environment"
    else
        log_info "Creating environment without Python"
        conda create -p "$env_name" -y || \
            handle_error ${LINENO} "Failed to create environment"
    fi
    # Activate environment using absolute path
    local full_env_path="$(pwd)/$env_name"
    log_info "Activating environment: $full_env_path"
    conda activate "$full_env_path" || \
        handle_error ${LINENO} "Failed to activate environment"
    # Install requested packages if any
    if [ ${#packages[@]} -ne 0 ]; then
        log_info "Installing conda packages: ${packages[*]}"
        conda install -c conda-forge "${packages[@]}" -y || \
            handle_error ${LINENO} "Failed to install conda packages"
    fi
}

# Set up Python environment
log_info "Setting up Python environment..."
setup_env ".venv" "3.12"
pip install -r requirements.txt --extra-index-url https://download.pytorch.org/whl/cu118 || \
    handle_error ${LINENO} "Failed to install Python dependencies"
conda deactivate || handle_error ${LINENO} "Failed to deactivate Miniconda"

# Set up R environment
log_info "Setting up R environment..."
setup_env ".renv" "" conda-forge r-base=4.4.3 r-essentials r-tidyverse quarto
log_info "Installing R packages..."
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

# Project Configuration
log_info "Setting up project configuration..."

# Create or verify pyproject.toml
if [ ! -f "pyproject.toml" ]; then
    log_info "Creating pyproject.toml..."
    cat << EOF > pyproject.toml
[build-system]
requires = ["setuptools", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "Dashboard Rhizosphere Project"
version = "0.1.0"
description = "A comprehensive dashboard for rhizosphere data analysis"
requires-python = ">=3.12"
dependencies = [
    "numpy>=1.24.0",
    "pandas>=2.0.0",
    "dash>=2.10.0",
    "scikit-learn>=1.3.0",
    "tensorflow>=2.13.0",
    "keras>=2.13.0",
    "matplotlib>=3.7.0",
    "seaborn>=0.12.0",
    "xgboost>=2.0.0",
    "lightgbm>=4.0.0",
    "torch>=2.0.0",
    "torchvision>=0.15.0",
    "torchaudio>=2.0.0"
]

[tool.pip]
extra-index-url = "https://download.pytorch.org/whl/cu118"

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "black>=23.0.0",
    "isort>=5.0.0",
    "flake8>=6.0.0"
]
EOF
fi

# Final Validation
log_info "Performing final validation..."

# Validate Python environment
validate_env ".venv" || handle_error ${LINENO} "Python environment validation failed"

# Validate R environment
validate_env ".renv" || handle_error ${LINENO} "R environment validation failed"

# Final success message
log_success "Setup completed successfully!"
log_info "You can now activate the Python environment with: conda activate $(pwd)/.venv"
log_info "Or the R environment with: conda activate $(pwd)/.renv"