using ChairmarksExtras
using Test

@testset "ChairmarksExtras.jl" begin
    @test (@belapsed 1+1) isa Float64
    @test 0 < (@belapsed 1+1) < 100
    @test 0 === @ballocated 1+1
    @test 0 === @ballocations 1+1
    @test 0 < @ballocated rand(10)
    @test 0 < @ballocations rand(10)

    p = Pipe()
    redirect_stdout(p) do
        @test 2 == @btime 1+1
    end
    close(p.in)
    s = read(p.out, String)
    m = match(r"^  (\d+\.\d\d\d (n|μ|m|))s$", s).captures[1]
    @test s == "  "*m*"s\n"

    @test (@btimed 5 sqrt _^2 @assert _ ≈ 5).value === nothing
    @test (@btimed 5 sqrt _^2 inv).value ≈ 1/5
    @test (@btimed 5 _^2 inv).value ≈ 1/25
    @test_throws MethodError @btimed

    @testset "Aqua" begin
        import Aqua
        # persistent_tasks=false because that test is slow and we don't use persistent tasks
        Aqua.test_all(ChairmarksExtras, deps_compat=false, persistent_tasks=false)
        Aqua.test_deps_compat(ChairmarksExtras, check_extras=false)
    end
end
