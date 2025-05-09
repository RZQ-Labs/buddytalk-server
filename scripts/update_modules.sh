#!/bin/bash

# =============================================================================
# Script Name: update_submodules.sh
# Author: Hendro Wibowo <hendrothemail@gmail.com>
# Description: Script to update Git submodules and allow the user to specify the branch.
# =============================================================================

# Exit the script on any error
set -e

# Check if the script is running in the root directory
if [ ! -f .rootdir ]; then
  echo "Error: This script must be run from the root directory."
  exit 1
fi

echo "Updating Git submodules with user-specified branch..."

# Prompt the user to enter the branch name
echo "Enter the branch name to update submodules (default: development):"
read -r BRANCH_NAME

# If no branch name is provided, use 'development' as default
BRANCH_NAME=${BRANCH_NAME:-development}

echo "Selected branch: $BRANCH_NAME"

# Initialize and update all submodules
echo "Initializing and updating submodules..."
git submodule update --init --recursive

# Checkout the specified branch for each submodule and pull the latest changes
echo "Checking out branch '$BRANCH_NAME' for each submodule and pulling the latest changes..."
echo "=================================================================================================="

git submodule foreach "
  git checkout $BRANCH_NAME || {
    echo 'Branch $BRANCH_NAME does not exist in submodule \$(basename \$PWD)';
    exit 1;
  }
  git pull origin $BRANCH_NAME || {
    echo 'Failed to pull latest changes for submodule \$(basename \$PWD)';
    exit 1;
  }
"

echo "=================================================================================================="
echo "Submodule update complete!"
