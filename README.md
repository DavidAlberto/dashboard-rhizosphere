# Dashboard Rhizosphere Project Setup Guide

This README provides instructions for setting up the development environment for the Dashboard Rhizosphere Project, including Conda installation, creation of virtual environments, and installation of packages for R and Python.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Quick Setup](#quick-setup)
3. [Manual Setup](#manual-setup)
   - [Clone the Repository](#clone-the-repository)
   - [Conda Installation](#conda-installation)
   - [Python Environment Setup](#python-environment-setup)
   - [R Environment Setup](#r-environment-setup)
   - [Quarto Installation](#quarto-installation)
   - [Python Project Configuration](#python-project-configuration)
4. [Using the Environments](#using-the-environments)
5. [Troubleshooting](#troubleshooting)

## Prerequisites

- Git
- Internet connection
- Administrator permissions (for Conda installation)

## Quick Setup

For automatic setup, run:

```bash
curl -sSL https://raw.githubusercontent.com/DavidAlberto/dashboard-rhizosphere/main/setup.sh | bash
```

Or if you've already cloned the repository:

```bash
./setup.sh
```

## Manual Setup

### Clone the Repository

```bash
git clone https://github.com/DavidAlberto/dashboard-rhizosphere.git
cd dashboard-rhizosphere
```

### Conda Installation

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda
source $HOME/miniconda/bin/activate
```

### Python Environment Setup

```bash
conda create -p .venv python=3.12 -y
conda activate .venv
pip install -r requirements.txt
```

### R Environment Setup

```bash
conda create -p .renv r-base=4.3.3 -y
conda activate .renv
conda install -c conda-forge r-essentials r-tidyverse quarto -y
Rscript setup.R
```

### Quarto Installation

For Debian/Ubuntu systems, you can install Quarto using the binary package:

```bash
wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.3.450/quarto-1.3.450-linux-amd64.deb
sudo dpkg -i quarto-1.3.450-linux-amd64.deb
sudo apt-get install -f
```

For other systems or for the latest version, please refer to the [official Quarto documentation](https://quarto.org/docs/get-started/).

### Python Project Configuration

The `pyproject.toml` file is already included in the repository. If you need to modify it:

```bash
nano pyproject.toml
```

## Using the Environments

- To activate the Python environment: `conda activate .venv`
- To activate the R environment: `conda activate .renv`

## Troubleshooting

If you encounter any issues during installation, please open an [Issue](https://github.com/DavidAlberto/dashboard-rhizosphere/issues) on GitHub.