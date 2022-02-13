include("double_pendulum.jl")
using Plots
using Interpolations
# gr(show = true)

# in IJulia this would be: gr(show = :ijulia)
# function run()
#     x = 0.0:0.01:2.0*pi
#     
# end
function plot_pendulum()
    dt = 0.01
    dtp = 1/30
    vals1 = simulate(2.0, 1.0, 0.0, 0.0, dt=dt)
    theta_1_1 = interpolate(map(a -> a[1], vals1[1]), BSpline(Linear()))
    theta_2_1 = interpolate(map(a -> a[2], vals1[1]), BSpline(Linear()))
  

    vals2 = simulate(2.0, 1 + 10^-3, 0.0, 0.0, dt=dt)
    theta_1_2 = interpolate(map(a -> a[1], vals2[1]), BSpline(Linear()))
    theta_2_2 = interpolate(map(a -> a[2], vals2[1]), BSpline(Linear()))

    # println(itp(1.5))

    x = 0.0:dtp:5
    i = 1
    while true
        p1 = plot([v -> theta_1_1(v/dt+1), v -> theta_1_2(v/dt+1)], x .+ i*dtp, ylims=(-2pi, 2pi))
        p2 = plot([v -> theta_2_1(v/dt+1), v -> theta_2_2(v/dt+1)], x .+ i*dtp, ylims=(-2pi, 2pi))
       
        display(plot(p1, p2, layout=(2, 1)))
        i += 1
    end

    # p = plot(zeros(0), [Theta_1[1]], leg = false)
    # anim = Animation()
    # for t = 0.0:dtp:5.
    #     push!(p, t, itp(t/dt+1))
    #     frame(anim)
    # end

end
plot_pendulum()