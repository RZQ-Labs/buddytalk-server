#!/bin/bash

# =============================================================================
# Script Name: run_worker.sh
# Author: Hendro Wibowo <hendrothemail@gmail.com>
# Description: Script to run worker services.
# =============================================================================

# Exit the script on any error
set -e

appname="buddytalk"

# Check if the script is running in the root directory
if [ ! -f .rootdir ]; then
  echo "Error: This script must be run from the root directory."
  exit 1
fi

echo "Managing $appname livekit worker..."

# Load environment variables from .env file
if [ -f "env/.env" ]; then
  echo "Loading environment variables from env/.env"
  source env/.env
else
  echo "Error: .env file not found at env/.env"
  exit 1
fi

# Override the hardcoded values with the ones from .env

export LIVEKIT_URL="${LK_URL}"
export LIVEKIT_API_KEY="${LK_API_KEY}"
export LIVEKIT_API_SECRET="${LK_API_SECRET}"

cd services/worker
cargo watch -x run
