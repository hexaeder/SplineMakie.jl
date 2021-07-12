using SplineMakie
using GeometryBasics
using Test
using Makie
using GLMakie

@testset "SplineMakie.jl" begin
    @testest "scatterlines of markers" begin
        path = SplineMakie.BezierCircle
        scatterlines(discretize(path))

        path = SplineMakie.BezierUTriangle
        scatterlines(discretize(path))

        path = SplineMakie.BezierDTriangle
        scatterlines(discretize(path))

        path = SplineMakie.BezierSquare
        scatterlines(discretize(path))

        path = SplineMakie.BezierCross
        scatterlines(discretize(path))
    end

    @testest "convert arguments for lines" begin
        path = SplineMakie.BezierCircle
        lines(path)
    end

    @testest "cubic spline" begin
        # 2d
        using SplineMakie: splinepath
        p = Point2f0[]
        for x in 0:10
            push!(p, Point2f0(x, rand()))
        end

        scatter(p)
        lines!(splinepath(p))

        # 3d
        p = rand(Point3f0, 5)
        scatter(p)
        lines!(splinepath(p))

    end

    @testset "recipe" begin
        p = rand(Point2f0, 5)
        spline(p)
        scatter!(p)

        p = rand(Point3f0, 5)
        spline(p)
        scatter!(p, markersize=20)

        x = [1.0,2,3]
        y = [1.0,-1,5]
        z = [1.0,-4.5,0.2]
        spline(x, y)
        spline(x, y, z)

        p = [(0,0), (-.2,.5), (0,1)]
        spline(p)

        p = [(0,0), (1,1)]
        f, ax, p = spline(p)
        p.plots[1][1][]
    end

end
