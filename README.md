# Ebola SEIHFR Modelling: 2026 Ituri Response

Interactive SEIHFR compartmental model for the 2026 Ebola outbreak in Ituri Province, DRC. This tool lets researchers and policy responders simulate transmission dynamics and test the impact of different intervention strategies.

## Overview

The SEIHFR model extends the standard SIR approach to account for the specific transmission pathways of Ebola Virus Disease (EVD):
- **S**: Susceptible
- **E**: Exposed (Incubation period)
- **I**: Infectious (Community transmission)
- **H**: Hospitalized (Reduced transmission in clinical settings)
- **F**: Funeral (Transmission during traditional burial practices)
- **R**: Recovered (Immunity)

## Features

- **Real-time Simulation**: Adjust community, hospital, and funeral transmission rates on the fly.
- **Snapshot Config**: Set initial counts for exposed, infectious, and hospitalized cases based on current field data.
- **Policy Testing**: Model the effect of varying "time to hospitalization" and "safe burial" protocols.
- **Visual Analytics**: Interactive charts with log/linear scaling and compartment toggles.

## Tech Stack

- **Backend**: Julia (DifferentialEquations.jl) for high-performance ODE solving.
- **Frontend**: Svelte 5 + Tailwind CSS for a responsive, modern dashboard.
- **Communication**: FastAPI-style Julia web server (HTTP.jl/Oxygen.jl).

## Local Development

### Prerequisites
- Julia 1.10+
- Node.js 20+ (pnpm recommended)
- Docker (optional, for containerized deployment)

### Setup

1. **Backend**:
   ```bash
   cd backend
   julia --project -e 'using Pkg; Pkg.instantiate()'
   julia --project app.jl
   ```

2. **Frontend**:
   ```bash
   cd frontend
   pnpm install
   pnpm dev
   ```

## License

MIT
