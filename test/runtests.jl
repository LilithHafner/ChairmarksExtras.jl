using ChairmarksExtras
using Test

@testset "ChairmarksExtras.jl" begin
    @test (@belapsed 1+1) isa Float64
    @test 0 < (@belapsed 1+1) < 100
    @test 0 == @ballocated 1+1
    @test 0 == @ballocations 1+1
    @test 0 < @ballocated rand(10)
    @test 0 < @ballocations rand(10)
    @test 0 < @ballocated for _ in 1:rand(50:100) rand(3) end
    @test 0 < @ballocations for _ in 1:rand(50:100) rand(3) end

    f = tempname()
    open(f, "w") do io
        redirect_stdout(io) do
            @test 2 == @btime 1+1
        end
    end
    s = read(f, String)
    m = match(r"^  (\d+\.\d\d\d (n|μ|m|))s$", s).captures[1]
    @test s == "  "*m*"s\n"

    @test (@btimed 5 sqrt _^2 @assert _ ≈ 5).value === nothing
    @test (@btimed 5 sqrt _^2 inv).value ≈ 1/5
    @test (@btimed 5 _^2 inv).value ≈ 1/25
    @test_throws MethodError @btimed
    x = @btimed 1+1 samples=10 evals=17
    @test x.samples == 10
    @test x.evals == 17
    @test x.value == 2

    b = @be 1+1
    @test b.time isa Vector{Float64}
    @test :time in propertynames(b)
    @test_throws ErrorException b.squids

    # Interpolation
    x = 3
    @test redirect_stdout(devnull) do
        (@btime 1 + $x seconds=0)
    end == 4

    @testset "Aqua" begin
        import Aqua
        # persistent_tasks=false because that test is slow and we don't use persistent tasks
        Aqua.test_all(ChairmarksExtras, deps_compat=false, persistent_tasks=false, piracies=false)
        Aqua.test_deps_compat(ChairmarksExtras, check_extras=false)
        Aqua.test_piracies(ChairmarksExtras, treat_as_own=[Chairmarks.Benchmark])
    end
end
