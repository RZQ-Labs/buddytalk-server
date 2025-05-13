#!/bin/bash

# =============================================================================
# Script Name: run_services.sh
# Author: Hendro Wibowo <hendrothemail@gmail.com>
# Description: Script to manage docker services.
# =============================================================================

# Exit the script on any error
set -e

appname="buddytalk"

# Check if the script is running in the root directory
if [ ! -f .rootdir ]; then
  echo "Error: This script must be run from the root directory."
  exit 1
fi

echo "Managing $appname backend services..."

# Check if livekit.yaml exists, if not generate it from example file
if [ ! -f services/livekit/livekit.yaml ]; then
  echo "Generating LiveKit config from example..."

  # Check if env file exists
  if [ ! -f env/.env ]; then
    echo "Error: env/.env file not found. Please create it first."
    exit 1
  fi

  # Get LiveKit credentials from env file
  LK_API_KEY=$(grep LK_API_KEY env/.env | cut -d '=' -f2)
  LK_API_SECRET=$(grep LK_API_SECRET env/.env | cut -d '=' -f2)

  if [ -z "$LK_API_KEY" ] || [ -z "$LK_API_SECRET" ]; then
    echo "Error: LiveKit API credentials not found in env/.env"
    exit 1
  fi

  # Create livekit.yaml from example and replace credentials
  cp services/livekit/livekit.yaml.example services/livekit/livekit.yaml
  sed -i "s/your-api-key/$LK_API_KEY/" services/livekit/livekit.yaml
  sed -i "s/your-api-secret/$LK_API_SECRET/" services/livekit/livekit.yaml

  echo "LiveKit config generated successfully"
fi


# Parse command line arguments
while getopts "a:e:s:h" opt; do
  case $opt in
    a) ACTION=$OPTARG ;;
    e) ENV_NAME=$OPTARG ;;
    s) SERVICE_NAME=$OPTARG ;;
    h)
      echo "Usage: $0 [-a action] [-e environment] [-s service_name]"
      echo "  -a  Action to perform (start, stop, restart, restart-service, show, logs, logs-service)"
      echo "  -e  Environment name (default: development)"
      echo "  -s  Service name (required for restart-service and logs-service actions)"
      exit 0
      ;;
    *) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
  esac
done

echo "Selected action: $ACTION"

# Prompt the user to enter the action if not provided as an argument
if [ -z "$ACTION" ]; then
  echo "Enter the action (start, stop, restart, restart-service, show, logs, logs-service) [default: start]:"
  read -r ACTION
fi

# If no action is provided, use 'start' as default
ACTION=${ACTION:-start}

# Prompt the user to enter the environment name if not provided as an argument
if [ -z "$ENV_NAME" ]; then
  echo "Enter the environment (default: development):"
  read -r ENV_NAME
fi

# If no environment name is provided, use 'development' as default
ENV_NAME=${ENV_NAME:-development}

echo "Selected environment: $ENV_NAME"

# If action is restart-service or logs-service, prompt for the service name if not provided as an argument
if { [ "$ACTION" == "restart-service" ] || [ "$ACTION" == "logs-service" ]; } && [ -z "$SERVICE_NAME" ]; then
  echo "Enter the service name:"
  read -r SERVICE_NAME
fi

# Set the project name based on the environment name
PROJECT_NAME="${appname:l}-$ENV_NAME"

# Set the docker compose file based on the environment name
COMPOSE_FILES="./docker/run/run-$ENV_NAME-compose.yaml"

case "$ACTION" in
  start)
    echo "Executing docker compose -f "$COMPOSE_FILES" up -d"
    # shellcheck disable=SC2086
    docker compose -f "$COMPOSE_FILES" up -V -d

    echo "Executing docker compose -f "$COMPOSE_FILES" logs -f"
    # shellcheck disable=SC2086
    docker compose -f "$COMPOSE_FILES" logs -f
    ;;
  stop)
    echo "Executing docker compose --project-name \"$PROJECT_NAME\" down"
    docker compose -f "$COMPOSE_FILES" down
    ;;
  full-stop)
    echo "Executing docker compose --project-name \"$PROJECT_NAME\" down along with volumes removal"
    docker compose -f "$COMPOSE_FILES" down --volumes
    ;;
  restart)
    echo "Executing docker compose --project-name \"$PROJECT_NAME\" down"
    docker compose -f "$COMPOSE_FILES" down

    echo "Executing docker compose --project-name \"$PROJECT_NAME\" -f \"$COMPOSE_FILES\" up -d --build"
    # shellcheck disable=SC2086
    docker compose -f "$COMPOSE_FILES" -f "$COMPOSE_FILES" up -V -d

    echo "Executing docker compose --project-name \"$PROJECT_NAME\" logs -f"
    docker compose -f "$COMPOSE_FILES" logs -f
    ;;
  full-restart)
      echo "Executing docker compose --project-name \"$PROJECT_NAME\" down along with volumes removal"
      docker compose -f "$COMPOSE_FILES" down --volumes

      echo "Executing docker compose --project-name \"$PROJECT_NAME\" -f \"$COMPOSE_FILES\" up -d --build --no-cache"

      # This command runs docker compose with the following parameters:
      # -f "$COMPOSE_FILES": Sets the project name from the variable defined earlier
      # -f "$COMPOSE_FILES": Specifies the compose file to use from the variable defined earlier
      # up: Creates and starts the containers defined in the compose file
      # -V: Recreates anonymous volumes instead of retrieving data from previous containers
      # -d: Runs containers in detached mode (in the background)
      docker compose -f "$COMPOSE_FILES" -f "$COMPOSE_FILES" up -V -d

      echo "Executing docker compose --project-name \"$PROJECT_NAME\" logs -f"
      docker compose -f "$COMPOSE_FILES" logs -f
      ;;
  restart-service)
    if [ -z "$SERVICE_NAME" ]; then
      echo "Error: Service name is required for action 'restart-service'."
      exit 1
    fi
    echo "Executing docker compose --project-name \"$PROJECT_NAME\" restart $SERVICE_NAME"

    # shellcheck disable=SC2086
    docker compose -f "$COMPOSE_FILES" restart $SERVICE_NAME

    echo "Executing docker compose --project-name \"$PROJECT_NAME\" logs -f"
    docker compose -f "$COMPOSE_FILES" logs -f
    ;;
  show)
    echo "Executing docker compose --project-name \"$PROJECT_NAME\" ps"
    docker compose -f "$COMPOSE_FILES" ps
    ;;
  logs)
    echo "Executing docker compose --project-name \"$PROJECT_NAME\" logs -f"
    docker compose -f "$COMPOSE_FILES" logs -f
    ;;
  logs-service)
    if [ -z "$SERVICE_NAME" ]; then
      echo "Error: Service name is required for action 'logs-service'."
      exit 1
    fi
    echo "Executing docker compose --project-name \"$PROJECT_NAME\" logs -f \"$SERVICE_NAME\""
    docker compose -f "$COMPOSE_FILES" logs -f "$SERVICE_NAME"
    ;;
  *)
    echo "Error: Unknown action '$ACTION'. Valid options are: start, stop, restart, restart-service, show, logs, logs-service."
    exit 1
    ;;
esac

echo "$appname backend services action '$ACTION' completed."
