# Dashboard Rhizosphere Project Setup Guide

This README provides instructions for setting up the development environment for the Dashboard Rhizosphere Project, including Conda installation, creation of R environment and installation of packages.

## Table of Contents
- [Dashboard Rhizosphere Project Setup Guide](#dashboard-rhizosphere-project-setup-guide)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Quick Setup](#quick-setup)
  - [Manual Setup](#manual-setup)
    - [Clone the Repository](#clone-the-repository)
    - [Conda Installation](#conda-installation)
    - [R Environment Setup](#r-environment-setup)
  - [Troubleshooting](#troubleshooting)

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

### R Environment Setup

```bash
conda env create -f "$ENV_YAML" --force -p "$CONDA_ENV_PATH"
conda env create -f environment.yml --prefix .renv
conda activate .renv
Rscript setup.R
conda deactivate
```

## Troubleshooting

If you encounter any issues during installation, please open an [Issue](https://github.com/DavidAlberto/dashboard-rhizosphere/issues) on GitHub.