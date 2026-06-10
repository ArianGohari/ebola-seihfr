const S = 1  # healthy, can contract disease
const E = 2  # infected, not yet infectious (incubation)
const I = 3  # infectious, symptomatic
const H = 4  # hospitalized, isolated
const F = 5  # deceased, infectious during funeral/burial
const R = 6  # recovered or safely buried

const N = 7_000_000.0 # Ituri Province population (IOM 2025)

# Model parameters are passed in explicitly (no globals) so concurrent
# simulations cannot clobber each other's rates. `p` is a NamedTuple with:
#   βI, βH, βF  transmission rates
#   σ           incubation rate (1/incubation_days)
#   γH          hospitalization rate (1/hosp_days)
#   γF, γR      death/recovery rates without hospital
#   γHR, γHD    recovery/death rates in hospital
#   γFR         burial rate (1/funeral_days)

infection(m, p) = (p.βI*m[I] + p.βH*m[H] + p.βF*m[F]) / N * m[S]
incubation(m, p) = p.σ * m[E]
hospitalization(m, p) = p.γH * m[I]
death_I(m, p) = p.γF * m[I]
recovery_I(m, p) = p.γR * m[I]
recovery_H(m, p) = p.γHR * m[H]
death_H(m, p) = p.γHD * m[H]
burial(m, p) = p.γFR * m[F]

function odes(m, p)
    dS = -infection(m, p)
    dE = infection(m, p) - incubation(m, p)
    dI = incubation(m, p) - hospitalization(m, p) - death_I(m, p) - recovery_I(m, p)
    dH = hospitalization(m, p) - death_H(m, p) - recovery_H(m, p)
    dF = death_I(m, p) + death_H(m, p) - burial(m, p)
    dR = burial(m, p) + recovery_I(m, p) + recovery_H(m, p)
    return [dS, dE, dI, dH, dF, dR]
end
