# This file is a part of JuliaFEM.
# License is MIT: see https://github.com/JuliaFEM/JuliaFEM.jl/blob/master/LICENSE.md

using JuliaFEM
using JuliaFEM.Testing

@testset "local field initialization" begin

    @testset "initialize scalar field problem" begin
        el = Element(Seg2, [1, 2])
        pr = Problem(Heat, 1)
        push!(pr, el)
        initialize!(pr, 0.0, Val{:Local})
        @test haskey(el, "temperature")
        # one timestep in field "temperature"
        @test length(el["temperature"]) == 1
        # this way we access to field at default time t=0.0, it's different than ^!
        @test length(el("temperature")) == 2
        # length of single increment
        @test length(el("temperature", 0.0)) == 2
        @test length(last(el, "temperature").data) == 2
    end

    @testset "initialize vector field problem" begin
        el = Element(Seg2, [1, 2])
        pr = Problem(Elasticity, 2)
        push!(pr, el)
        initialize!(pr, 0.0, Val{:Local})
        @test haskey(el, "displacement")
        @test length(el["displacement"]) == 1
        # this way we access to field at default time t=0.0, it's different than ^!
        @test length(el("displacement")) == 2
        # length of single increment
        @test length(el("displacement", 0.0)) == 2
        @test length(last(el, "displacement").data) == 2
    end

    @testset "initialize boundary problem" begin
        el = Element(Seg2, [1, 2])
        pr = Problem(Dirichlet, "bc", 1, "temperature")
        push!(pr, el)
        initialize!(pr, 0.0, Val{:Local})
        @test haskey(el, "reaction force")
        @test haskey(el, "temperature")
    end

end

@testset "global field initialization" begin

    @testset "initialize global field for vector field problem" begin
        el1 = Element(Seg2, 1, [1, 2])
        el2 = Element(Seg2, 2, [2, 3])
        pr = Problem(Elasticity, 2)
        push!(pr, el1, el2)
        initialize!(pr, 0.0, Val{:Global})
        @test isa(pr["displacement"], DVTV)
        # all elements + problem share same dict based nodal field
        @test isapprox(el1("displacement", 0.0)[1], [0.0, 0.0])
        @test isapprox(el1("displacement", 0.0)[3], [0.0, 0.0])
        @test isapprox(el2("displacement", 0.0)[2], [0.0, 0.0])
        update!(el1, "displacement", 0.0 => Dict(2 => [1.0, 1.0]))
        @test isapprox(el2("displacement", 0.0)[2], [1.0, 1.0])
        @test isapprox(pr("displacement", 0.0)[2], [1.0, 1.0])
    end

end

@testset "create dict field depending from problems" begin
    X = Dict{Int64, Vector{Float64}}(
        1 => [0.0, 0.0],
        2 => [1.0, 0.0],
        3 => [1.0, 1.0],
        4 => [0.0, 1.0],
        5 => [0.0, 2.0],
        6 => [1.0, 2.0],
        7 => [1.0, 3.0],
        8 => [0.0, 3.0])
    p1 = Problem(Elasticity, "Body 1", 2)
    e1 = Element(Quad4, 1, [1, 2, 3, 4])
    push!(p1, e1)
    update!(p1, "geometry", 0.0 => X)
    update!(p1, "geometry", 0.0 => X)
    @test isapprox(p1("geometry", 0.0)[2], [1.0, 0.0])
    @test isapprox(e1("geometry", 0.0)[2], [1.0, 0.0]) # value is updated to element also
    update!(p1, "geometry", 0.0 => Dict(2 => [1.0, 1.0]))
    @test isapprox(p1("geometry", 0.0)[2], [1.0, 1.0])
    @test isapprox(e1("geometry", 0.0)[2], [1.0, 1.0])
    # rest of data is still there
    @test isapprox(p1("geometry", 0.0)[3], [1.0, 1.0])
    @test isapprox(e1("geometry", 0.0)[3], [1.0, 1.0])
end
