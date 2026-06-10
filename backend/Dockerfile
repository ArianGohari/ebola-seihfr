FROM julia:1.11

WORKDIR /app

# Set depot path to a writable location inside the container
ENV JULIA_DEPOT_PATH=/app/.julia:/usr/local/julia/share/julia

# Only copy Project.toml to start with a clean slate. 
# We also copy 'src' early so Pkg.precompile() can find the package entry point.
COPY Project.toml ./
COPY src/ ./src/

# Install dependencies.
RUN julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'

# Copy the rest of the code
COPY . .

# Ensure permissions
RUN chmod -R 777 /app/.julia

EXPOSE 8000

# Run the app
CMD ["julia", "--project=.", "src/EbolaSeihfr.jl"]
