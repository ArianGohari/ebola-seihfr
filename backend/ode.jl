"""
    euler(odes, m0, t_end, dt, max_points=1000)

Simple Euler integration with integrated downsampling to save memory.
"""
function euler(odes, m0, t_end, dt; max_points=1000)
    m = m0
    n_steps = Int(floor(t_end / dt))
    
    # We only save approximately max_points
    save_step = max(1, div(n_steps, max_points))
    n_saved = Int(ceil(n_steps / save_step))
    
    ret = Vector{typeof(m0)}(undef, n_saved)
    save_idx = 1
    
    @fastmath @inbounds for i in 1:n_steps
        m = m + dt * odes(m)
        if i % save_step == 0 && save_idx <= n_saved
            ret[save_idx] = m
            save_idx += 1
        end
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
    
    save_step = max(1, div(n_steps, max_points))
    n_saved = Int(ceil(n_steps / save_step))
    
    ret = Vector{typeof(m0)}(undef, n_saved)
    save_idx = 1

    @fastmath @inbounds for i in 1:n_steps
        k1 = odes(m)
        k2 = odes(m + dt/2 * k1)
        k3 = odes(m + dt/2 * k2)
        k4 = odes(m + dt * k3)
        m = m + dt/6 * (k1 + 2*k2 + 2*k3 + k4)
        
        if i % save_step == 0 && save_idx <= n_saved
            ret[save_idx] = m
            save_idx += 1
        end
    end

    return ret
end
