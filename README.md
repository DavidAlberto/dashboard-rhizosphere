# Dashboard Rhizosphere Project Setup Guide

This README provides instructions for setting up the development environment for the Dashboard Rhizosphere Project, including Conda installation, creation of R environment and installation of packages.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Quick Setup](#quick-setup)
3. [Manual Setup](#manual-setup)
   - [Clone the Repository](#clone-the-repository)
   - [Conda Installation](#conda-installation)
   - [Quarto Installation](#quarto-installation)
   - [R Environment Setup](#r-environment-setup)
4. [Troubleshooting](#troubleshooting)

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

### Quarto Installation

For Debian/Ubuntu systems, you can install Quarto using the binary package:

```bash
wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.3.450/quarto-1.3.450-linux-amd64.deb
sudo dpkg -i quarto-1.3.450-linux-amd64.deb
sudo apt-get install -f
```

### R Environment Setup

```bash
conda env create -f environment.yml --prefix .renv
conda activate .renv
Rscript setup.R
conda deactivate
```

For other systems or for the latest version, please refer to the [official Quarto documentation](https://quarto.org/docs/get-started/).

## Troubleshooting

If you encounter any issues during installation, please open an [Issue](https://github.com/DavidAlberto/dashboard-rhizosphere/issues) on GitHub.