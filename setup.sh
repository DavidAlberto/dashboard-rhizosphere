#!/usr/bin/env bash

set -euo pipefail

# Colors for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to handle errors
handle_error() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Function to display success messages
success() {
    echo -e "${GREEN}$1${NC}"
}

# Check prerequisites
command -v git >/dev/null 2>&1 || handle_error "Git is not installed. Please install it and try again."

# Clone the repository
if [ ! -d "dashboard-rhizosphere" ]; then
    git clone https://github.com/DavidAlberto/dashboard-rhizosphere.git || handle_error "Failed to clone the repository"
fi
cd dashboard-rhizosphere || handle_error "Failed to enter the project directory"

# Download and install Miniconda if not installed
if ! command -v conda &> /dev/null; then
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh || handle_error "Failed to download Miniconda"
    bash miniconda.sh -b -p $HOME/miniconda || handle_error "Failed to install Miniconda"
    source $HOME/miniconda/bin/activate || handle_error "Failed to activate Miniconda"
    rm miniconda.sh
fi

# Function to create and configure environment
setup_env() {
    local env_name=$1
    local python_version=$2
    shift 2
    local packages=("$@")

    conda create -p "$env_name" python="$python_version" -y || handle_error "Failed to create $env_name environment"
    conda activate "$env_name" || handle_error "Failed to activate $env_name environment"
    
    if [ ${#packages[@]} -ne 0 ]; then
        conda install -c conda-forge "${packages[@]}" -y || handle_error "Failed to install packages for $env_name"
    fi
}

# Set up Python environment
setup_env ".venv" "3.11"
pip install -r requirements.txt --extra-index-url https://download.pytorch.org/whl/cu118 || handle_error "Failed to install Python dependencies including PyTorch"

# Set up R environment
setup_env ".renv" "" r-base=4.4 r-essentials r-tidyverse quarto
Rscript -e "install.packages(c('ggplot2', 'dplyr', 'tidyr', 'purrr', 'stringr', 'forcats'), repos='https://cran.rstudio.com/')" || handle_error "Failed to install additional R packages"

# Verify pyproject.toml
if [ ! -f "pyproject.toml" ]; then
    cat << EOF > pyproject.toml
[build-system]
requires = ["setuptools", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "Dashboard Rhizosphere Project"
version = "0.1.0"
dependencies = [
    "numpy",
    "pandas",
    "scikit-learn",
    "tensorflow",
    "keras",
    "matplotlib",
    "seaborn",
    "xgboost",
    "lightgbm",
    "torch",
    "torchvision",
    "torchaudio"
]

[tool.pip]
extra-index-url = "https://download.pytorch.org/whl/cu118"
EOF
fi

success "Setup completed successfully!"