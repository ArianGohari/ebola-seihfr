module App

using Genie, Genie.Router, Genie.Renderer.Json, Genie.Requests

# Include original models
include("seihfr.jl")
include("ode.jl")

# Simulation parameters strictly updated to June 5, 2026 scientific baseline
Base.@kwdef struct SimParams
    solver::String = "rk4"
    days::Float64 = 360.0
    dt::Float64 = 0.1
    
    # Initial State (Accurate Snapshot June 5, 2026)
    # Based on WHO report (396 confirmed) + conservative 1.5x detection gap (~600 burden)
    e0::Float64 = 225.0
    i0::Float64 = 140.0
    h0::Float64 = 60.0
    r0::Float64 = 110.0
    d0::Float64 = 65.0
    
    # Transmission Rates (BDBV Scientific Baseline, R0 ~ 1.44)
    beta_i::Float64 = 0.38
    beta_h::Float64 = 0.15
    beta_f::Float64 = 0.30
    
    # Biological & response parameters
    incubation_days::Float64 = 9.0
    hosp_days::Float64 = 5.0
    gamma_f::Float64 = 0.045
    gamma_r::Float64 = 0.105
    gamma_hr::Float64 = 0.32
    gamma_hd::Float64 = 0.05 # Reduced mortality reflecting modern supportive care
    funeral_days::Float64 = 2.0
end

function run_simulation(p::SimParams)
    # Per-call rate set passed explicitly into odes(); no global mutation,
    # so concurrent requests can't clobber each other's parameters.
    rates = (
        βI = p.beta_i, βH = p.beta_h, βF = p.beta_f,
        σ = 1.0 / p.incubation_days,
        γH = 1.0 / p.hosp_days,
        γF = p.gamma_f, γR = p.gamma_r, γHR = p.gamma_hr, γHD = p.gamma_hd,
        γFR = 1.0 / p.funeral_days,
    )

    # Initial state (6 compartments: S, E, I, H, F, R)
    # We add d0 (cumulative deaths) tracking as a 7th value
    m0 = [N - (p.e0+p.i0+p.h0+p.r0+p.d0), p.e0, p.i0, p.h0, 0.0, p.r0, p.d0]

    function wrapped_odes(m)
        dm = odes(m[1:6], rates)
        # Track cumulative deaths: flux into death from I and H
        d_deaths = death_I(m[1:6], rates) + death_H(m[1:6], rates)
        return [dm..., d_deaths]
    end

    solver = p.solver == "euler" ? euler : runge_kutta_4
    result = solver(wrapped_odes, m0, p.days, p.dt)

    idx = 1:max(1, div(length(result), 1000)):length(result)
    
    last_r = result[end]
    # Statistics relative to the simulation start.
    # total_infected = everyone who has ever entered the E compartment:
    #   (m0[S] - last_r[S]) is the new infections during the run, and the
    #   initial burden (e0 included — those people were already past S) is
    #   added on top so the baseline isn't undercounted.
    total_observed_cases = (m0[S] - last_r[S]) + (p.e0 + p.i0 + p.h0 + p.r0 + p.d0)
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

    # Defaults mirror the SimParams struct so a missing field behaves the
    # same whether it's filled here or by the struct's own default.
    d = SimParams()
    p = SimParams(
        solver          = haskey(data, :solver) ? string(data[:solver]) : (haskey(data, "solver") ? string(data["solver"]) : d.solver),
        days            = val(:days, d.days),
        dt              = val(:dt, d.dt),
        e0              = val(:e0, d.e0),
        i0              = val(:i0, d.i0),
        h0              = val(:h0, d.h0),
        r0              = val(:r0, d.r0),
        d0              = val(:d0, d.d0),
        beta_i          = val(:beta_i, d.beta_i),
        beta_h          = val(:beta_h, d.beta_h),
        beta_f          = val(:beta_f, d.beta_f),
        incubation_days = val(:incubation_days, d.incubation_days),
        hosp_days       = val(:hosp_days, d.hosp_days),
        gamma_f         = val(:gamma_f, d.gamma_f),
        gamma_r         = val(:gamma_r, d.gamma_r),
        gamma_hr        = val(:gamma_hr, d.gamma_hr),
        gamma_hd        = val(:gamma_hd, d.gamma_hd),
        funeral_days    = val(:funeral_days, d.funeral_days)
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
