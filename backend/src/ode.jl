"""
    euler(odes, m0, t_end, dt, max_points=1000)

Simple Euler integration with integrated downsampling.
"""
function euler(odes, m0, t_end, dt; max_points=1000)
    m = m0
    n_steps = Int(floor(t_end / dt))
    save_every = max(1, div(n_steps, max_points))
    
    # Pre-allocate slightly more to be safe, then trim
    ret = Vector{typeof(m0)}()
    sizehint!(ret, max_points + 2)
    
    push!(ret, m) # Always include t=0

    @fastmath @inbounds for i in 1:n_steps
        m = m + dt * odes(m)
        if i % save_every == 0
            push!(ret, m)
        end
    end
    
    # Ensure final state is always captured
    if n_steps % save_every != 0
        push!(ret, m)
    end

    return ret
end

"""
    runge_kutta_4(odes, m0, t_end, dt, max_points=1000)

Fourth-order Runge-Kutta with integrated downsampling.
"""
function runge_kutta_4(odes, m0, t_end, dt; max_points=1000)
    m = m0
    n_steps = Int(floor(t_end / dt))
    save_every = max(1, div(n_steps, max_points))
    
    ret = Vector{typeof(m0)}()
    sizehint!(ret, max_points + 2)
    
    push!(ret, m) # Always include t=0

    @fastmath @inbounds for i in 1:n_steps
        k1 = odes(m)
        k2 = odes(m + dt/2 * k1)
        k3 = odes(m + dt/2 * k2)
        k4 = odes(m + dt * k3)
        m = m + dt/6 * (k1 + 2*k2 + 2*k3 + k4)
        
        if i % save_every == 0
            push!(ret, m)
        end
    end
    
    # Ensure final state is always captured
    if n_steps % save_every != 0
        push!(ret, m)
    end

    return ret
end
