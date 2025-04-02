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
    log_info "Conda not found. Installing Miniconda..."
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

# ─── CONDA ENVIRONMENT SETUP ───────────────────────────────────────────────────
echo "Select the type of Conda environment to create:"
echo "1) Local environment (in project folder)"
echo "2) Global environment (in Conda's envs directory)"
read -p "Enter your choice [1/2]: " ENV_CHOICE

case "$ENV_CHOICE" in
    1)
        # Config for local environment
        CONDA_ENV_PATH="$SCRIPT_DIR/.rhizosphere"
        log_info "Creating local conda environment at '$CONDA_ENV_PATH' from '$ENV_YML'..."
        
        # Delete existing environment if it exists
        if [ -d "$CONDA_ENV_PATH" ]; then
            conda env remove -p "$CONDA_ENV_PATH" -y || true
        fi
        
        # Create new environment
        conda env create -f "$ENV_YML" --prefix "$CONDA_ENV_PATH" || \
            handle_error ${LINENO} "Error creating the conda environment"
        
        # Configure activation/deactivation scripts
        mkdir -p "$CONDA_ENV_PATH/etc/conda/activate.d"
        mkdir -p "$CONDA_ENV_PATH/etc/conda/deactivate.d"

        cat << EOF > "$CONDA_ENV_PATH/etc/conda/activate.d/env_vars.sh"
#!/bin/sh
export PKG_CONFIG_PATH="$CONDA_ENV_PATH/lib/pkgconfig"
export LD_LIBRARY_PATH="$CONDA_ENV_PATH/lib:\$LD_LIBRARY_PATH"
export PATH="$CONDA_ENV_PATH/bin:\$PATH"
EOF
        chmod +x "$CONDA_ENV_PATH/etc/conda/activate.d/env_vars.sh"

        cat << EOF > "$CONDA_ENV_PATH/etc/conda/deactivate.d/env_vars.sh"
#!/bin/sh
unset PKG_CONFIG_PATH
export LD_LIBRARY_PATH=\$(echo "\$LD_LIBRARY_PATH" | sed -e "s|$CONDA_ENV_PATH/lib:||")
export PATH=\$(echo "\$PATH" | sed -e "s|$CONDA_ENV_PATH/bin:||")
EOF
        chmod +x "$CONDA_ENV_PATH/etc/conda/deactivate.d/env_vars.sh"

        # Activate the local environment
        log_info "Activating conda environment: $CONDA_ENV_PATH"
        conda activate "$CONDA_ENV_PATH" || handle_error ${LINENO} "Error activating the conda environment"
        
        log_success "Local environment created successfully at $CONDA_ENV_PATH"
        ;;
    2)
        # Config for global environment
        ENV_NAME="rhizosphere"
        log_info "Creating global conda environment '$ENV_NAME' from '$ENV_YML'..."
        
        # Delete existing environment if it exists
        if conda info --envs | grep -q "^$ENV_NAME\s"; then
            conda env remove -n "$ENV_NAME" -y || true
        fi
        
        # Create new environment
        conda env create -f "$ENV_YML" -n "$ENV_NAME" || \
            handle_error ${LINENO} "Error creating the conda environment"
        
        # Configure activation/deactivation scripts
        mkdir -p "$CONDA_PREFIX/etc/conda/activate.d"
        mkdir -p "$CONDA_PREFIX/etc/conda/deactivate.d"

        cat << EOF > "$CONDA_PREFIX/etc/conda/activate.d/env_vars.sh"
#!/bin/sh
export PKG_CONFIG_PATH="$CONDA_PREFIX/lib/pkgconfig"
export LD_LIBRARY_PATH="$CONDA_PREFIX/lib:\$LD_LIBRARY_PATH"
EOF
        chmod +x "$CONDA_PREFIX/etc/conda/activate.d/env_vars.sh"

        cat << EOF > "$CONDA_PREFIX/etc/conda/deactivate.d/env_vars.sh"
#!/bin/sh
unset PKG_CONFIG_PATH
export LD_LIBRARY_PATH=\$(echo "\$LD_LIBRARY_PATH" | sed -e "s|$CONDA_PREFIX/lib:||")
EOF
        chmod +x "$CONDA_PREFIX/etc/conda/deactivate.d/env_vars.sh"

        # Activate the global environment
        log_info "Activating conda environment: $ENV_NAME"
        conda activate "$ENV_NAME" || handle_error ${LINENO} "Error activating the conda environment"

        log_success "Global environment '$ENV_NAME' created successfully"
        ;;
    *)
        handle_error ${LINENO} "Invalid choice. Please enter 1 for local or 2 for global."
        ;;
esac

# Mensaje final con instrucciones
log_info "Environment setup completed."
if [[ "$ENV_CHOICE" == "1" ]]; then
    log_info "To activate this environment, run: conda activate $CONDA_ENV_PATH"
else
    log_info "To activate this environment, run: conda activate $ENV_NAME"
fi

# ─── RUN SETUP.R TO RESTORE R ENVIRONMENT ───────────────────────────────────────
SETUP_R_SCRIPT="$SCRIPT_DIR/setup.R"

if [ -f "$SETUP_R_SCRIPT" ]; then
    log_info "Running R setup script: $SETUP_R_SCRIPT"
    
    # Verify if Rscript is available
    if ! command -v Rscript &> /dev/null; then
        log_warning "Rscript not found. Please install R to run the setup script."
    else
        # Run the R script to restore the R environment
        log_info "Running R setup script: $SETUP_R_SCRIPT"
        Rscript "$SETUP_R_SCRIPT" || handle_error ${LINENO} "Error running $SETUP_R_SCRIPT"
    fi
else
    log_warning "No '$SETUP_R_SCRIPT' found. Skipping R environment setup."
fi

# ─── FINAL MESSAGE ─────────────────────────────────────────────────────────────
log_success "Setup completed successfully!"

# Print instructions for activating the environment
if [[ "$ENV_CHOICE" == "1" ]]; then
    log_info "To activate this local environment, run:"
    log_info "  conda activate $CONDA_ENV_PATH"
else
    log_info "To activate this global environment, run:"
    log_info "  conda activate $ENV_NAME"
fi

log_info "To deactivate the environment, run: conda deactivate"