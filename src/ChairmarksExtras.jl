module ChairmarksExtras

using Reexport
@reexport using Chairmarks

export @belapsed, @ballocated, @ballocations, @btime, @btimed

"""
    @belapsed [[init] setup] f [teardown] keywords...

Benchmark `f` and return the fasted runtime in seconds.

Equivalent to `(@b args...).time`.

See `@be` for more info.
"""
macro belapsed(args...)
    :(@b($(args...)).time)
end
"""
    @ballocated [[init] setup] f [teardown] keywords...

Benchmark `f` and return the minimum amount of memory allocated in bytes. This may not be an
integer if the allocation pattern of `f` is nondeterministic.

Similar to `(@b args...).bytes`.

See `@be` for more info.
"""
macro ballocated(args...)
    :(@b($(args...)).bytes)
end
"""
    @ballocations [[init] setup] f [teardown] keywords...

Benchmark `f` and return the minimum number of allocations. This may not be an
integer if the allocation pattern of `f` is nondeterministic.

Similar to `(@b args...).allocs`.

See `@be` for more info.
"""
macro ballocations(args...)
    :(@b($(args...)).allocs)
end

function save_result(expr)
    if expr.head == :escape && length(expr.args) == 1
        return Expr(:escape, save_result(expr.args[1]))
    end
    if expr.head == :let && length(expr.args) == 2
        return Expr(:let, expr.args[1], save_result(expr.args[2]))
    end
    if expr.head == :block && length(expr.args) == 1
        return Expr(:block, save_result(expr.args[1]))
    end
    result = gensym("result")
    args = expr.args
    length(args) == 2 && return expr
    length(args) == 3 && insert!(args, 3, nothing)
    while length(args) < 5; push!(args, nothing) end
    i = lastindex(args)
    if args[i] === nothing
        args[i] = :(Base.Fix1(setindex!, $result))
    elseif args[i] isa Expr && args[i].head == :->
        args[i].args[2] = :($result[] = $(args[i].args[2]))
    else
        x = gensym()
        args[i] = :($x -> $result[] = $(args[i])($x))
    end
    quote
        $result = Ref{Any}()
        $expr, $result[]
    end
end

"""
    @btimed [[init] setup] f [teardown] keywords...

Benchmark `f` and return a `NamedTuple` containing both the performance information and the
result of end of the pipeline.

Similar to `Base.@timed`

See `@be` for more info on arguments and execution model

# Examples
```julia-repl
julia> @btimed 1+1
(value = 2, time = 1.1338457460906442e-9, bytes = 0.0, gctime = 0.0, allocations = 0.0, compile_time = 0.0, recompile_time = 0.0)

julia> @btimed @eval begin f(x) = x+5; f(7) end
(value = 12, time = 0.001291175, bytes = 39584.0, gctime = 0.0, allocations = 859.0, compile_time = 0.0009262507034496286, recompile_time = 0.0)

julia> @btimed rand(4) sort seconds=1
(value = [0.2657034395624964, 0.2816572316379955, 0.5107416699597612, 0.908363448987202], time = 1.7637310606060608e-8, bytes = 96.0, gctime = 0.0, allocations = 2.0, compile_time = 0.0, recompile_time = 0.0)
```
"""
macro btimed(args...)
    quote
        full,value = $(save_result(Chairmarks.process_args(args)))
        summarized = Chairmarks.summarize(full)
        (
            value=value,
            time=summarized.time,
            bytes=summarized.bytes,
            gctime=summarized.gc_fraction*summarized.time,
            allocations=summarized.allocs,
            compile_time=summarized.compile_fraction*summarized.time,
            recompile_time=summarized.time*summarized.compile_fraction*summarized.recompile_fraction,
            evals=summarized.evals,
            samples=length(full.samples),
        )
    end
end
"""
    @btime [[init] setup] f [teardown] keywords...

Benchmark `f`; print the runtime, amount of allocations, and other relevant performance
information; and return the result of end of the pipeline

Similar to `Base.@time`

See `@be` for more info on arguments and execution model

# Examples
```julia-repl
julia> @btime 1+1
  1.135 ns
2

julia> @btime @eval begin f(x) = x+5; f(7) end
  1.300 ms (859 allocs: 38.656 KiB, 74.29% compile time)
12

julia> @btime rand(4) sort seconds=1
  17.188 ns (2 allocs: 96 bytes)
4-element Vector{Float64}:
 0.27900573230467307
 0.28547170596819316
 0.6337243664545191
 0.9911675357522034
```
"""
macro btime(args...)
    quote
        perf,value = $(save_result(Chairmarks.process_args(args)))
        print("  ")
        show(stdout, MIME"text/plain"(), Chairmarks.summarize(perf))
        println()
        value
    end
end

Base.getproperty(x::Chairmarks.Benchmark, s::Symbol) =
    s == :samples ? getfield(x, :samples) : getproperty.(x.samples, s)
Base.propertynames(x::Chairmarks.Benchmark) = (:samples, fieldnames(Chairmarks.Sample)...)

end
