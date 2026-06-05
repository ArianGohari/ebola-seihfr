module App

using Genie, Genie.Router, Genie.Renderer.Json, Genie.Requests

# Include original models
include("seihfr.jl")
include("ode.jl")

# Simulation parameters updated to June 5, 2026 scientific baseline
Base.@kwdef struct SimParams
    solver::String = "rk4"
    days::Float64 = 360.0
    dt::Float64 = 0.1
    
    # Initial State (Snapshot June 5, 2026)
    e0::Float64 = 280.0
    i0::Float64 = 140.0
    h0::Float64 = 60.0
    r0::Float64 = 110.0
    d0::Float64 = 65.0
    
    # Transmission Rates (Updated BDBV 2026)
    beta_i::Float64 = 0.35
    beta_h::Float64 = 0.12
    beta_f::Float64 = 0.35
    
    # Biological & response parameters
    incubation_days::Float64 = 8.4
    hosp_days::Float64 = 4.2
    gamma_f::Float64 = 0.045
    gamma_r::Float64 = 0.105
    gamma_hr::Float64 = 0.32
    gamma_hd::Float64 = 0.08
    funeral_days::Float64 = 2.0
end

function run_simulation(p::SimParams)
    # Update globals in seihfr.jl for odes(m) consistency
    global βI, βH, βF = p.beta_i, p.beta_h, p.beta_f
    global σ = 1.0 / p.incubation_days
    global γH = 1.0 / p.hosp_days
    global γF, γR, γHR, γHD = p.gamma_f, p.gamma_r, p.gamma_hr, p.gamma_hd
    global γFR = 1.0 / p.funeral_days

    # Initial state (6 compartments: S, E, I, H, F, R)
    # We add d0 (cumulative deaths) tracking as a 7th value
    m0 = [N - (p.e0+p.i0+p.h0+p.r0+p.d0), p.e0, p.i0, p.h0, 0.0, p.r0, p.d0]

    function wrapped_odes(m)
        dm = odes(m[1:6])
        # Track cumulative deaths: flux into death from I and H
        d_deaths = death_I(m[1:6]) + death_H(m[1:6])
        return [dm..., d_deaths]
    end

    solver = p.solver == "euler" ? euler : runge_kutta_4
    result = solver(wrapped_odes, m0, p.days, p.dt)

    idx = 1:max(1, div(length(result), 1000)):length(result)
    
    last_r = result[end]
    # Statistics relative to the simulation start
    # total_infected includes everyone who has ever entered the E compartment
    # In this model, initial S - current S represents total new + existing cases
    total_observed_cases = (m0[S] - last_r[S]) + (p.i0 + p.h0 + p.r0 + p.d0)
    total_deaths = last_r[7]
    
    return Dict(
        "times" => [i * p.dt for i in idx],
        "S" => [r[S] for r in result[idx]],
        "E" => [r[E] for r in result[idx]],
        "I" => [r[I] for r in result[idx]],
        "H" => [r[H] for r in result[idx]],
        "F" => [r[F] for r in result[idx]],
        "R" => [r[R] for r in result[idx]],
        "stats" => Dict(
            "total_infected" => total_observed_cases,
            "total_deaths" => total_deaths,
            "cfr" => total_observed_cases > 0 ? (total_deaths / total_observed_cases * 100.0) : 0.0,
            "peak_I" => maximum([r[I] for r in result])
        )
    )
end

# --- Routes ---

route("/simulate", method = POST) do
    data = postpayload()
    
    # Helper for parsing payload (handles both string and symbol keys)
    val(k, default) = begin
        v = get(data, k, get(data, string(k), nothing))
        v === nothing ? default : (v isa Number ? Float64(v) : parse(Float64, string(v)))
    end

    p = SimParams(
        solver          = haskey(data, :solver) ? string(data[:solver]) : (haskey(data, "solver") ? string(data["solver"]) : "rk4"),
        days            = val(:days, 360.0),
        dt              = val(:dt, 0.1),
        e0              = val(:e0, 180.0),
        i0              = val(:i0, 80.0),
        beta_i          = val(:beta_i, 0.35),
        beta_h          = val(:beta_h, 0.14),
        beta_f          = val(:beta_f, 0.33),
        incubation_days = val(:incubation_days, 6.3),
        hosp_days       = val(:hosp_days, 4.5),
        gamma_f         = val(:gamma_f, 0.05),
        gamma_r         = val(:gamma_r, 0.10),
        gamma_hr        = val(:gamma_hr, 0.28),
        gamma_hd        = val(:gamma_hd, 0.07),
        funeral_days    = val(:funeral_days, 2.0)
    )
    
    run_simulation(p) |> json
end

# Startup
Genie.config.run_as_server = true
Genie.config.cors_allowed_origins = ["*"]

# Pre-compile
run_simulation(SimParams(days=1.0))

up(8000, "0.0.0.0")

end
