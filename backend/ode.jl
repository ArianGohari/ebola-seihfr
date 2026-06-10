function euler(odes, m0, t_end, dt)
    m = copy(m0)
    ret = Vector{typeof(m)}()

    for _ in dt:dt:t_end
        m = m + dt * odes(m)
        push!(ret, copy(m))
    end

    return ret
end


function runge_kutta_4(odes, m0, t_end, dt)
    m = copy(m0)
    ret = Vector{typeof(m)}()

    for _ in dt:dt:t_end
        k1 = odes(m)
        k2 = odes(m + dt/2 * k1)
        k3 = odes(m + dt/2 * k2)
        k4 = odes(m + dt * k3)
        m = m + dt/6 * (k1 + 2*k2 + 2*k3 + k4)
        push!(ret, copy(m))
    end

    return ret
end
