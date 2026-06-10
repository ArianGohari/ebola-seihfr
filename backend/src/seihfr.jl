using StaticArrays

# State indices
const S = 1  # Susceptible
const E = 2  # Exposed (incubation)
const I = 3  # Infectious
const H = 4  # Hospitalized
const F = 5  # Funeral (deceased infectious)
const R = 6  # Recovered/Safely buried

const N = 7_000_000.0 # Ituri Province population

"""
    infection(m, p)

Calculate the transmission flux based on infectious categories (I, H, F).
"""
infection(m, p) = (p.βI*m[I] + p.βH*m[H] + p.βF*m[F]) / N * m[S]

incubation(m, p) = p.σ * m[E]
hospitalization(m, p) = p.γH * m[I]
death_I(m, p) = p.γF * m[I]
recovery_I(m, p) = p.γR * m[I]
recovery_H(m, p) = p.γHR * m[H]
death_H(m, p) = p.γHD * m[H]
burial(m, p) = p.γFR * m[F]

"""
    odes(m, p)

The SEIHFR model differential equations. Returns an `SVector` for zero-allocation performance.
"""
function odes(m, p)
    inf = infection(m, p)
    inc = incubation(m, p)
    hosp = hospitalization(m, p)
    di = death_I(m, p)
    ri = recovery_I(m, p)
    rh = recovery_H(m, p)
    dh = death_H(m, p)
    bur = burial(m, p)

    dS = -inf
    dE = inf - inc
    dI = inc - hosp - di - ri
    dH = hosp - dh - rh
    dF = di + dh - bur
    dR = bur + ri + rh
    
    return @SVector [dS, dE, dI, dH, dF, dR]
end
