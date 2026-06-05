FROM julia:1.11

WORKDIR /app

# Copy dependency files first for caching
COPY Project.toml Manifest.toml ./

# Install dependencies
RUN julia --project=. -e 'using Pkg; Pkg.resolve(); Pkg.instantiate(); Pkg.precompile()'

# Copy source code
COPY . .

# Expose Genie port
EXPOSE 8000

# Run the app
CMD ["julia", "--project=.", "app.jl"]
