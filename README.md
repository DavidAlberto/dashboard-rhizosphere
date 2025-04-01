# Dashboard Rhizosphere Project

## Table of Contents
- [Dashboard Rhizosphere Project](#dashboard-rhizosphere-project)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Get Started](#get-started)
  - [Prerequisites](#prerequisites)
    - [Git installation](#git-installation)
    - [Conda installation](#conda-installation)
  - [Quick Setup](#quick-setup)
  - [Manual Setup](#manual-setup)
    - [1. Clone the Repository](#1-clone-the-repository)
    - [2. Create a Conda Environment](#2-create-a-conda-environment)
    - [3. R Environment Setup](#3-r-environment-setup)
    - [4. Run the Application](#4-run-the-application)
  - [Troubleshooting](#troubleshooting)

## Overview

The Dashboard Rhizosphere Project is a web-based application built using R and Shiny, designed to facilitate the analysis and visualization of rhizosphere data. The project aims to provide researchers with an interactive platform to explore various aspects of rhizosphere dynamics, including microbial communities, plant interactions, and environmental factors. 

## Get Started

Instructions for setting up the development environment for the Dashboard Rhizosphere Project.

## Prerequisites

- Git
- Conda (Anaconda or Miniconda)

### Git installation

If you don't have Git installed, you can install it using the following commands:

```bash
# Verify if git is installed
git --version

# If git is not installed, install it
sudo apt update
sudo apt install git
```

### Conda installation

If you don't have Conda installed, you can install it using the following commands:

```bash
# Verfiy if conda is installed
conda --version

# If conda is not installed, install it
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda
source $HOME/miniconda/bin/activate
```

## Quick Setup

For automatic setup, run:

```bash
curl -sSL https://raw.githubusercontent.com/DavidAlberto/dashboard-rhizosphere/refs/heads/dev/setup.sh | bash
```

## Manual Setup

For manual setup, follow these steps:

### 1. Clone the Repository

Clone and navigate to the repository. The `dev` branch is the development branch, and it is recommended to use this branch for the moment.

```bash
git clone -b dev --single-branch https://github.com/DavidAlberto/dashboard-rhizosphere.git
cd dashboard-rhizosphere
```

### 2. Create a Conda Environment

Next, create a Conda environment. The `environment.yml` file contains the necessary dependencies for the project.

If you want to create the environment in a specific directory, you can use the `--prefix` option. This is useful for keeping the environment isolated from your base Conda environment.

```bash
conda env create -f environment.yml --prefix .rhizosphere
conda activate .rhizosphere
```

Else, you can create the environment in the default Conda environment directory

```bash
conda env create -f environment.yml
conda activate rhizosphere
```

### 3. R Environment Setup

After activating the Conda environment, you need to install the R packages required for the project. The `install.R` script will take care of this.

```bash
# Install R packages
Rscript setup.R
```

This script will install the necessary R packages and dependencies for the project. It may take some time to complete, depending on your internet connection and system performance.

### 4. Run the Application

Once the setup is complete, you can run the application using the following command in the R console:

```R
# Run the application
library("shiny")
runApp("shiny/.")
```

## Troubleshooting

If you encounter any issues during installation, please open an [Issue](https://github.com/DavidAlberto/dashboard-rhizosphere/issues) on GitHub.