"""
    euler(odes, m0, t_end, dt)

Simple Euler integration. Returns a vector of states.
"""
function euler(odes, m0, t_end, dt)
    m = m0
    n_steps = Int(floor(t_end / dt))
    ret = Vector{typeof(m0)}(undef, n_steps)

    @fastmath @inbounds for i in 1:n_steps
        m = m + dt * odes(m)
        ret[i] = m
    end

    return ret
end

"""
    runge_kutta_4(odes, m0, t_end, dt)

Fourth-order Runge-Kutta integration.
"""
function runge_kutta_4(odes, m0, t_end, dt)
    m = m0
    n_steps = Int(floor(t_end / dt))
    ret = Vector{typeof(m0)}(undef, n_steps)

    @fastmath @inbounds for i in 1:n_steps
        k1 = odes(m)
        k2 = odes(m + dt/2 * k1)
        k3 = odes(m + dt/2 * k2)
        k4 = odes(m + dt * k3)
        m = m + dt/6 * (k1 + 2*k2 + 2*k3 + k4)
        ret[i] = m
    end

    return ret
end
