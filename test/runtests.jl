using ChairmarksExtras
using Test
using Aqua

@testset "ChairmarksExtras.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(ChairmarksExtras)
    end
    # Write your tests here.
end
