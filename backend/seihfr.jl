const S = 1  # healthy, can contract disease
const E = 2  # infected, not yet infectious (incubation)
const I = 3  # infectious, symptomatic
const H = 4  # hospitalized, isolated
const F = 5  # deceased, infectious during funeral/burial
const R = 6  # recovered or safely buried

const N = 3_000_000.0 # Ituri Province population

# transmission rates (Bundibugyo 2026)
βI, βH, βF = 0.38, 0.15, 0.30

# transition rates (adjusted for Bundibugyo CFR ~24.2%)
σ = 1/9    # incubation period ~9 days
γH = 0.2   # time to hospitalization ~5 days
γF = 0.045 # time to death without hospital
γR = 0.105 # time to recovery without hospital
γHR = 0.32 # time to recovery in hospital
γHD = 0.08 # time to death in hospital
γFR = 0.5  # funeral duration ~2 days

infection(m) = (βI*m[I] + βH*m[H] + βF*m[F]) / N * m[S]
incubation(m) = σ * m[E]
hospitalization(m) = γH * m[I]
death_I(m) = γF * m[I]
recovery_I(m) = γR * m[I]
recovery_H(m) = γHR * m[H]
death_H(m) = γHD * m[H]
burial(m) = γFR * m[F]

function odes(m)
    dS = -infection(m)
    dE = infection(m) - incubation(m)
    dI = incubation(m) - hospitalization(m) - death_I(m) - recovery_I(m)
    dH = hospitalization(m) - death_H(m) - recovery_H(m)
    dF = death_I(m) + death_H(m) - burial(m)
    dR = burial(m) + recovery_I(m) + recovery_H(m)
    return [dS, dE, dI, dH, dF, dR]
end
