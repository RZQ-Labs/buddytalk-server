# BuddyTalk Server

BuddyTalk is a modular backend system designed for real-time audio processing, communication, and data management, leveraging microservices and containerized infrastructure. The project is orchestrated using Docker Compose and includes several core services:

## Project Structure

- **services/**
  - **worker/**: Rust-based service that connects to a LiveKit room, subscribes to remote audio tracks, and logs received audio frames for real-time processing.
  - **livekit/**: LiveKit server for real-time audio/video communication.
  - **chromadb/**: Chroma database for vector storage and retrieval.
  - **redis/**: Redis server for caching and message brokering.
  - **adminer/**: Adminer database management tool.
- **docker/**: Docker Compose and service configuration files.
- **scripts/**: Utility scripts for managing, generating, and updating services and submodules.
- **env/**: Environment variable files.

## Prerequisites

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/)
- (For development) [Rust](https://www.rust-lang.org/tools/install) (for the worker service)

## Setup & Usage

### 1. Clone the Repository

```sh
git clone <repo-url>
cd buddytalk-server
```

### 2. Update Submodules

If your project uses git submodules, update them with:

```sh
./scripts/update_modules.sh
```

### 3. Configure Environment

Copy or create your environment variables in `env/.env` as needed for your services (e.g., LiveKit API keys).

### 4. Generate Docker Compose File

You can generate a Docker Compose file for your desired environment:

```sh
./scripts/generate_compose_file.sh -e development
```

### 5. Manage Services

Start, stop, or manage your backend services using:

```sh
./scripts/manage_services.sh -a start
```

Other actions: `stop`, `restart`, `restart-service`, `show`, `logs`, `logs-service`.

### 6. Accessing Services

- **LiveKit**: Runs on the configured port (default: 7880).
- **Adminer**: Accessible on port 8080 for database management.
- **Redis**: Exposed on port 6379.
- **ChromaDB**: Used internally for vector storage.

## Service Details

- **Worker**: See `services/worker/README.md` for details on the Rust worker.
- **LiveKit**: Configured via `services/livekit/livekit.yaml`.
- **ChromaDB**: Python-based vector database, initialized by `startup.py`.
- **Adminer**: Lightweight database management UI.
- **Redis**: In-memory data store.

## Development

- Each service can be developed and tested independently.
- Use the provided scripts for orchestration and management.
- For custom Compose setups, see the `docker/services/` directory.

## License

This is a private repository. All rights reserved. Unauthorized use, distribution, or modification of this code is strictly prohibited.
