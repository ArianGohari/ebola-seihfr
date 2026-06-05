# Ebola Simulation - Justfile

# Default task: list all commands
default:
    @just --list

# Install all dependencies for backend and frontend
install:
    @echo "Instantiating Julia project..."
    @julia --project=backend -e 'using Pkg; Pkg.instantiate()'
    @echo "Installing pnpm packages..."
    @cd frontend && pnpm install

# Run the Julia backend (port 8000)
backend:
    @julia --project=backend backend/app.jl

# Run the SvelteKit frontend in development mode (port 5173)
# --strictPort ensures it fails if 5173 is taken, preventing ghost instances
frontend:
    @cd frontend && NODE_NO_WARNINGS=1 pnpm dev --port 5173 --strictPort

# Run the complete stack in development mode
dev:
    @echo "Starting backend and frontend..."
    @echo "Backend: http://localhost:8000"
    @echo "Frontend: http://localhost:5173"
    @echo "(Giving Julia 3s to warm up before starting Vite...)"
    @ (trap 'kill 0' SIGINT; just backend & (sleep 3 && NODE_NO_WARNINGS=1 just frontend))

# Build the frontend for production
build:
    @cd frontend && NODE_NO_WARNINGS=1 pnpm build

# Preview the production build
preview: build
    @echo "Starting backend and production preview..."
    @ (trap 'kill 0' SIGINT; just backend & cd frontend && NODE_NO_WARNINGS=1 pnpm preview)

# Identify which processes are using the app ports
check-ports:
    @echo "Checking port 8000 (Backend)..."
    @lsof -i :8000 || echo "Port 8000 is free."
    @echo "\nChecking port 5173 (Frontend)..."
    @lsof -i :5173 || echo "Port 5173 is free."

# Kill processes on the app ports
kill-ports:
    @echo "Killing processes on 8000 and 5173..."
    @-lsof -ti :8000 | xargs kill -9 2>/dev/null
    @-lsof -ti :5173 | xargs kill -9 2>/dev/null
    @echo "Ports cleared."

# Docker tasks
docker-build:
    @docker compose build

docker-up:
    @docker compose up

docker-down:
    @docker compose down

# Clean node_modules and build artifacts
clean:
    @rm -rf frontend/node_modules frontend/.svelte-kit frontend/build
