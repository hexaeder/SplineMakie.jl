module SplineMakie

using GeometryBasics
using GeometryBasics: VecTypes
using Makie
using LinearAlgebra: Tridiagonal

export BezierPath, MoveTo, LineTo, CurveTo, EllipticalArc, ClosePath, discretize

include("bezier.jl")
include("bezier_extension.jl")

Makie.convert_arguments(P::PointBased, x::BezierPath) = (discretize(x),)

@recipe(Spline, positions) do scene
    Attributes(default_theme(scene, Lines)...)
end

Makie.conversion_trait(::Type{<:Spline}) = PointBased()

function Makie.plot!(p::Combined{spline, S}) where {S<:Tuple{AbstractVector{<:AbstractPoint}}}
    path = @lift splinepath($(p.positions))
    lines!(p, path; p.attributes...)
    plot
end

function splinepath(P::AbstractVector{<:AbstractPoint{Dim, T}}) where {Dim, T}
    if length(P) == 2
        return BezierPath([MoveTo(P[1]), LineTo(P[2])])
    end
    N = length(P)
    pxy = Tuple(cubic_spline(map(p -> p[i], P)) for i in 1:Dim)
    WP = Point{Dim, T}.(zip(pxy...))

    commands = Vector{PathCommand}(undef, N)
    commands[1] = MoveTo(P[1])
    for i in 2:(N-1)
        commands[i] = CurveTo(WP[i-1],
                              2*P[i] - WP[i],
                              P[i])
    end
    commands[N] = CurveTo(WP[N-1],
                          (P[N] + WP[N-1])/2,
                          P[N])
    BezierPath(commands)
end

function cubic_spline(p::Vector{<:Number})
    N = length(p) - 1

    dl = [if i==N-1; 2; else 1 end for i in 1:(N-1)]
    d  = [if i==1; 2; elseif i==N; 7; else 4 end for i in 1:N]
    du = [1 for i in 1:(N-1)]
    M = Tridiagonal(dl, d, du)

    b = [if i == 1
             p[i] + 2p[i+1]
         elseif i == N
             8p[i] + p[i+1]
         else
             4p[i] + 2p[i+1]
         end for i in 1:N]
    return M \ b
end

# TODO: add other inter types like hobby splines

end
