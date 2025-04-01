#!/usr/bin/env bash
# =============================================================================
# Setup Script for Dashboard Rhizosphere Project
# This script sets up the complete development environment:
# - Clone the repository
# - Install Miniconda (if needed)
# - Create the conda environment from a YAML file (environment.yml)
# - Restore the R environment using renv (using renv.lock and renv folder)
# =============================================================================

set -euo pipefail

# ─── COLORS AND LOGGING FUNCTIONS ──────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_error()   { echo -e "${RED}[ERROR] $1${NC}" >&2; }
log_success() { echo -e "${GREEN}[SUCCESS] $1${NC}"; }
log_info()    { echo -e "${BLUE}[INFO] $1${NC}"; }
log_warning() { echo -e "${YELLOW}[WARNING] $1${NC}"; }

handle_error() {
    log_error "Error on line $1: $2"
    exit 1
}
trap 'handle_error ${LINENO} "$BASH_COMMAND"' ERR

# ─── VERIFICATION FUNCTIONS ─────────────────────────────────────────────────────
check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "Required command '$1' not found. Please install it and try again."
        exit 1
    fi
}

# ─── REPOSITORY SETUP ───────────────────────────────────────────────────────────
log_info "Verifying Git installation..."
check_command git

if [ -d ".git" ]; then
    log_info "Already inside a Git repository. Skipping clone step."
else
    log_info "Cloning repository..."
    # git clone https://github.com/DavidAlberto/dashboard-rhizosphere.git || \
        # handle_error ${LINENO} "Failed to clone the repository"
    # For testing purposes, clone the 'dev' branch only
    git clone -b dev --single-branch https://github.com/DavidAlberto/dashboard-rhizosphere.git || \
        handle_error ${LINENO} "Failed to clone the repository"
    cd dashboard-rhizosphere || handle_error ${LINENO} "Failed to enter the project directory"
fi

# ─── MINICONDA INSTALLATION ─────────────────────────────────────────────────────
if ! command -v conda &> /dev/null; then
    log_info "Miniconda not found. Installing Miniconda..."
    check_command wget
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh || \
        handle_error ${LINENO} "Error downloading Miniconda"
    bash miniconda.sh -b -p "$HOME/miniconda" || \
        handle_error ${LINENO} "Error installing Miniconda"
    rm miniconda.sh
    export PATH="$HOME/miniconda/bin:$PATH"
fi

# Initialize conda for the current session
CONDA_BASE=$(conda info --base 2>/dev/null)
if [ -n "$CONDA_BASE" ] && [ -f "$CONDA_BASE/etc/profile.d/conda.sh" ]; then
    source "$CONDA_BASE/etc/profile.d/conda.sh"
else
    eval "$(conda shell.bash hook)" || handle_error ${LINENO} "Error initializing conda"
fi

# ─── CREATE CONDA ENVIRONMENT FROM YAML IN PROJECT FOLDER ───────────────────────
# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# ENV_YML="$SCRIPT_DIR/environment.yml"
# CONDA_ENV_PATH="$SCRIPT_DIR/rhizosphere"  # Keep the rhizosphere environment within your project folder

# if [ ! -f "$ENV_YML" ]; then
#     handle_error ${LINENO} "File '$ENV_YML' not found. Please create it with the desired configuration."
# fi

# log_info "Creating (or recreating) the conda environment from '$ENV_YML'..."

# # Remove existing environment (only if it exists locally)
# if [ -d "$CONDA_ENV_PATH" ]; then
#     conda env remove -p "$CONDA_ENV_PATH" -y || true
# fi

# # Create new environment
# conda env create -f "$ENV_YML" -p "$CONDA_ENV_PATH" || \
#     handle_error ${LINENO} "Error creating the conda environment"

# # Activate conda environment
# log_info "Activating conda environment: $CONDA_ENV_PATH"
# conda activate "$CONDA_ENV_PATH" || handle_error ${LINENO} "Error activating the conda environment"

# ─── CREATE GLOBAL CONDA ENVIRONMENT FROM YAML ─────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_YML="$SCRIPT_DIR/environment.yml"
ENV_NAME="rhizosphere"  # Name of the conda environment

if [ ! -f "$ENV_YML" ]; then
    handle_error ${LINENO} "File '$ENV_YML' not found. Please create it with the desired configuration."
fi

log_info "Creating (or recreating) the global conda environment '$ENV_NAME' from '$ENV_YML'..."

# Remove existing environment (only if it exists globally)
if conda info --envs | grep -q "^$ENV_NAME\s"; then
    conda env remove -n "$ENV_NAME" -y || true
fi

# Create new environment
conda env create -f "$ENV_YML" -n "$ENV_NAME" || \
    handle_error ${LINENO} "Error creating the conda environment"

# Activate conda environment
log_info "Activating conda environment: $ENV_NAME"
conda activate "$ENV_NAME" || handle_error ${LINENO} "Error activating the conda environment"


# ─── RUN SETUP.R TO RESTORE R ENVIRONMENT ───────────────────────────────────────
SETUP_R_SCRIPT="setup.R"

if [ -f "$SETUP_R_SCRIPT" ]; then
    log_info "Running R setup script: $SETUP_R_SCRIPT"
    Rscript "$SETUP_R_SCRIPT" || handle_error ${LINENO} "Error running $SETUP_R_SCRIPT"
else
    log_warning "No '$SETUP_R_SCRIPT' found. Skipping R environment setup."
fi

# ─── FINAL MESSAGE ─────────────────────────────────────────────────────────────
log_success "Setup completed successfully!"
log_info "To activate the conda environment, run: conda activate $CONDA_ENV_PATH"