include("runge_kutta.jl")

function get_derivatives(state::Array{T})::Array{T} where {T<:Number}
    l = 1
    g = 9.8
    (theta_1, theta_2, omega_1, omega_2) = state
    theta_1_dot = omega_1
    theta_2_dot = omega_2

    delta_theta = theta_2 - theta_1
    denominator = l * (cos(delta_theta)^2 - 2)

    sdt = sin(delta_theta)
    cdt = cos(delta_theta)
    st1 = sin(theta_1)
    st2 = sin(theta_2)
    omega_1_dot = -((l * omega_1^2) * sdt * cdt + (l * omega_2^
                    2) * sdt + g * st2 - 2 * g * st1) / denominator
    omega_2_dot = ((l * omega_2^2) * sdt * cdt + (2 * l * omega_1^2) *
                                                 sdt + 2 * g * st2 - 2 * g * st1 * cdt) / denominator
    return [theta_1_dot, theta_2_dot, omega_1_dot, omega_2_dot]
end

function get_energy(m::Number, l::Number, g::Number, theta_1::Number, theta_2::Number, omega_1::Number, omega_2::Number)::Tuple{BigFloat,BigFloat}
    T = m * l^2 * (3 / 2 * omega_1^2 + omega_2^2 + 2omega_1 * omega_2 * cos(theta_2 - theta_1))
    U = -m * g * l * (2cos(theta_1) + cos(theta_2))
    return (T, U)
end

function simulate()
    setprecision(64)
    dt = (0.0001)
    pir = π
    theta_1, theta_2, omega_1, omega_2 = (1.0), (0.0), (0.0), (0.0)
    state = [theta_1, theta_2, omega_1, omega_2]
    m, l = 1.0, 1.0
    E0::Float64 = sum(get_energy(m, l, 9.8, theta_1, theta_2, omega_1, omega_2))
    println("Initial energy: $E0")
    vals = [state]
    diffs = []
    sdiffs = []
    for _ = 1:200000
        state = advance(state, get_derivatives, dt)
        state = [state[1] % 2pir, state[2] % 2pir, state[3], state[4]]
        theta_1, theta_2, omega_1, omega_2 = state
        E::Float64 = sum(get_energy(m, l, 9.8, theta_1, theta_2, omega_1, omega_2))
        diff = abs(E0 - E)
        sdiff = E0 - E
        push!(diffs, diff)
        push!(sdiffs, sdiff)
        push!(vals, state)
    end
    println("Max diff: $(reduce((x, y) -> max(x, y), diffs))")
    mdiff = sum(diffs) / length(diffs)
    println("Avg diff: $(mdiff)")
    println("Avg %Err: $(abs(mdiff / E0) * 100)")
    msdiff = sum(sdiffs) / length(sdiffs)
    println("Amt %Err: $(msdiff / E0 * 100)")

end

function get_d(S1::Array{T}, S2::Array{T})::T where {T<:Number}
    return sqrt(sum((S2 - S1) .^ 2))
end

function reset(S1::Array{T}, S2::Array{T}, d0::T)::Array{T} where {T<:Number}
    ΔS = S2 - S1

    d::T = sqrt(sum(ΔS .^ 2))

    return S1 + (ΔS .* (d0 / d))
end

function calculate_lyapunov()
    setprecision(128)
    dt = Float64(0.01)
    pir = convert(Float64, π)
    m, l = 1, 1.0

    theta_1_a::Float64, theta_2_a::Float64, omega_1_a::Float64, omega_2_a::Float64 = (1.0), (0.0), (0.0), (0.0)
    state_a = [theta_1_a, theta_2_a, omega_1_a, omega_2_a]
    E0_a = sum(get_energy(m, l, 9.8, theta_1_a, theta_2_a, omega_1_a, omega_2_a))

    theta_1_b::Float64, theta_2_b::Float64, omega_1_b::Float64, omega_2_b::Float64 = (1.0), (10^-1), (0.0), (0.0)
    state_b = [theta_1_b, theta_2_b, omega_1_b, omega_2_b]
    E0_b = sum(get_energy(m, l, 9.8, theta_1_b, theta_2_b, omega_1_b, omega_2_b))

    d0 = get_d(state_a, state_b)
    vals_a = [state_a]
    s = 0.0
    n = 10^8
    for i = 1:n
        state_a = advance(state_a, get_derivatives, dt)
        state_b = advance(state_b, get_derivatives, dt)

        s += log(get_d(state_a, state_b) / d0)

        state_b = reset(state_a, state_b, d0)
        state_b = reset(state_a, state_b, d0)

        if i % 400000 == 1
            println(s / (i * dt))
        end
    end

    λ = s / (n * dt)
    println("λ = $λ")
end

function main()
    calculate_lyapunov()
end

main()