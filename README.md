# SplineMakie
Just a prototype for a spline recipe, something which takes several points and draws a continous curve throuth them
```julia
p = rand(Point2f0, 5)
spline(p)
scatter!(p)
```
<img width="396" alt="Screenshot 2021-07-12 at 15 43 08" src="https://user-images.githubusercontent.com/35867212/125300258-23948680-e32a-11eb-9bf5-d4d32bd509c7.png">

```julia
p = rand(Point3f0, 5)
spline(p)
scatter!(p, markersize=20)
```
<img width="294" alt="Screenshot 2021-07-12 at 15 42 48" src="https://user-images.githubusercontent.com/35867212/125300255-22635980-e32a-11eb-8d46-ca40bef38e11.png">


<!--[![Build Status](https://github.com/hexaeder/SplineMakie.jl/workflows/CI/badge.svg)](https://github.com/hexaeder/SplineMakie.jl/actions)-->

