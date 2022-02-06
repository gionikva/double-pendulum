

function advance(state::Array{T}, f::Function, h::T)::Array{T} where T <: Number
    K1::Array{T} = f(state)
    # c = (tup) -> tup[1] + h * tup[2] / 2
    # zipped = zip(state, K1)
    # print(collect(zipped))
    # print(map(c, collect(zipped)))
    K2::Array{T} = f(map((v, k1) -> v + h * k1 / 2, state, K1))
    K3::Array{T} = f(map((v, k2) -> v + h * k2 / 2, state, K2))
    K4::Array{T} = f(map((v, k3) -> v + h * k3, state, K3))
    return map((v, k1, k2, k3, k4) -> v + h / 6 * (k1 + 2k2 + 2k3 + k4), state, K1, K2, K3, K4)
end

