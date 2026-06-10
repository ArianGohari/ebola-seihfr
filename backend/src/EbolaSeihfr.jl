module EbolaSeihfr

using Genie, Genie.Router, Genie.Renderer.Json, Genie.Requests
using StaticArrays

# Include models
include("seihfr.jl")
include("ode.jl")

"""
    SimParams

Simulation parameters with default values based on the June 2026 baseline.
"""
Base.@kwdef struct SimParams
    solver::String = "rk4"
    days::Float64 = 360.0
    dt::Float64 = 0.1
    
    # Initial State
    e0::Float64 = 225.0
    i0::Float64 = 140.0
    h0::Float64 = 60.0
    r0::Float64 = 110.0
    d0::Float64 = 65.0
    
    # Transmission Rates
    beta_i::Float64 = 0.38
    beta_h::Float64 = 0.15
    beta_f::Float64 = 0.30
    
    # Biological & response parameters
    incubation_days::Float64 = 9.0
    hosp_days::Float64 = 5.0
    gamma_f::Float64 = 0.045
    gamma_r::Float64 = 0.105
    gamma_hr::Float64 = 0.32
    gamma_hd::Float64 = 0.05
    funeral_days::Float64 = 2.0
end

"""
    run_simulation(p::SimParams)

Runs the SEIHFR simulation using the provided parameters. 
Uses `StaticArrays` for high-performance integration.
"""
function run_simulation(p::SimParams)
    # Type-stable parameters for the closure
    βI, βH, βF = Float64(p.beta_i), Float64(p.beta_h), Float64(p.beta_f)
    σ = 1.0 / Float64(p.incubation_days)
    γH = 1.0 / Float64(p.hosp_days)
    γF, γR, γHR, γHD = Float64(p.gamma_f), Float64(p.gamma_r), Float64(p.gamma_hr), Float64(p.gamma_hd)
    γFR = 1.0 / Float64(p.funeral_days)
    
    rates = (βI=βI, βH=βH, βF=βF, σ=σ, γH=γH, γF=γF, γR=γR, γHR=γHR, γHD=γHD, γFR=γFR)

    # Initial state
    s0 = N - (p.e0 + p.i0 + p.h0 + p.r0 + p.d0)
    m0 = @SVector [s0, p.e0, p.i0, p.h0, 0.0, p.r0, p.d0]

    function wrapped_odes(m)
        m_core = SVector(m[1], m[2], m[3], m[4], m[5], m[6])
        dm = odes(m_core, rates)
        d_deaths = death_I(m_core, rates) + death_H(m_core, rates)
        return @SVector [dm[1], dm[2], dm[3], dm[4], dm[5], dm[6], d_deaths]
    end

    solver_func = p.solver == "euler" ? euler : runge_kutta_4
    # Performance Win: Integrated downsampling reduces memory allocations by 1000x+
    result = solver_func(wrapped_odes, m0, p.days, p.dt; max_points=1000)

    # Post-processing the now-smaller result set
    n_out = length(result)
    times = Vector{Float64}(undef, n_out)
    S_v = Vector{Float64}(undef, n_out)
    E_v = Vector{Float64}(undef, n_out)
    I_v = Vector{Float64}(undef, n_out)
    H_v = Vector{Float64}(undef, n_out)
    F_v = Vector{Float64}(undef, n_out)
    R_v = Vector{Float64}(undef, n_out)
    
    peak_I = 0.0
    # Use floor(n_steps/max_points)*dt as the time increment for saved points
    n_steps = Int(floor(p.days / p.dt))
    save_step_val = max(1, div(n_steps, 1000)) * p.dt

    for j in 1:n_out
        r = result[j]
        times[j] = j * save_step_val
        S_v[j] = r[1]
        E_v[j] = r[2]
        I_v[j] = r[3]
        H_v[j] = r[4]
        F_v[j] = r[5]
        R_v[j] = r[6]
        (r[3] > peak_I) && (peak_I = r[3])
    end
    
    last_r = result[end]
    total_observed_cases = (m0[1] - last_r[1]) + (p.e0 + p.i0 + p.h0 + p.r0 + p.d0)
    total_deaths = last_r[7]
    
    return Dict(
        "times" => times,
        "S" => S_v, "E" => E_v, "I" => I_v, "H" => H_v, "F" => F_v, "R" => R_v,
        "stats" => Dict(
            "total_infected" => total_observed_cases,
            "total_deaths" => total_deaths,
            "cfr" => total_observed_cases > 0 ? (total_deaths / total_observed_cases * 100.0) : 0.0,
            "peak_I" => peak_I
        )
    )
end

# --- Routes ---

route("/simulate", method = POST) do
    data = postpayload()
    
    # Helper for parsing payload
    val(k, default) = begin
        v = get(data, k, get(data, string(k), nothing))
        v === nothing ? default : (v isa Number ? Float64(v) : parse(Float64, string(v)))
    end

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

"""
    startup()

Configures and starts the Genie server.
"""
function startup()
    Genie.config.run_as_server = true
    Genie.config.cors_allowed_origins = ["*"]
    
    # Pre-compile for "snappy" first request
    @info "Pre-compiling simulation..."
    run_simulation(SimParams(days=1.0))
    
    up(8000, "0.0.0.0")
end

end # module

# Only start if this file is run directly
if abspath(PROGRAM_FILE) == @__FILE__
    EbolaSeihfr.startup()
end
