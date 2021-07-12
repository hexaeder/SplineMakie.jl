function interpolate(c::EllipticalArc, p0, t)
    ϕ, rx, ry = c.angle, c.r1, c.r2
    θ = c.a1 + (c.a2 - c.a1) * t
    m = Mat2(cos(ϕ), sin(ϕ), -sin(ϕ), cos(ϕ))
    m * Point(rx * cos(θ), ry * sin(θ)) + c.c
end

function interpolate(c::CurveTo, p0, t)
    p1, p2, p3 = c.c1, c.c2, c.p
    (1 - t)^3 * p0 + 3(t - 2t^2 + t^3) * p1 + 3(t^2 -t^3) * p2 + t^3 * p3
end

discretize!(v::Vector{<:AbstractPoint}, c::Union{MoveTo, LineTo}) = push!(v, c.p)
function discretize!(v::Vector{<:AbstractPoint}, c::ClosePath)
    if v[end] !== v[begin]
        push!(v, v[begin])
    end
end

function discretize!(v::Vector{<:AbstractPoint}, c::Union{EllipticalArc, CurveTo})
    N0 = length(v)
    p0 = v[end]
    N = 100
    resize!(v, N0 + N)
    dt = 1.0/N
    for (i, t) in enumerate(dt:dt:1.0)
        v[N0 + i] = interpolate(c, p0, t)
    end
end

export discretize
function discretize(path::BezierPath)
    T = typeof(path.commands[1].p) #XXX BezierPath{T} ?
    v = Vector{T}()
    for c in path.commands
        discretize!(v, c)
    end
    return v
end

#=
using LinearAlgebra: norm, cross, ⋅, normalize

"""continous parametric from of bezier path"""
function (path::BezierPath)(t)
    N = length(path.commands) - 1
    t = t * N
    seg = round(Int, t % N) + 1
    tseg = rem(t, N)
    p0 = endpos(path.commands[seg]) # get last point from prev
    c = path.commands[seg+1]
    if c isa ClosePath
        return interpolate(LineTo(endpos(path.commands[1])), p0, tseg)
    else
        return interpolate(path.commands[seg+1], p0, tseg)
    end
end

endpos(c::MoveTo) = c.p
endpos(c::LineTo) = c.p
endpos(c::CurveTo) = c.p
endpos(c::EllipticalArc) = c(zero(Point2), 1)

interpolate(c::MoveTo, p0, t) = endpos(c)
interpolate(c::LineTo, p0, t) = p0 + (c.p - p0) * t


# experiments on adaptive discretization
function tangent(c::CurveTo, p0, t)
    p1, p2, p3 = c.c1, c.c2, c.p
    normalize(-3(1 - t)^2 * p0 + 3(1 - 4t + 3t^2) * p1 + 3(2t -3t^2) * p2 + 3t^2 * p3)
end

function discretize_adaptive!(v::Vector{<:AbstractPoint}, c::Union{EllipticalArc, CurveTo})
    α = 2 / 360 * 2π
    dtstep = 0.01

    p0 = v[end]

    t = 0.0
    while true
        oldT = tangent(c, p0, t)
        T = oldT
        steps = 0
        while abs(oldT ⋅ T) > cos(α)
            t += dtstep
            steps += 1
            T = tangent(c, p0, t)
        end
        if steps == 1 # if a single step was to much than adjust stepsize
            dtstep = dtstep/2
            continue
        end
        t >= 1.0 && break

        t -= dtstep
        push!(v, interpolate(c, p0, t))
    end
    push!(v, interpolate(c, p0, 1.0))
end
=#
