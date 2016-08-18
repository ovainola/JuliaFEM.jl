# This file is a part of JuliaFEM.
# License is MIT: see https://github.com/JuliaFEM/JuliaFEM.jl/blob/master/LICENSE.md

using JuliaFEM
using JuliaFEM.Testing

@testset "vector field" begin
    el = Element(Seg2, 1, [1, 2])
    X = Vector{Float64}[[0.0, 0.0], [1.0, 0.0]]
    update!(el, "field1", X)
    update!(el, "field2", 0.0 => X)
    @test isa(el["field1"], DVTI)
    @test isa(el["field2"], DVTV)
    @test isapprox(el("field1")[1], [0.0, 0.0])
    @test isapprox(el("field1", 0.0)[1], [0.0, 0.0])
    @test isapprox(el("field1", [0.0], 0.0), [0.5, 0.0])
end

@testset "dict field" begin
    el = Element(Seg2, 1, [1, 2])
    X = Dict{Int64, Vector{Float64}}(1 => [0.0, 0.0], 2 => [1.0, 0.0], 3 => [0.5, 0.5])
    update!(el, "field1", X)
    update!(el, "field2", 0.0 => X)
    @test isa(el["field1"], DVTI)
    @test isa(el["field2"], DVTV)
    @test isapprox(el("field1")[1], [0.0, 0.0])
    @test isapprox(el("field1", 0.0)[1], [0.0, 0.0])
    @test isapprox(el("field1", 0.0)[3], [0.5, 0.5])
    @test isapprox(el("field1", [0.0], 0.0), [0.5, 0.0])
end
