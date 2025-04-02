#!/bin/bash
set -e  # Exit if any command fails

# ─── FUNCTION TO PRINT ERRORS ────────────────────────────────────────────────
error_exit() {
    echo "Error: $1"
    exit 1
}

# ─── CHECK IF CONDA IS AVAILABLE ─────────────────────────────────────────────
if ! command -v conda &> /dev/null; then
    error_exit "Conda is not installed or not available in the current session."
fi

# ─── PROMPT USER FOR ENVIRONMENT TYPE ────────────────────────────────────────
echo "Do you want to configure a local or global Conda environment?"
echo "1) Local (environment inside the project folder, e.g., .rhizosphere)"
echo "2) Global (standard Conda environment, e.g., rhizosphere)"
read -p "Enter choice [1/2]: " ENV_TYPE

if [[ "$ENV_TYPE" == "1" ]]; then
    ENV_PATH="$(pwd)/.rhizosphere"
elif [[ "$ENV_TYPE" == "2" ]]; then
    read -p "Enter the name of the global Conda environment: " ENV_NAME
    ENV_PATH=$(conda info --envs | awk -v name="$ENV_NAME" '$1 == name {print $2}')
    if [[ -z "$ENV_PATH" ]]; then
        error_exit "The specified Conda environment '$ENV_NAME' was not found."
    fi
else
    error_exit "Invalid choice. Please enter 1 for local or 2 for global."
fi

# ─── ENSURE THE SELECTED ENVIRONMENT EXISTS ──────────────────────────────────
if [ ! -d "$ENV_PATH" ]; then
    error_exit "The Conda environment at '$ENV_PATH' does not exist."
fi

echo "Configuring environment variables for Conda environment: $ENV_PATH"

# ─── ENSURE ACTIVATION & DEACTIVATION DIRECTORIES EXIST ──────────────────────
mkdir -p "$ENV_PATH/etc/conda/activate.d"
mkdir -p "$ENV_PATH/etc/conda/deactivate.d"

# ─── CREATE ACTIVATION SCRIPT ────────────────────────────────────────────────
cat << EOF > "$ENV_PATH/etc/conda/activate.d/env_vars.sh"
#!/bin/sh
export PKG_CONFIG_PATH="$ENV_PATH/lib/pkgconfig"
export LD_LIBRARY_PATH="$ENV_PATH/lib:\$LD_LIBRARY_PATH"
EOF
chmod +x "$ENV_PATH/etc/conda/activate.d/env_vars.sh"

# ─── CREATE DEACTIVATION SCRIPT ──────────────────────────────────────────────
cat << EOF > "$ENV_PATH/etc/conda/deactivate.d/env_vars.sh"
#!/bin/sh
unset PKG_CONFIG_PATH
export LD_LIBRARY_PATH=\$(echo "\$LD_LIBRARY_PATH" | sed -e "s|$ENV_PATH/lib:||")
EOF
chmod +x "$ENV_PATH/etc/conda/deactivate.d/env_vars.sh"

echo "Environment variables configured successfully! 🎉"
echo "Restart your terminal or reactivate your Conda environment for changes to take effect."