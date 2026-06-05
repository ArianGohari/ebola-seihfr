FROM julia:1.11

WORKDIR /app

# Set depot path to a writable location inside the container
ENV JULIA_DEPOT_PATH=/app/.julia:/usr/local/julia/share/julia

# Only copy Project.toml to start with a clean slate
COPY Project.toml ./

# Install dependencies. We skip Manifest.toml entirely to let 1.11 
# solve the environment from scratch.
RUN julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'

# Copy the rest of the code
COPY . .

# Ensure permissions
RUN chmod -R 777 /app/.julia

EXPOSE 8000

# Run the app
CMD ["julia", "--project=.", "app.jl"]
